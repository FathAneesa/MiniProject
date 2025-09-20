import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryTestPage extends StatefulWidget {
  final String studentId;
  const MemoryTestPage({super.key, required this.studentId});

  @override
  State<MemoryTestPage> createState() => _MemoryTestPageState();
}

class _MemoryTestPageState extends State<MemoryTestPage> {
  final Random _random = Random();

  // Game session variables
  List<int> _gameOrder = [];
  int _currentGameIndex = 0;
  int _score = 0;
  bool _gameScored = false;

  bool _gameOver = false;
  Timer? _gameTimer;
  int _timeLeft = 10;

  // Game-specific states
  List<int> _sequence = [];
  List<int> _userSequence = [];
  bool _showSequence = true;
  int? _reactionStart;
  bool _signalShown = false;

  // List<String> _words = ["Cat", "Tree", "Book", "Moon", "Car", "Sun", "Dog"];
  // List<String> _shownWords = [];
  List<String> _userWords = [];

  int? _patternHighlight;

  // -------------------- START TEST --------------------
  void _startTest() async {
    _score = 0;
    _gameOver = false;

    final prefs = await SharedPreferences.getInstance();
    List<String>? lastOrder = prefs.getStringList('lastGameOrder');

    // Create new shuffled order
    List<int> newOrder = List.generate(10, (i) => i)..shuffle();
    while (lastOrder != null &&
        listEquals(lastOrder.map(int.parse).toList(), newOrder)) {
      newOrder.shuffle();
    }

    prefs.setStringList(
        'lastGameOrder', newOrder.map((e) => e.toString()).toList());

    setState(() {
      _gameOrder = newOrder;
      _currentGameIndex = 0;
    });

    _startGameTimer();
  }

  // -------------------- GAME TIMER --------------------
  void _startGameTimer() {
    _timeLeft = 10;
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _nextGame();
      }
    });
  }

  void _nextGame({bool scored = false}) {
  if (scored) _score = (_score + 1).clamp(0, 10);

  _gameTimer?.cancel();
  _resetGameStates();

  if (_currentGameIndex < 9) {
    setState(() {
      _currentGameIndex++;
    });
    _startGameTimer();
  } else {
    _endTest();
  }
}


  void _resetGameStates() {
  _sequence = [];
  _userSequence = [];
  _showSequence = true;
  _reactionSignal = false;
  _reactionStart = null;
  _patternSquare = null;
  _missingIndex = null;
  _numberSequence = null;
  _nextNumber = 1;
  _shownWords = [];
  _userWords = [];
}


  Future<void> _endTest() async {
    _gameTimer?.cancel();
    setState(() => _gameOver = true);

    final url = Uri.parse("http://10.0.2.2:8000/focus-test/add");
    final body = jsonEncode({
      "studentId": widget.studentId,
      "score": _score,
      "date": DateTime.now().toIso8601String(),
    });

    try {
      await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);
    } catch (e) {
      debugPrint("Error sending score: $e");
    }
  }

  // -------------------- GAME BUILDER --------------------
  Widget _buildGame(int index) {
    switch (index) {
      case 0:
        return _sequenceMemoryGame();
      case 1:
        return _quickMathGame();
      case 2:
        return _stroopGame();
      case 3:
        return _reactionGame();
      case 4:
        return _oddOneOutGame();
      case 5:
        return _wordRecallGame();
      case 6:
        return _patternMemoryGame();
      case 7:
        return _missingTileGame();
      case 8:
        return _numberTapGame();
      case 9:
        return _wordColorMatchGame();
      default:
        return const Text("Unknown Game");
    }
  }

  // -------------------- GAME 1: Sequence Memory --------------------
  Widget _sequenceMemoryGame() {
    final colors = [Colors.red, Colors.green, Colors.blue, Colors.orange];
    if (_sequence.isEmpty) {
      _sequence = List.generate(3 + _random.nextInt(3), (_) => _random.nextInt(4));
      _showSequence = true;
      Future.delayed(const Duration(seconds: 2), () {
        _showSequence = false;
        setState(() {});
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Sequence Memory: Repeat the sequence of colors displayed!",
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _showSequence
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _sequence
                    .map((i) => Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(4),
                          color: colors[i],
                        ))
                    .toList(),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colors[i], minimumSize: const Size(50, 50)),
                      onPressed: () {
                        _userSequence.add(i);
                        if (_userSequence.length == _sequence.length) {
                          if (listEquals(_userSequence, _sequence)) _score++;
                          _nextGame();
                        }
                      },
                      child: null);
                }),
              ),
      ],
    );
  }

  // -------------------- GAME 2: Quick Math --------------------
  int? _mathA;
