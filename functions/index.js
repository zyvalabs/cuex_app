const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Generic FCM Notification Cloud Function
 * 
 * Supports:
 * - Send to specific device tokens
 * - Send to topic (broadcast)
 * - Subscribe tokens to topic
 * - Unsubscribe tokens from topic
 * 
 * Request body:
 * {
 *   action: "sendToTokens" | "sendToTopic" | "subscribeToTopic" | "unsubscribeFromTopic",
 *   tokens: ["token1", "token2"],   // for sendToTokens, subscribe, unsubscribe
 *   topic: "match_123",             // for sendToTopic, subscribe, unsubscribe
 *   notification: {
 *     title: "High Break!",
 *     body: "Player scored 147!",
 *     imageUrl: "https://...",      // optional
 *   },
 *   data: {                         // optional - any custom key/value
 *     matchId: "123",
 *     type: "high_break",
 *     score: "147",
 *   }
 * }
 */
exports.notify = functions.https.onRequest(async (req, res) => {
  // CORS
  res.set("Access-Control-Allow-Origin", "*");
  if (req.method === "OPTIONS") {
    res.set("Access-Control-Allow-Methods", "POST");
    res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    res.status(204).send("");
    return;
  }

  if (req.method !== "POST") {
    res.status(405).json({ success: false, error: "Method not allowed" });
    return;
  }

  try {
    const { action, tokens, topic, notification, data } = req.body;

    if (!action) {
      res.status(400).json({ success: false, error: "action is required" });
      return;
    }

    switch (action) {

      // ── Send to specific device tokens ──
      case "sendToTokens": {
        if (!tokens || tokens.length === 0) {
          res.status(400).json({ success: false, error: "tokens required" });
          return;
        }
        if (!notification?.title || !notification?.body) {
          res.status(400).json({ success: false, error: "notification title and body required" });
          return;
        }

        const message = {
          notification: {
            title: notification.title,
            body: notification.body,
            ...(notification.imageUrl && { imageUrl: notification.imageUrl }),
          },
          android: {
            notification: {
              icon: "ic_notification", // your app's notification icon
              color: "#10B981",        // CueX green
              ...(notification.imageUrl && { imageUrl: notification.imageUrl }),
            },
          },
          apns: {
            payload: {
              aps: {
                "mutable-content": 1,
              },
            },
            ...(notification.imageUrl && {
              fcmOptions: { imageUrl: notification.imageUrl },
            }),
          },
          data: data ? Object.fromEntries(
            Object.entries(data).map(([k, v]) => [k, String(v)])
          ) : {},
          tokens: tokens,
        };

        const response = await admin.messaging().sendEachForMulticast(message);
        
        // Filter out invalid tokens
        const failedTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            const code = resp.error?.code;
            if (
              code === "messaging/invalid-registration-token" ||
              code === "messaging/registration-token-not-registered"
            ) {
              failedTokens.push(tokens[idx]);
            }
          }
        });

        res.status(200).json({
          success: true,
          sent: response.successCount,
          failed: response.failureCount,
          failedTokens, // return so Flutter can clean up invalid tokens in Supabase
        });
        break;
      }

      // ── Send to topic ──
      case "sendToTopic": {
        if (!topic) {
          res.status(400).json({ success: false, error: "topic required" });
          return;
        }
        if (!notification?.title || !notification?.body) {
          res.status(400).json({ success: false, error: "notification title and body required" });
          return;
        }

        const message = {
          notification: {
            title: notification.title,
            body: notification.body,
            ...(notification.imageUrl && { imageUrl: notification.imageUrl }),
          },
          android: {
            notification: {
              icon: "ic_notification",
              color: "#10B981",
              ...(notification.imageUrl && { imageUrl: notification.imageUrl }),
            },
          },
          apns: {
            payload: { aps: { "mutable-content": 1 } },
            ...(notification.imageUrl && {
              fcmOptions: { imageUrl: notification.imageUrl },
            }),
          },
          data: data ? Object.fromEntries(
            Object.entries(data).map(([k, v]) => [k, String(v)])
          ) : {},
          topic: topic,
        };

        await admin.messaging().send(message);
        res.status(200).json({ success: true });
        break;
      }

      // ── Subscribe tokens to topic ──
      case "subscribeToTopic": {
        if (!tokens || tokens.length === 0 || !topic) {
          res.status(400).json({ success: false, error: "tokens and topic required" });
          return;
        }
        await admin.messaging().subscribeToTopic(tokens, topic);
        res.status(200).json({ success: true });
        break;
      }

      // ── Unsubscribe tokens from topic ──
      case "unsubscribeFromTopic": {
        if (!tokens || tokens.length === 0 || !topic) {
          res.status(400).json({ success: false, error: "tokens and topic required" });
          return;
        }
        await admin.messaging().unsubscribeFromTopic(tokens, topic);
        res.status(200).json({ success: true });
        break;
      }

      default:
        res.status(400).json({ success: false, error: `Unknown action: ${action}` });
    }

  } catch (error) {
    console.error("❌ Notification error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});