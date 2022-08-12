import 'package:rubikssolver/definitions.dart';

class PossibleRotations {
  //names are based on the 2d projection of a cube
  //     ■
  //-■-■-■-■-
  //     ■
  static final List<RotData> line = [
    RotData(Side.front, Direction.top),
    RotData(Side.right, Direction.top),
    RotData(Side.back, Direction.top),
    RotData(Side.left, Direction.top),
  ];
  //   /-■-\
  // ■ ■ ■ ■
  //   \-■-/
  static final List<RotData> circle = [
    RotData(Side.top, Direction.top),
    RotData(Side.right, Direction.right),
    RotData(Side.bottom, Direction.bottom),
    RotData(Side.left, Direction.left),
  ];
  //  /--■
  // ■ ■ ■ ■
  //  \--■
  static final List<RotData> triangle = [
    RotData(Side.top, Direction.right),
    RotData(Side.front, Direction.right),
    RotData(Side.bottom, Direction.right),
    RotData(Side.back, Direction.left),
  ];
  static final List<List<RotData>> toList = [
    line,
    circle,
    triangle,
  ];

  static const List<String> instructionNames = [
    "F",
    "R",
    "U",
    "B",
    "L",
    "D",
    "F'",
    "R'",
    "U'",
    "B'",
    "L'",
    "D'"
  ];
}

class RubiksCube {
  final int size;
  Map<Side, List<List<Side>>> cube = {};

  RubiksCube get carbonCopy {
    RubiksCube newCube = RubiksCube(size);
    newCube.cube = {
      Side.front: List.generate(
          size, (i) => List.generate(size, (j) => cube[Side.front]![i][j])),
      Side.top: List.generate(
          size, (i) => List.generate(size, (j) => cube[Side.top]![i][j])),
      Side.left: List.generate(
          size, (i) => List.generate(size, (j) => cube[Side.left]![i][j])),
      Side.back: List.generate(
          size, (i) => List.generate(size, (j) => cube[Side.back]![i][j])),
      Side.bottom: List.generate(
          size, (i) => List.generate(size, (j) => cube[Side.bottom]![i][j])),
      Side.right: List.generate(
          size, (i) => List.generate(size, (j) => cube[Side.right]![i][j])),
    };
    return newCube;
  }

  RubiksCube(
    this.size,
  ) {
    cube = {
      Side.front:
          List.generate(size, (_) => List.generate(size, (_) => Side.front)),
      Side.top:
          List.generate(size, (_) => List.generate(size, (_) => Side.top)),
      Side.left:
          List.generate(size, (_) => List.generate(size, (_) => Side.left)),
      Side.back:
          List.generate(size, (_) => List.generate(size, (_) => Side.back)),
      Side.bottom:
          List.generate(size, (_) => List.generate(size, (_) => Side.bottom)),
      Side.right:
          List.generate(size, (_) => List.generate(size, (_) => Side.right)),
    };
  }
  List<Side> getLine(RotData data, int index) {
    List<Side> line = [];
    switch (data.startingDirection.hashCode) {
      case 0:
        for (int i = 0; i < size; i++) {
          line.add(cube[data.side]![index][i]);
        }
        break;
      case 1:
        for (int i = 0; i < size; i++) {
          line.add(cube[data.side]![i][size - 1 - index]);
        }
        break;
      case 2:
        for (int i = 0; i < size; i++) {
          line.add(cube[data.side]![size - 1 - index][size - 1 - i]);
        }
        break;
      case 3:
        for (int i = 0; i < size; i++) {
          line.add(cube[data.side]![size - 1 - i][index]);
        }
        break;
      default:
    }
    return line;
  }

  void _setLine(RotData data, int index, List<Side> line) {
    switch (data.startingDirection.hashCode) {
      case 0:
        for (int i = 0; i < size; i++) {
          cube[data.side]![index][i] = line[i];
        }
        break;
      case 1:
        for (int i = 0; i < size; i++) {
          cube[data.side]![i][size - 1 - index] = line[i];
        }
        break;
      case 2:
        for (int i = 0; i < size; i++) {
          cube[data.side]![size - 1 - index][size - 1 - i] = line[i];
        }
        break;
      case 3:
        for (int i = 0; i < size; i++) {
          cube[data.side]![size - 1 - i][index] = line[i];
        }
        break;
      default:
    }
  }

  void _rotateSide(Side side, bool reversed) {
    List<List<Side>> faceCopy =
        List.generate(size, (_) => List.generate(size, (_) => Side(0)));
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        faceCopy[i][j] = cube[side]![i][j];
      }
    }
    if (!reversed) {
      for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
          cube[side]![i][j] = faceCopy[size - 1 - j][i];
        }
      }
    } else {
      for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
          cube[side]![i][j] = faceCopy[j][size - 1 - i];
        }
      }
    }
  }

  void rotate(List<RotData> rotation, int rotationIndex, bool reversed) {
    //get the lines
    List<List<Side>> lines = [];
    for (RotData sideData in reversed ? rotation.reversed : rotation) {
      lines.add(getLine(sideData, rotationIndex));
    }
    int i = 0;
    for (RotData sideData in reversed ? rotation.reversed : rotation) {
      i++;
      _setLine(sideData, rotationIndex, lines[i % 4]);
    }
    if (rotationIndex == 0 || rotationIndex == size - 1) {
      if (rotation == PossibleRotations.line) {
        if (rotationIndex == 0) {
          _rotateSide(Side.top, reversed);
        } else {
          _rotateSide(Side.bottom, !reversed);
        }
      }
      if (rotation == PossibleRotations.circle) {
        if (rotationIndex == 0) {
          _rotateSide(Side.back, reversed);
        } else {
          _rotateSide(Side.front, !reversed);
        }
      }
      if (rotation == PossibleRotations.triangle) {
        if (rotationIndex == 0) {
          _rotateSide(Side.right, reversed);
        } else {
          _rotateSide(Side.left, !reversed);
        }
      }
    }
  }

  void rotateFrom3x3Notation(String instructions) {
    List<String> instructionList = instructions.split(" ");
    for (String instruction in instructionList) {
      switch (instruction) {
        case "F":
          rotate(PossibleRotations.circle, size - 1, true);
          break;
        case "R":
          rotate(PossibleRotations.triangle, 0, false);
          break;
        case "U":
          rotate(PossibleRotations.line, 0, false);
          break;
        case "B":
          rotate(PossibleRotations.circle, 0, false);
          break;
        case "L":
          rotate(PossibleRotations.triangle, size - 1, true);
          break;
        case "D":
          rotate(PossibleRotations.line, size - 1, true);
          break;
        case "F'":
          rotate(PossibleRotations.circle, size - 1, false);
          break;
        case "R'":
          rotate(PossibleRotations.triangle, 0, true);
          break;
        case "U'":
          rotate(PossibleRotations.line, 0, true);
          break;
        case "B'":
          rotate(PossibleRotations.circle, 0, true);
          break;
        case "L'":
          rotate(PossibleRotations.triangle, size - 1, false);
          break;
        case "D'":
          rotate(PossibleRotations.line, size - 1, false);
          break;
        default:
      }
    }
  }
}
