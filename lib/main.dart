import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: 'Card Matching Game',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const GameScreen(),
      ),
    );
  }
}

class GameProvider extends ChangeNotifier {
  final List<CardModel> _cards = [];
  CardModel? _firstSelected;
  CardModel? _secondSelected;
  int _score = 0;
  int _timeElapsed = 0;
  Timer? _timer;
  bool _gameOver = false;
  bool _showPicturesFirst = true;

  GameProvider() {
    _initializeGame();
  }

  List<CardModel> get cards => _cards;
  int get score => _score;
  int get timeElapsed => _timeElapsed;
  bool get gameOver => _gameOver;
  bool get showPicturesFirst => _showPicturesFirst;

  void _initializeGame() {
    _cards.clear();
    List<String> cardValues = [
      'assets/image1.png', 
      'assets/image2.png', 
      'assets/image3.png', 
      'assets/image4.png', 
      'assets/image5.png', 
      'assets/image6.png', 
      'assets/image7.png', 
      'assets/image8.png'
    ];
    cardValues = [...cardValues, ...cardValues];
    cardValues.shuffle();

    for (var value in cardValues) {
      _cards.add(CardModel(imagePath: value));
    }

    _score = 0;
    _timeElapsed = 0;
    _gameOver = false;
    _showPicturesFirst = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      _showPicturesFirst = false;
      notifyListeners();
      _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeElapsed++;
      notifyListeners();
    });
  }

  void flipCard(CardModel card) {
    if (card.isMatched || card.isFlipped || _gameOver || _showPicturesFirst) return;
    card.isFlipped = true;

    if (_firstSelected == null) {
      _firstSelected = card;
    } else {
      _secondSelected = card;
      _checkForMatch();
    }
    notifyListeners();
  }

  void _checkForMatch() {
    if (_firstSelected!.imagePath == _secondSelected!.imagePath) {
      _firstSelected!.isMatched = true;
      _secondSelected!.isMatched = true;
      _score += 10;
      _firstSelected = null;
      _secondSelected = null;
      _checkGameOver();
      notifyListeners();
    } else {
      // After a short delay, flip the cards back
      Future.delayed(const Duration(seconds: 1), () {
        _firstSelected!.isFlipped = false;
        _secondSelected!.isFlipped = false;
        _firstSelected = null;
        _secondSelected = null;
        notifyListeners();
      });
    }
  }

  void _checkGameOver() {
    if (_cards.every((card) => card.isMatched)) {
      _gameOver = true;
      _timer?.cancel();
      notifyListeners();
    }
  }

  void resetGame() {
    _initializeGame();
  }
}

class CardModel {
  final String imagePath;
  bool isFlipped = false;
  bool isMatched = false;
  CardModel({required this.imagePath});
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Card Matching Game')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: ${game.score}', style: const TextStyle(fontSize: 20)),
                Text('Time: ${game.timeElapsed}s', style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: game.cards.length,
              itemBuilder: (context, index) {
                return CardWidget(card: game.cards[index], showPicture: game.showPicturesFirst);
              },
            ),
          ),
          if (game.gameOver)
            ElevatedButton(
              onPressed: game.resetGame,
              child: const Text('Restart Game'),
            ),
        ],
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final CardModel card;
  final bool showPicture;
  const CardWidget({super.key, required this.card, required this.showPicture});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
    return GestureDetector(
      onTap: () => game.flipCard(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.isFlipped || showPicture ? Colors.white : Colors.blue,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        alignment: Alignment.center,
        child: card.isFlipped || showPicture
            ? Image.asset(card.imagePath) // Show the image
            : const Icon(Icons.help_outline, size: 36, color: Colors.white), // Show question mark
      ),
    );
  }
}
