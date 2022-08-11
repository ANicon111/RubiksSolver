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
  static List<RotData> fromIndex(int index) {
    switch (index) {
      case 0:
        return line;
      case 1:
        return circle;
      case 2:
        return triangle;
      default:
    }
    return [];
  }
}

class RubiksCube {
  final int size;
  Map<Side, List<List<Side>>> cube = {};

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

  void setLine(RotData data, int index, List<Side> line) {
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

  void rotate(List<RotData> rotation, int rotationIndex, bool reversed) {
    //get the lines
    List<List<Side>> lines = [];
    for (RotData sideData in reversed ? rotation.reversed : rotation) {
      lines.add(getLine(sideData, rotationIndex));
    }
    int i = 0;
    for (RotData sideData in reversed ? rotation.reversed : rotation) {
      i++;
      setLine(sideData, rotationIndex, lines[i % 4]);
    }
  }

  int cubeScore() {
    int cubeScore = 0;
    for (int i = 0; i < 6; i++) {
      List<int> sideScore = [0, 0, 0, 0, 0, 0];
      for (int j = 0; j < size; j++) {
        for (int k = 0; k < size; k++) {
          sideScore[cube[Side(i)]![j][k].hashCode]++;
        }
      }
      int most = 0;
      for (int i = 0; i < 6; i++) {
        if (most < sideScore[i]) most = sideScore[i];
      }
      cubeScore += most;
    }
    return cubeScore;
  }
}
