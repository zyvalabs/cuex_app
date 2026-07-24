import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/sports/sports_grid.dart';
import '../../../../../common/widgets/step indicator/step_indicator.dart';
import '../../../controllers/sport_controller.dart';
import '../../../controllers/venue_controller.dart';
import 'format_selector.dart';
import 'match_selector.dart';


class CreateMatchScreen1 extends StatefulWidget {
  const CreateMatchScreen1({super.key});

  @override
  State<CreateMatchScreen1> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen1> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 4;
  String? _selectedSportName; String? _selectedFormat;
  int _matchLength = 5;
  String? _selectedSportId;

  static const List<String> _titles = [
    'Select Sport',
    'Match Format',
    'YouTube Details',
    'Review',
  ];

  @override
  void initState() {
    super.initState();
    Get.put(SportController());
  }

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _showDone();
    }
  }

  void _back() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _currentStep--);
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _showDone() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F6E56),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Match Created',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6E56),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _back,
        ),
        title: const Text(
          'Create Match',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: StepIndicator(
              totalSteps: _totalSteps,
              currentStep: _currentStep,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _totalSteps,
              onPageChanged: (i) => setState(() => _currentStep = i),
              itemBuilder: (_, i) =>
              i == 0 ? _buildSportStep() : _DummyStep(title: _titles[i], step: i + 1),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6E56),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _currentStep == _totalSteps - 1 ? 'Finish' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Sport',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose the game you are playing',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final sports = SportController.instance.activeSports;
            if (sports.isEmpty) return const Center(child: CircularProgressIndicator());
            return SportsGrid(
              sports: sports,
              selectedSportIds: _selectedSportId == null ? [] : [_selectedSportId!],
              onTap: (sport) => setState(() {
                _selectedSportId = sport.id;
                _selectedSportName = sport.name;
              }),
            );
          }),
          FormatSelector(
            sportName: _selectedSportName,
            selectedFormat: _selectedFormat,
            onSelected: (f) => setState(() => _selectedFormat = f),
          ),
          MatchLengthStepper(
            sportName: _selectedSportName,
            value: _matchLength,
            onChanged: (v) => setState(() => _matchLength = v),
          ),
        ],
      ),
    );
  }
}

class _DummyStep extends StatelessWidget {
  final String title;
  final int step;

  const _DummyStep({required this.title, required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Step ' + step.toString(),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}