class CardModel {
  String imagePath;
  bool isFaceUp;
  bool isMatched;

  CardModel({
    required this.imagePath,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}