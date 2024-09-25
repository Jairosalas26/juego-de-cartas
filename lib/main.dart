import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juego de Cartas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DifficultySelectionPage(),
    );
  }
}

class DifficultySelectionPage extends StatelessWidget {
  const DifficultySelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona la Dificultad'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => startGame(context, 6),
              child: const Text('Fácil (6 cartas)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => startGame(context, 8),
              child: const Text('Medio (8 cartas)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => startGame(context, 12),
              child: const Text('Difícil (12 cartas)'),
            ),
          ],
        ),
      ),
    );
  }

  void startGame(BuildContext context, int cardCount) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CardGamePage(cardCount: cardCount),
      ),
    );
  }
}

class CardGamePage extends StatefulWidget {
  final int cardCount;

  const CardGamePage({Key? key, required this.cardCount}) : super(key: key);

  @override
  _CardGamePageState createState() => _CardGamePageState();
}

class _CardGamePageState extends State<CardGamePage> {
  late List<String> cardImages;
  late List<bool> cardFlips;
  int? firstCardIndex;
  int? secondCardIndex;
  int pairCount = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    List<String> baseImages = [
      'https://picsum.photos/200/300?random=1',
      'https://picsum.photos/200/300?random=2',
      'https://picsum.photos/200/300?random=3',
      'https://picsum.photos/200/300?random=4',
      'https://picsum.photos/200/300?random=5',
      'https://picsum.photos/200/300?random=6',
    ];

    baseImages = baseImages.take(widget.cardCount ~/ 2).toList();

    cardImages = [...baseImages, ...baseImages];
    cardImages.shuffle(Random());
    cardFlips = List.generate(widget.cardCount, (index) => false);
    firstCardIndex = null;
    secondCardIndex = null;
    pairCount = 0;
    score = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego de Cartas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Intentos: $score', style: TextStyle(fontSize: 18)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.cardCount <= 8 ? 2 : 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: cardImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => onCardTap(index),
                  child: Card(
                    color: cardFlips[index] ? Colors.white : Colors.blue,
                    child: cardFlips[index]
                        ? Image.network(
                            cardImages[index],
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          )
                        : const Icon(Icons.question_mark, size: 40.0),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                initializeGame();
              });
            },
            child: const Text('Reiniciar Juego'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const DifficultySelectionPage(),
                ),
              );
            },
            child: const Text('Cambiar Dificultad'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void onCardTap(int index) {
    if (cardFlips[index] || secondCardIndex != null) return;

    setState(() {
      cardFlips[index] = true;
      score++;

      if (firstCardIndex == null) {
        firstCardIndex = index;
      } else {
        secondCardIndex = index;
        checkMatch();
      }
    });
  }

  void checkMatch() {
    if (cardImages[firstCardIndex!] == cardImages[secondCardIndex!]) {
      pairCount++;
      firstCardIndex = null;
      secondCardIndex = null;

      if (pairCount == cardImages.length ~/ 2) {
        // El juego ha terminado, mostrar la última carta antes de reiniciar
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            initializeGame();
          });
        });
      }
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          cardFlips[firstCardIndex!] = false;
          cardFlips[secondCardIndex!] = false;
          firstCardIndex = null;
          secondCardIndex = null;
        });
      });
    }
  }
}

