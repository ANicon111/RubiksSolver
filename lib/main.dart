import 'package:flutter/material.dart';
import 'package:rubikssolver/ai.dart';
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
  RubiksCube cube = RubiksCube(2);
  List<Color> colors = [
    Colors.black,
    Colors.amber,
    Colors.red,
    Colors.purple,
    Colors.lime,
    Colors.cyan,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 1080 * RelSize(context).pixel,
          height: 810 * RelSize(context).pixel,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  List<AIMove> kekw = AI(cube, 12 ~/ cube.size).dfs();
                  for (AIMove move in kekw) {
                    cube.rotate(move.rotationList, move.index, move.reversed);
                  }
                  setState(() {});
                },
                child: Text(cube.cubeScore().toString()),
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
                  cube.rotate(PossibleRotations.line, index, direction);
                },
                rotateY: (int index, bool direction) {
                  cube.rotate(PossibleRotations.triangle, index, !direction);
                },
                cube: cube.cube,
                side: Side.back,
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
                  cube.rotate(PossibleRotations.line, index, direction);
                },
                rotateY: (int index, bool direction) {
                  cube.rotate(PossibleRotations.circle, index, !direction);
                },
                cube: cube.cube,
                side: Side.left,
                colors: colors,
              ),
              CubeFace(
                top: 0 * RelSize(context).pixel,
                left: 540 * RelSize(context).pixel,
                dim: 270 * RelSize(context).pixel / cube.size,
                size: cube.size,
                update: () {
                  setState(() {});
                },
                rotateX: (int index, bool direction) {
                  cube.rotate(PossibleRotations.circle, index, direction);
                },
                rotateY: (int index, bool direction) {
                  cube.rotate(PossibleRotations.triangle, cube.size - 1 - index,
                      direction);
                },
                cube: cube.cube,
                side: Side.top,
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
                  cube.rotate(PossibleRotations.line, index, direction);
                },
                rotateY: (int index, bool direction) {
                  cube.rotate(PossibleRotations.triangle, cube.size - 1 - index,
                      direction);
                },
                cube: cube.cube,
                side: Side.front,
                colors: colors,
              ),
              CubeFace(
                top: 540 * RelSize(context).pixel,
                left: 540 * RelSize(context).pixel,
                dim: 270 * RelSize(context).pixel / cube.size,
                size: cube.size,
                update: () {
                  setState(() {});
                },
                rotateX: (int index, bool direction) {
                  cube.rotate(PossibleRotations.circle, cube.size - 1 - index,
                      direction);
                },
                rotateY: (int index, bool direction) {
                  cube.rotate(PossibleRotations.triangle, cube.size - 1 - index,
                      direction);
                },
                cube: cube.cube,
                side: Side.bottom,
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
                  cube.rotate(PossibleRotations.line, index, direction);
                },
                rotateY: (int index, bool direction) {
                  cube.rotate(PossibleRotations.circle, cube.size - 1 - index,
                      direction);
                },
                cube: cube.cube,
                side: Side.right,
                colors: colors,
              ),
            ],
          ),
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
  final Map<Side, List<List<Side>>> cube;
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
                    color:
                        widget.colors[widget.cube[widget.side]![i][j].hashCode],
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
