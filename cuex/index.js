const {onRequest} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const axios = require("axios");
const admin = require("firebase-admin");

admin.initializeApp();

const CLIENT_ID = "488636506968-ldbnaudsdndqugrgt6tslfpr4llk0jcp.apps.googleusercontent.com";
const CLIENT_SECRET = "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";
const REDIRECT_URI = "https://us-central1-cuex-ab44c.cloudfunctions.net/youtubeCallback";

// Step 1: Generate auth URL
exports.youtubeAuthUrl = onRequest(async (req, res) => {
  const userId = req.query.userId;
  const url = `https://accounts.google.com/o/oauth2/v2/auth?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&response_type=code&scope=https://www.googleapis.com/auth/youtube&access_type=offline&prompt=select_account%20consent&state=${userId}`;
  res.json({url});
});

// Step 2: Handle browser callback
exports.youtubeCallback = onRequest(async (req, res) => {
  const code = req.query.code;
  const userId = req.query.state;

  try {
    const {data} = await axios.post("https://oauth2.googleapis.com/token", {
      code,
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      redirect_uri: REDIRECT_URI,
      grant_type: "authorization_code",
    });

    await admin.firestore().collection("Users").doc(userId).update({
      youtube: {
        refresh_token: data.refresh_token,
        access_token: data.access_token,
        expires_at: Date.now() + data.expires_in * 1000,
      },
    });

    res.send("<h2>YouTube connected! You can close this tab.</h2>");
  } catch (e) {
    res.status(500).send("Error: " + e.message);
  }
});

// Step 3: Exchange server auth code from native Google Sign In
exports.youtubeExchangeCode = onRequest(async (req, res) => {
  const {code, userId} = req.body;

  if (!code || !userId) {
    return res.status(400).json({error: "Missing code or userId"});
  }

  try {
    const {data} = await axios.post("https://oauth2.googleapis.com/token", {
      code,
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      redirect_uri: "postmessage",
      grant_type: "authorization_code",
    });

    if (!data.refresh_token) {
      return res.status(400).json({error: "No refresh token returned."});
    }

    await admin.firestore().collection("Users").doc(userId).update({
      youtube: {
        refresh_token: data.refresh_token,
        access_token: data.access_token,
        expires_at: Date.now() + data.expires_in * 1000,
      },
    });

    res.json({success: true});
  } catch (e) {
    console.error("Exchange error:", e.response?.data || e.message);
    res.status(500).json({error: e.response?.data || e.message});
  }
});

// Step 4: Refresh access token
exports.youtubeRefreshToken = onRequest(async (req, res) => {
  const userId = req.query.userId;

  if (!userId) {
    return res.status(400).json({error: "Missing userId"});
  }

  const doc = await admin.firestore().collection("Users").doc(userId).get();
  const youtube = doc.data()?.youtube;

  if (!youtube?.refresh_token) {
    return res.status(401).json({error: "Not connected"});
  }

  try {
    const {data} = await axios.post("https://oauth2.googleapis.com/token", {
      refresh_token: youtube.refresh_token,
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      grant_type: "refresh_token",
    });

    await admin.firestore().collection("Users").doc(userId).update({
      "youtube.access_token": data.access_token,
      "youtube.expires_at": Date.now() + data.expires_in * 1000,
    });

    res.json({access_token: data.access_token});
  } catch (e) {
    res.status(500).json({error: e.message});
  }
});

// Step 5: Auto complete expired events (runs every 24 hours)
exports.autoCompleteEvents = onSchedule("every 24 hours", async (event) => {
  const now = admin.firestore.Timestamp.now();

  const snapshot = await admin.firestore()
      .collection("Events")
      .where("eventStatus", "!=", "completed")
      .where("endDate", "<=", now)
      .get();

  if (snapshot.empty) {
    console.log("✅ No events to complete");
    return;
  }

  const batch = admin.firestore().batch();
  snapshot.docs.forEach((doc) => {
    console.log(`🏁 Completing event: ${doc.data().name}`);
    batch.update(doc.ref, {
      eventStatus: "completed",
      updatedAt: now,
    });
  });

  await batch.commit();
  console.log(`✅ Completed ${snapshot.docs.length} events`);
});