int? _mathB;
int? _mathAnswer;
List<int>? _mathOptions;

Widget _quickMathGame() {
  if (_mathA == null) {
    _mathA = _random.nextInt(10);
    _mathB = _random.nextInt(10);
    _mathAnswer = _mathA! + _mathB!;
    _mathOptions = [_mathAnswer!, _mathAnswer! + 1, _mathAnswer! - 1, _mathAnswer! + 2]..shuffle();
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Quick Math: Solve this problem!",
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      Text("$_mathA + $_mathB = ?", style: const TextStyle(color: Colors.white, fontSize: 24)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        children: _mathOptions!.map((o) {
          return ElevatedButton(
            onPressed: () {
              if (o == _mathAnswer) _score++;
              _mathA = null; // reset for next game
              _mathB = null;
              _mathAnswer = null;
              _mathOptions = null;
              _nextGame();
            },
            child: Text("$o"),
          );
        }).toList(),
      )
    ],
  );
}


  // -------------------- GAME 3: Stroop --------------------
  Widget _stroopGame() {
    final colorMap = {"Red": Colors.red, "Green": Colors.green, "Blue": Colors.blue, "Orange": Colors.orange};
    List<String> words = colorMap.keys.toList();
    int wordIndex = _random.nextInt(4);
    int colorIndex = _random.nextInt(4);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Stroop Test: Tap the color of the text, not the word!",
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(words[wordIndex],
            style: TextStyle(color: colorMap[words[colorIndex]], fontSize: 32)),
        Wrap(
          spacing: 10,
          children: colorMap.keys.map((c) {
            return ElevatedButton(
              onPressed: () {
                if (c == words[colorIndex]) _score++;
                _nextGame();
              },
              child: Text(c),
            );
          }).toList(),
        )
      ],
    );
  }

  // -------------------- GAME 4: Reaction Speed --------------------
  bool _reactionSignal = false;


Widget _reactionGame() {
  if (!_reactionSignal) {
    Future.delayed(Duration(seconds: 1 + _random.nextInt(3)), () {
      if (mounted) {
        setState(() {
          _reactionSignal = true;
          _reactionStart = DateTime.now().millisecondsSinceEpoch;
        });
      }
    });
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Reaction Test: Tap the button as soon as you see GO!",
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: _reactionSignal
            ? () {
                if (_reactionStart != null) {
                  int reactionTime =
                      DateTime.now().millisecondsSinceEpoch - _reactionStart!;
                  if (reactionTime < 1000) _score++; // fast reaction
                }
                _reactionSignal = false;
                _reactionStart = null;
                _nextGame();
              }
            : null,
        child: Text(_reactionSignal ? "GO!" : "Wait..."),
      )
    ],
  );
}


  // -------------------- GAME 5: Odd One Out --------------------
Widget _oddOneOutGame() {
  int oddIndex = _random.nextInt(9);
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Odd One Out: Tap the square that looks different!",
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(9, (i) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: i == oddIndex ? Colors.red : Colors.blue,
                minimumSize: const Size(50, 50)),
            onPressed: () {
              if (i == oddIndex) _score++;
              _nextGame();
            },
            child: null,
          );
        }),
      ),
    ],
  );
}


  // -------------------- GAME 6: Word Recall --------------------
List<String> _words = ["Cat", "Tree", "Book", "Moon", "Car", "Sun", "Dog"];
List<String> _shownWords = [];
List<String> _options = [];
bool _showWords = true;

Widget _wordRecallGame() {
  if (_shownWords.isEmpty) {
    _shownWords = (_words..shuffle()).take(5).toList();
    _showWords = true;

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showWords = false;

          // Include at least one correct word
          List<String> wrongWords = _words
              .where((w) => !_shownWords.contains(w))
              .toList()
              ..shuffle();

          // Mix 1 correct + 3 wrong words
          _options = (_shownWords.take(1).toList() + wrongWords.take(3).toList())..shuffle();
        });
      }
    });
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Word Recall: Remember these words!",
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),

      if (_showWords)
        Wrap(
          spacing: 8,
          children: _shownWords
              .map((w) => Chip(
                    label: Text(w, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.deepPurple,
                  ))
              .toList(),
        ),

      if (!_showWords)
        Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Select a word you remember from the list:",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _options
                  .map((word) => ElevatedButton(
                        onPressed: () {
                          // Show if user is correct or incorrect
                          bool correct = _shownWords.contains(word);
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(correct ? "Correct!" : "Incorrect!"),
                              content: Text(
                                  "The word you selected is ${correct ? "correct" : "not in the list"}"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      if (correct) _score++; // Award point
                                      _shownWords = [];
                                      _options = [];
                                      _nextGame();
                                    },
                                    child: const Text("OK"))
                              ],
                            ),
                          );
                        },
                        child: Text(word),
                      ))
                  .toList(),
            ),
          ],
        ),
    ],
  );
}




  // -------------------- GAME 7: Pattern Memory --------------------
  int? _patternSquare;

