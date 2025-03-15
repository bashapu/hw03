import 'package:flutter/material.dart';
import 'card_model.dart';

void main() {
  runApp(const MemoryGame());
}

class MemoryGame extends StatelessWidget {
  const MemoryGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int score = 0;
  List<bool> flippedCards = List.generate(16, (_) => false);
  List<CardModel> cards = List.generate(8, (index) {
    return CardModel(imagePath: 'assets/image$index.png');
  })..addAll(List.generate(8, (index) {
    return CardModel(imagePath: 'assets/image$index.png');
  }));

  void _checkMatch(int firstIndex, int secondIndex) {
    if (cards[firstIndex].imagePath == cards[secondIndex].imagePath) {
      cards[firstIndex].isMatched = true;
      cards[secondIndex].isMatched = true;
      score += 10;
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          cards[firstIndex].isFaceUp = false;
          cards[secondIndex].isFaceUp = false;
        });
      });
      score -= 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Memory Game")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 16,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  flippedCards[index] = !flippedCards[index];
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  color: cards[index].isFaceUp ? Colors.white : Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child:
                    cards[index].isFaceUp
                        ? Image.asset(cards[index].imagePath)
                        : const Center(child: Text("Tap")),
              )
            );
          },
        ),
      ),
    );
  }
}