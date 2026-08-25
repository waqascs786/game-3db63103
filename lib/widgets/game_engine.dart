import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_config.dart';

class GameEngine extends StatefulWidget {
  final GameConfig config;
  final int currentLevel;
  final int coins;
  final Function(int) onLevelComplete;
  final VoidCallback onHintUsed;
  final VoidCallback? onNavigatePrev;
  final VoidCallback? onNavigateNext;

  const GameEngine({
    super.key,
    required this.config,
    required this.currentLevel,
    required this.coins,
    required this.onLevelComplete,
    required this.onHintUsed,
    this.onNavigatePrev,
    this.onNavigateNext,
  });

  @override
  State<GameEngine> createState() => _GameEngineState();
}

class _GameEngineState extends State<GameEngine> with SingleTickerProviderStateMixin {
  String _currentAnswer = '';
  bool _showComplete = false;
  late AnimationController _animController;

  Color? _getColor(String key) {
    final value = widget.config.design['colors']?[key];
    if (value is int) return Color(value);
    return Colors.white;
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _getColor('background'),
      child: _showComplete ? _buildCompleteScreen() : _buildGameScreen(),
    );
  }

  Widget _buildGameScreen() {
    if (widget.config.levels.isEmpty) return _emptyScreen();
    if (widget.currentLevel >= widget.config.levels.length) return _allDoneScreen();

    final level = widget.config.levels[widget.currentLevel];
    final answer = level.answer.toUpperCase();
    final letters = _generateLetters(answer);

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildQuestion(level),
          Expanded(child: _buildImage(level)),
          _buildAnswerSlots(answer),
          const SizedBox(height: 8),
          _buildLetterGrid(letters),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _emptyScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.games, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No levels available', style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _allDoneScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
          const SizedBox(height: 16),
          const Text('All levels complete!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Coins: ' + widget.coins.toString(), style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.onNavigatePrev,
            child: Icon(Icons.chevron_left, color: widget.onNavigatePrev != null ? Colors.white : Colors.grey, size: 28),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: _getColor('primary'), borderRadius: BorderRadius.circular(6)),
            child: Text('Level: ' + (widget.currentLevel + 1).toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: _getColor('secondary'), borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              const Icon(Icons.monetization_on, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(widget.coins.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
          ),
          GestureDetector(
            onTap: widget.onNavigateNext,
            child: Icon(Icons.chevron_right, color: widget.onNavigateNext != null ? Colors.white : Colors.grey, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(GameLevel level) {
    if (level.question.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(level.question, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
    );
  }

  Widget _buildImage(GameLevel level) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF30363D), borderRadius: BorderRadius.circular(12)),
      child: level.imageUrl.isNotEmpty
          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(level.imageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image, size: 64, color: Colors.grey))))
          : const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)),
    );
  }

  Widget _buildAnswerSlots(String answer) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(answer.length, (i) {
          final char = i < _currentAnswer.length ? _currentAnswer[i] : '';
          return Container(
            width: 36, height: 36, margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: char.isNotEmpty ? _getColor('primary') : const Color(0xFF30363D),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(child: Text(char, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
          );
        }),
      ),
    );
  }

  Widget _buildLetterGrid(List<String> letters) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
        children: letters.map((letter) => GestureDetector(
          onTap: () {
            setState(() => _currentAnswer += letter);
            _checkAnswer();
          },
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: _getColor('primary'), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(letter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.people, size: 18), label: const Text('Ask Friends'),
            style: ElevatedButton.styleFrom(backgroundColor: _getColor('secondary')),
          ),
          ElevatedButton.icon(
            onPressed: widget.coins >= 20 ? () { widget.onHintUsed(); _useHint(); } : null,
            icon: const Icon(Icons.lightbulb, size: 18), label: const Text('Hints (20)'),
            style: ElevatedButton.styleFrom(backgroundColor: _getColor('primary')),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteScreen() {
    final level = widget.config.levels[widget.currentLevel];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.elasticOut)),
            child: const Icon(Icons.check_circle, size: 100, color: Colors.green),
          ),
          const SizedBox(height: 24),
          const Text('Well Done!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('+' + level.coinsReward.toString() + ' coins', style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 20)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() => _showComplete = false);
              widget.onLevelComplete(level.coinsReward);
            },
            child: const Text('Next Level'),
          ),
        ],
      ),
    );
  }

  void _checkAnswer() {
    final answer = widget.config.levels[widget.currentLevel].answer.toUpperCase();
    if (_currentAnswer.length == answer.length) {
      if (_currentAnswer == answer) {
        _animController.forward(from: 0);
        setState(() => _showComplete = true);
      } else {
        setState(() => _currentAnswer = '');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wrong answer! Try again'), backgroundColor: Colors.red, duration: Duration(seconds: 1)),
        );
      }
    }
  }

  void _useHint() {
    final answer = widget.config.levels[widget.currentLevel].answer.toUpperCase();
    if (_currentAnswer.length < answer.length) {
      setState(() => _currentAnswer += answer[_currentAnswer.length]);
      _checkAnswer();
    }
  }

  List<String> _generateLetters(String answer) {
    final chars = answer.split('');
    final all = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    final random = Random();
    final needed = (widget.config.settings['amountOfLetters'] ?? 14) - chars.length;
    for (var i = 0; i < needed; i++) {
      chars.add(all[random.nextInt(all.length)]);
    }
    chars.shuffle();
    return chars;
  }
}