Widget _patternMemoryGame() {
  if (_patternSquare == null) _patternSquare = _random.nextInt(9);

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Pattern Memory: Tap the highlighted square!",
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(9, (i) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: i == _patternSquare ? Colors.green : Colors.grey,
              minimumSize: const Size(50, 50),
            ),
            onPressed: () {
              if (i == _patternSquare) _score++;
              _patternSquare = null;
              _nextGame();
            },
            child: null,
          );
        }),
      ),
    ],
  );
}

  // -------------------- GAME 8: Missing Tile --------------------
 int? _missingIndex;

Widget _missingTileGame() {
  if (_missingIndex == null) _missingIndex = _random.nextInt(9);

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Missing Tile: Tap the blank spot!",
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(9, (i) {
          if (i == _missingIndex) {
            return GestureDetector(
              onTap: () {
                _score++;
                _missingIndex = null;
                _nextGame();
              },
              child: Container(
                width: 50,
                height: 50,
                color: Colors.white,
              ),
            );
          } else {
            return Container(
              width: 50,
              height: 50,
              color: Colors.blue,
            );
          }
        }),
      ),
    ],
  );
}

  // -------------------- GAME 9: Number Tap --------------------
List<int>? _numberSequence;
int _nextNumber = 0;
int _tapCount = 0;
bool _numberGameAnswered = false;

Widget _numberTapGame() {
  if (_numberSequence == null) {
    _numberSequence = List.generate(5, (i) => i + 1)..shuffle(); // 5 numbers
    _nextNumber = _numberSequence!.reduce(min); // smallest number
    _tapCount = 0;
    _numberGameAnswered = false;
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Number Tap: Tap numbers in ascending order!",
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _numberSequence!.map((n) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(50, 50)),
            onPressed: _numberGameAnswered ? null : () {
              if (n == _nextNumber) _tapCount++; // correct tap count
              if (_tapCount == _numberSequence!.length) {
                // End of game
                _numberGameAnswered = true;
                if (_tapCount == _numberSequence!.length) _score++; // full correct
                Future.delayed(const Duration(milliseconds: 500), () => _nextGame());
              } else {
                // next smallest number
                _nextNumber = _numberSequence!
                    .where((num) => num > _nextNumber)
                    .fold(_nextNumber, (prev, curr) => min(prev, curr));
              }
            },
            child: Text("$n"),
          );
        }).toList(),
      ),
    ],
  );
}



  // -------------------- GAME 10: Word-Color Match --------------------
  Widget _wordColorMatchGame() {
  final words = ["Sun", "Sky", "Leaf", "Fire"];
  final colors = [Colors.yellow, Colors.blue, Colors.green, Colors.red];
  int correct = _random.nextInt(4);

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Word-Color Match: Tap the word that matches the color!",
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      Text(words[correct],
          style: TextStyle(color: colors[correct], fontSize: 28)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        children: List.generate(4, (i) {
          return ElevatedButton(
            onPressed: () {
              if (i == correct) _score++;
              _nextGame();
            },
            child: Text(words[i]),
          );
        }),
      )
    ],
  );
}

  // -------------------- OTHER GAMES --------------------
  // For brevity: Odd One Out, Word Recall, Pattern Memory, Missing Tile, Number Tap, Word-Color Match
  // You can replicate same pattern: short instruction + interactive buttons/grid

  // -------------------- BUILD --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Memory & Focus Test")),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.indigo])),
        child: Center(
          child: _gameOver
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Test Finished! Score: $_score",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Back to Dashboard")),
                  ],
                )
              : (_gameOrder.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Ready for your Memory Test?",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _startTest,
                          child: const Text("Start Test"),
                        )
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Game ${_currentGameIndex + 1} of 10",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18)),
                        SizedBox(
  width: 60,
  height: 60,
  child: Stack(
    alignment: Alignment.center,
    children: [
      CircularProgressIndicator(
        value: _timeLeft / 10,
        backgroundColor: Colors.white.withOpacity(0.3),
        color: Colors.orange,
        strokeWidth: 6,
      ),
      Text(
        "$_timeLeft s",
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),
      )
    ],
  ),
),

                        const SizedBox(height: 20),
                        _buildGame(_gameOrder[_currentGameIndex]),
                      ],
                    )),
        ),
      ),
    );
  }
}
