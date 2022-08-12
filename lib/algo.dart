import 'package:rubikssolver/definitions.dart';
import 'package:rubikssolver/logic.dart';

class Move {
  final List<RotData> rotationList;
  final int index;
  final bool reversed;

  Move(this.rotationList, this.index, this.reversed);

  Move fromInstruction(String instruction, int size) {
    switch (instruction) {
      case "F":
        return Move(PossibleRotations.circle, size - 1, true);
      case "R":
        return Move(PossibleRotations.triangle, 0, false);
      case "U":
        return Move(PossibleRotations.line, 0, false);
      case "B":
        return Move(PossibleRotations.circle, 0, false);
      case "L":
        return Move(PossibleRotations.triangle, size - 1, true);
      case "D":
        return Move(PossibleRotations.line, size - 1, true);
      case "F'":
        return Move(PossibleRotations.circle, size - 1, false);
      case "R'":
        return Move(PossibleRotations.triangle, 0, true);
      case "U'":
        return Move(PossibleRotations.line, 0, true);
      case "B'":
        return Move(PossibleRotations.circle, 0, true);
      case "L'":
        return Move(PossibleRotations.triangle, size - 1, false);
      case "D'":
        return Move(PossibleRotations.line, size - 1, false);
      default:
        throw "Invalid instruction";
    }
  }
}

class Algorithm {
  RubiksCube cube;
  int step = 0;
  //steps:
  //0-100 simplify to 3x3;

  //100-200 solve 3x3
  //100 3x3 make a plus
  void step100() {
    //move center pieces to their respective sides
    Side topCenterPieceSide = Side.top;
    for (int i = 0; i < 6; i++) {
      if (cube.cube[Side(i)]![1][1] == Side.top) {
        topCenterPieceSide = Side(i);
      }
    }
    if (topCenterPieceSide == Side.right) {
      for (int i = 1; i < cube.size - 1; i++) {
        moves.add(Move(PossibleRotations.circle, i, false));
        cube.rotate(PossibleRotations.circle, i, false);
      }
    } else if (topCenterPieceSide == Side.bottom) {
      for (int i = 1; i < cube.size - 1; i++) {
        moves.add(Move(PossibleRotations.circle, i, true));
        moves.add(Move(PossibleRotations.circle, i, true));
        cube.rotate(PossibleRotations.circle, i, true);
        cube.rotate(PossibleRotations.circle, i, true);
      }
    } else if (topCenterPieceSide == Side.left) {
      for (int i = 1; i < cube.size - 1; i++) {
        moves.add(Move(PossibleRotations.circle, i, true));
        cube.rotate(PossibleRotations.circle, i, true);
      }
    } else if (topCenterPieceSide == Side.front) {
      for (int i = 1; i < cube.size - 1; i++) {
        moves.add(Move(PossibleRotations.triangle, i, false));
        cube.rotate(PossibleRotations.triangle, i, false);
      }
    } else if (topCenterPieceSide == Side.back) {
      for (int i = 1; i < cube.size - 1; i++) {
        moves.add(Move(PossibleRotations.triangle, i, true));
        cube.rotate(PossibleRotations.triangle, i, true);
      }
    }
    Side frontCenterPieceSide = Side.front;
    for (int i = 0; i < 6; i++) {
      if (cube.cube[Side(i)]![1][1] == Side.front) {
        frontCenterPieceSide = Side(i);
      }
    }
    if (frontCenterPieceSide == Side.left) {
      for (int i = 1; i < cube.size - 1; i++) {
        moves.add(Move(PossibleRotations.line, i, true));
        cube.rotate(PossibleRotations.line, i, true);
      }
    } else if (frontCenterPieceSide == Side.back) {
      for (int i = 1; i < cube.size - 1; i++) {
        moves.add(Move(PossibleRotations.line, i, false));
        moves.add(Move(PossibleRotations.line, i, false));
        cube.rotate(PossibleRotations.line, i, false);
        cube.rotate(PossibleRotations.line, i, false);
      }
    } else if (frontCenterPieceSide == Side.right) {
      for (int i = 1; i < cube.size - 1; i++) {
        moves.add(Move(PossibleRotations.line, i, false));
        cube.rotate(PossibleRotations.line, i, false);
      }
    }
    //find all side top pieces
    Direction trd, tld, tfd, tbd;
    Side trs, tls, tfs, tbs;
    for (List<RotData> rotation in PossibleRotations.toList) {
      for (int i = 0; i < 4; i++) {
        for (int j in [0, cube.size - 1]) {}
      }
    }
    //move them

    //go to next step
    step = -1;
  }
  //101 3x3 corners

  //102 3x3 middle

  //103 3x3 second plus

  //104 3x3 edges

  //105 3x3 corners

  //-1 done;
  List<Move> moves = [];
  Algorithm(this.cube) {
    if (cube.size == 3) {
      step = 100;
    }
    while (step != -1) {
      switch (step) {
        case 100:
          step100();
          break;
        default:
      }
    }
  }
}
