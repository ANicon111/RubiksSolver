import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rubikssolver/algo.dart';
import 'package:rubikssolver/definitions.dart';
import 'package:rubikssolver/logic.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RubiksCube cube = RubiksCube(3);
  Timer? movePlayer;
  bool gameStarted = false;
  TextEditingController sizeGetter = TextEditingController(text: "3");
  List<Color> colors = [
    Colors.green,
    Colors.white,
    Colors.orange,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  @override
  void dispose() {
    movePlayer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: 1080 * RelSize(context).pixel,
                height: 810 * RelSize(context).pixel,
                child: Stack(
                  children: [
                    MaterialButton(
                      onPressed: () {
                        if (movePlayer != null) {
                          movePlayer?.cancel();
                          movePlayer = null;
                          setState(() {});
                        } else {
                          List<Move> algorithmMoves =
                              Algorithm(cube.carbonCopy).moves;
                          if (kDebugMode) {
                            print(
                                "Number of operations:${algorithmMoves.length}");
                          }
                          int i = 0;
                          void doMove() {
                            if (i == algorithmMoves.length) {
                              movePlayer!.cancel();
                              movePlayer = null;
                              setState(() {});
                              return;
                            }
                            Move move = algorithmMoves[i++];
                            cube.rotate(
                                move.rotationList, move.index, move.isReversed);
                            setState(() {});
                          }

                          movePlayer = Timer.periodic(
                              const Duration(milliseconds: 100), (_) {
                            doMove();
                          });
                        }
                      },
                      color: Theme.of(context).colorScheme.secondary,
                      hoverColor: Theme.of(context).colorScheme.primary,
                      height: RelSize(context).pixel * 96,
                      shape: const CircleBorder(side: BorderSide.none),
                      child: Icon(
                        movePlayer != null ? Icons.cancel : Icons.play_circle,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: RelSize(context).pixel * 48,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Row(
                        children: [
                          SizedBox(
                            width: RelSize(context).pixel * 120,
                            child: TextFormField(
                              style: TextStyle(
                                  fontSize: RelSize(context).pixel * 32),
                              decoration: InputDecoration(
                                labelStyle: TextStyle(
                                  fontSize: RelSize(context).pixel * 32,
                                ),
                                label: const Text(
                                  "Dimension",
                                ),
                                counterText: "",
                              ),
                              controller: sizeGetter,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                FilteringTextInputFormatter.singleLineFormatter
                              ],
                              maxLength: 2,
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              int val = int.tryParse(sizeGetter.text) ?? 3;
                              if (val < 2) {
                                val = 2;
                              }
                              sizeGetter.text = val.toString();
                              cube = RubiksCube(val);
                              setState(() {});
                            },
                            color: Theme.of(context).colorScheme.secondary,
                            hoverColor: Theme.of(context).colorScheme.primary,
                            height: RelSize(context).pixel * 96,
                            shape: const CircleBorder(side: BorderSide.none),
                            child: Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.onSecondary,
                              size: RelSize(context).pixel * 48,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: MaterialButton(
                        onPressed: () {
                          for (int i = 0; i < 1000; i++) {
                            cube.rotate(
                                PossibleRotations.toList[Random().nextInt(3)],
                                Random().nextInt(cube.size),
                                Random().nextBool());
                          }
                          setState(() {});
                        },
                        color: Theme.of(context).colorScheme.secondary,
                        hoverColor: Theme.of(context).colorScheme.primary,
                        height: RelSize(context).pixel * 96,
                        shape: const CircleBorder(side: BorderSide.none),
                        child: Icon(
                          Icons.shuffle,
                          color: Theme.of(context).colorScheme.onSecondary,
                          size: RelSize(context).pixel * 48,
                        ),
                      ),
                    ),
                    CubeFace(
                      top: 270 * RelSize(context).pixel,
                      left: 0 * RelSize(context).pixel,
                      dim: 270 * RelSize(context).pixel / cube.size,
                      size: cube.size,
                      update: () {
                        setState(() {});
                      },
                      rotateX: (int index, bool direction) {
                        cube.rotate(
                            PossibleRotations.line, index, direction, true);
                      },
                      rotateY: (int index, bool direction) {
                        cube.rotate(
                            PossibleRotations.circle, index, !direction, true);
                      },
                      cube: cube.cube,
                      side: Side.left,
                      colors: colors,
                    ),
                    CubeFace(
                      top: 0 * RelSize(context).pixel,
                      left: 270 * RelSize(context).pixel,
                      dim: 270 * RelSize(context).pixel / cube.size,
                      size: cube.size,
                      update: () {
                        setState(() {});
                      },
                      rotateX: (int index, bool direction) {
                        cube.rotate(
                            PossibleRotations.circle, index, direction, true);
                      },
                      rotateY: (int index, bool direction) {
                        cube.rotate(PossibleRotations.triangle,
                            cube.size - 1 - index, direction, true);
                      },
                      cube: cube.cube,
                      side: Side.top,
                      colors: colors,
                    ),
                    CubeFace(
                      top: 270 * RelSize(context).pixel,
                      left: 270 * RelSize(context).pixel,
                      dim: 270 * RelSize(context).pixel / cube.size,
                      size: cube.size,
                      update: () {
                        setState(() {});
                      },
                      rotateX: (int index, bool direction) {
                        cube.rotate(
                            PossibleRotations.line, index, direction, true);
                      },
                      rotateY: (int index, bool direction) {
                        cube.rotate(PossibleRotations.triangle,
                            cube.size - 1 - index, direction, true);
                      },
                      cube: cube.cube,
                      side: Side.front,
                      colors: colors,
                    ),
                    CubeFace(
                      top: 540 * RelSize(context).pixel,
                      left: 270 * RelSize(context).pixel,
                      dim: 270 * RelSize(context).pixel / cube.size,
                      size: cube.size,
                      update: () {
                        setState(() {});
                      },
                      rotateX: (int index, bool direction) {
                        cube.rotate(PossibleRotations.circle,
                            cube.size - 1 - index, !direction, true);
                      },
                      rotateY: (int index, bool direction) {
                        cube.rotate(PossibleRotations.triangle,
                            cube.size - 1 - index, direction, true);
                      },
                      cube: cube.cube,
                      side: Side.bottom,
                      colors: colors,
                    ),
                    CubeFace(
                      top: 270 * RelSize(context).pixel,
                      left: 540 * RelSize(context).pixel,
                      dim: 270 * RelSize(context).pixel / cube.size,
                      size: cube.size,
                      update: () {
                        setState(() {});
                      },
                      rotateX: (int index, bool direction) {
                        cube.rotate(
                            PossibleRotations.line, index, direction, true);
                      },
                      rotateY: (int index, bool direction) {
                        cube.rotate(PossibleRotations.circle,
                            cube.size - 1 - index, direction, true);
                      },
                      cube: cube.cube,
                      side: Side.right,
                      colors: colors,
                    ),
                    CubeFace(
                      top: 270 * RelSize(context).pixel,
                      left: 810 * RelSize(context).pixel,
                      dim: 270 * RelSize(context).pixel / cube.size,
                      size: cube.size,
                      update: () {
                        setState(() {});
                      },
                      rotateX: (int index, bool direction) {
                        cube.rotate(
                            PossibleRotations.line, index, direction, true);
                      },
                      rotateY: (int index, bool direction) {
                        cube.rotate(PossibleRotations.triangle, index,
                            !direction, true);
                      },
                      cube: cube.cube,
                      side: Side.back,
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ),
            gameStarted
                ? Container()
                : Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(200, 0, 0, 0),
                        borderRadius: BorderRadius.circular(
                          RelSize(context).pixel * 20,
                        ),
                      ),
                      width: max(
                          MediaQuery.of(context).size.width -
                              RelSize(context).vmin * 20,
                          MediaQuery.of(context).size.shortestSide),
                      height: MediaQuery.of(context).size.height -
                          RelSize(context).vmin * 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Rubik's Solver",
                            style: TextStyle(
                                fontSize: RelSize(context).pixel * 64),
                          ),
                          Tooltip(
                            message:
                                "Această aplicație simulează un cub magic,\nun joc de dexteritate care se bazează\npe rotirea la 90 de grade a liniilor unui cub\ncu fețe segmentate NxN",
                            textAlign: TextAlign.center,
                            child: Icon(
                              Icons.info_outline,
                              size: RelSize(context).pixel * 64,
                            ),
                          ),
                          Container(),
                          MaterialButton(
                            onPressed: () {
                              gameStarted = true;
                              setState(() {});
                            },
                            color: Theme.of(context).colorScheme.secondary,
                            hoverColor: Theme.of(context).colorScheme.primary,
                            height: RelSize(context).pixel * 96,
                            shape: const CircleBorder(side: BorderSide.none),
                            child: Icon(
                              Icons.play_arrow,
                              color: Theme.of(context).colorScheme.onSecondary,
                              size: RelSize(context).pixel * 48,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class CubeFace extends StatefulWidget {
  const CubeFace({
    Key? key,
    required this.top,
    required this.left,
    required this.dim,
    required this.size,
    required this.update,
    required this.rotateX,
    required this.rotateY,
    required this.cube,
    required this.side,
    required this.colors,
  }) : super(key: key);
  final double top;
  final double left;
  final double dim;
  final int size;
  final Function update;
  final Function(int index, bool direction) rotateX;
  final Function(int index, bool direction) rotateY;
  final Map<Side, List<List<PieceData>>> cube;
  final Side side;
  final List<Color> colors;

  @override
  State<CubeFace> createState() => _CubeFaceState();
}

class _CubeFaceState extends State<CubeFace> {
  Offset initMousePos = const Offset(0, 0);
  Offset currentMousePos = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      child: Column(
        children: List.generate(
          widget.size,
          (i) => Row(
            children: List.generate(
              widget.size,
              (j) => GestureDetector(
                onTap: kDebugMode
                    ? () {
                        // ignore: avoid_print
                        print(widget.cube[widget.side]![i][j]);
                      }
                    : null,
                onPanStart: (details) {
                  initMousePos = details.globalPosition;
                  currentMousePos = initMousePos;
                },
                onPanUpdate: ((details) {
                  currentMousePos = details.globalPosition;
                }),
                onPanEnd: (details) {
                  Offset diff = currentMousePos - initMousePos;
                  if (diff.dx.abs() > diff.dy.abs()) {
                    widget.rotateX(i, diff.dx > 0);
                  } else {
                    widget.rotateY(j, diff.dy > 0);
                  }
                  widget.update();
                },
                child: Container(
                  width: widget.dim,
                  height: widget.dim,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade600,
                      width: widget.dim / 20,
                    ),
                    color: widget
                        .colors[widget.cube[widget.side]![i][j].side.hashCode],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
