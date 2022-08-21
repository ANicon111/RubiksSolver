import 'package:rubikssolver/definitions.dart';
import 'package:rubikssolver/logic.dart';

class Move {
  final List<RotData> rotationList;
  final int index;
  final bool reversed;

  Move(this.rotationList, this.index, this.reversed);

  @override
  String toString() {
    String rotname = "";
    switch (rotationList) {
      case PossibleRotations.line:
        rotname = "line";
        break;
      case PossibleRotations.circle:
        rotname = "circle";
        break;
      case PossibleRotations.triangle:
        rotname = "triangle";
        break;
      default:
    }
    return "$rotname,$index,$reversed";
  }

  static Move fromInstruction(String instruction, int size) {
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
  static const bugDetectionLimit = 1000;
  RubiksCube cube;
  int step = 0;
  void rotate3x3ByNotation(String instructions) {
    cube.rotateFrom3x3Notation(instructions);
    instructions.split(" ").forEach((element) {
      moves.add(Move.fromInstruction(element, cube.size));
    });
  }

  void genericRotation(Move move) {
    cube.rotate(move.rotationList, move.index, move.reversed);
    moves.add(move);
  }

  //steps:
  //0-100 simplify to 3x3;
  //0 NxN top center
  void topCenterNxN() {
    //move pieces to the top
    int debug = 0;
    for (int i = 1; i < cube.size - 1; i++) {
      for (int j = 1; j < cube.size - 1; j++) {
        while (cube.piecePositions[Side.top]![i][j].side != Side.top ||
            cube.piecePositions[Side.top]![i][j].x != j ||
            cube.piecePositions[Side.top]![i][j].y != i) {
          PieceData pos = cube.piecePositions[Side.top]![i][j];
          if (debug < bugDetectionLimit * cube.size * cube.size) {
            debug++;
          } else {
            break;
          }
          //top algorithm
          if (pos.side == Side.top) {
            genericRotation(
                Move(PossibleRotations.triangle, cube.size - 1 - pos.x, true));
            genericRotation(Move(PossibleRotations.line, pos.y, true));
            genericRotation(
                Move(PossibleRotations.triangle, cube.size - 1 - pos.x, false));
          }
          //bottom algorithm
          else if (pos.side == Side.bottom) {
            genericRotation(
                Move(PossibleRotations.triangle, cube.size - 1 - pos.x, false));
            if (pos.x == pos.y &&
                pos.x == cube.size ~/ 2 &&
                cube.size % 2 == 1) {
              genericRotation(
                  Move(PossibleRotations.line, cube.size ~/ 2, false));
            } else {
              genericRotation(
                  Move(PossibleRotations.circle, cube.size - 1, false));
            }
            genericRotation(
                Move(PossibleRotations.triangle, cube.size - 1 - pos.x, true));
          }
          //generic side algorithm
          else if (pos.side != Side.left) {
            genericRotation(Move(PossibleRotations.line, pos.y, true));
          }
          //left algorithm
          else {
            if (cube.piecePositions[Side.top]![i][j].x != j ||
                cube.piecePositions[Side.top]![i][j].y != i) {
              genericRotation(
                  Move(PossibleRotations.triangle, cube.size - 1, false));
            } else {
              genericRotation(Move(
                  PossibleRotations.triangle, cube.size - 1 - pos.x, true));
              genericRotation(Move(PossibleRotations.line, pos.y, true));
              genericRotation(Move(
                  PossibleRotations.triangle, cube.size - 1 - pos.x, false));
            }
          }
        }
      }
    }
    //go to next step
    step = 1;
  }

  //1 NxN bottom center
  void bottomCenterNxN() {
    //move pieces to the bottom
    int debug = 0;
    for (int i = 1; i < cube.size - 1; i++) {
      for (int j = 1; j < cube.size - 1; j++) {
        while (cube.piecePositions[Side.bottom]![i][j].side != Side.bottom ||
            cube.piecePositions[Side.bottom]![i][j].x != j ||
            cube.piecePositions[Side.bottom]![i][j].y != i) {
          PieceData pos = cube.piecePositions[Side.bottom]![i][j];
          if (debug < bugDetectionLimit * cube.size * cube.size) {
            debug++;
          } else {
            break;
          }
          //bottom algorithm
          if (pos.side == Side.bottom) {
            genericRotation(
                Move(PossibleRotations.triangle, cube.size - 1 - pos.x, false));
            genericRotation(Move(PossibleRotations.circle, 0,
                ((pos.x >= cube.size ~/ 2) ^ (pos.y >= cube.size ~/ 2))));
            genericRotation(Move(PossibleRotations.line, pos.y, true));
            genericRotation(Move(PossibleRotations.circle, 0,
                !((pos.x >= cube.size ~/ 2) ^ (pos.y >= cube.size ~/ 2))));
            genericRotation(
                Move(PossibleRotations.triangle, cube.size - 1 - pos.x, true));
          }
          //generic side algorithm
          else if (pos.side != Side.left) {
            genericRotation(Move(PossibleRotations.line, pos.y, true));
          }
          //left algorithm
          else {
            if (pos.x != j || pos.y != i) {
              genericRotation(
                  Move(PossibleRotations.triangle, cube.size - 1, false));
            } else {
              genericRotation(Move(
                  PossibleRotations.triangle, cube.size - 1 - pos.x, false));
              genericRotation(Move(PossibleRotations.circle, 0,
                  ((pos.x >= cube.size ~/ 2) ^ (pos.y >= cube.size ~/ 2))));
              genericRotation(Move(PossibleRotations.line, pos.y, true));
              genericRotation(Move(PossibleRotations.circle, 0,
                  !((pos.x >= cube.size ~/ 2) ^ (pos.y >= cube.size ~/ 2))));
              genericRotation(Move(
                  PossibleRotations.triangle, cube.size - 1 - pos.x, true));
            }
          }
        }
      }
    }
    //go to next step
    step = 2;
  }

  //2 NxN left center
  void leftCenterNxN() {
    //move left pieces
    int debug = 0;
    for (int index = 0; index < 2; index++) {
      for (int i = 1; i < cube.size - 1; i++) {
        for (int j = 1; j < cube.size - 1; j++) {
          while (cube.piecePositions[Side.left]![i][j].side != Side.left ||
              cube.piecePositions[Side.left]![i][j].x != j ||
              cube.piecePositions[Side.left]![i][j].y != i) {
            PieceData pos = cube.piecePositions[Side.left]![i][j];
            if (debug < bugDetectionLimit * cube.size * cube.size) {
              debug++;
            } else {
              break;
            }
            if ((pos.y != j || pos.x != cube.size - 1 - i) &&
                pos.side != Side.left) {
              rotate3x3ByNotation(pos.side.toInstruction);
            } else if (pos.side == Side.left) {
              genericRotation(Move(PossibleRotations.line, pos.y, false));
              genericRotation(Move(PossibleRotations.line, pos.y, false));
            } else {
              List<Move> rememberedMoves = [];
              if (pos.side == Side.front && pos.y != i) {
                genericRotation(Move(PossibleRotations.line, pos.y, false));
                rememberedMoves.add(Move(PossibleRotations.line, pos.y, true));
              }
              genericRotation(Move(PossibleRotations.line, i, true));
              genericRotation(
                  Move(PossibleRotations.circle, cube.size - 1, true));
              while (cube.piecePositions[Side.left]![i][j].side != Side.front) {
                genericRotation(Move(PossibleRotations.line, pos.y, false));
                rememberedMoves.add(Move(PossibleRotations.line, pos.y, true));
              }
              if (cube.piecePositions[Side.left]![i][j].side == Side.front &&
                  (cube.piecePositions[Side.left]![i][j].y != j ||
                      cube.piecePositions[Side.left]![i][j].x !=
                          cube.size - 1 - i)) {
                genericRotation(Move(PossibleRotations.line,
                    cube.piecePositions[Side.left]![i][j].y, true));
                rememberedMoves.add(Move(PossibleRotations.line,
                    cube.piecePositions[Side.left]![i][j].y, false));
              }
              genericRotation(
                  Move(PossibleRotations.circle, cube.size - 1, false));
              genericRotation(Move(PossibleRotations.line, i, false));
              while (rememberedMoves.isNotEmpty) {
                genericRotation(rememberedMoves.removeLast());
              }
              while (cube.piecePositions[Side.left]![i][j].side != Side.left) {
                genericRotation(Move(PossibleRotations.line, pos.y, false));
              }
            }
          }
        }
      }
    }
    //go to next step
    step = 3;
  }

  //3 NxN front center
  void frontCenterNxN() {
    //move front pieces
    int debug = 0;
    for (int index = 0; index < 2; index++) {
      for (int i = 1; i < cube.size - 1; i++) {
        for (int j = 1; j < cube.size - 1; j++) {
          while (cube.piecePositions[Side.front]![i][j].side != Side.front ||
              cube.piecePositions[Side.front]![i][j].x != j ||
              cube.piecePositions[Side.front]![i][j].y != i) {
            PieceData pos = cube.piecePositions[Side.front]![i][j];
            if (debug < bugDetectionLimit * cube.size * cube.size) {
              debug++;
            } else {
              break;
            }
            if ((pos.y != j || pos.x != cube.size - 1 - i) &&
                pos.side != Side.front) {
              rotate3x3ByNotation(pos.side.toInstruction);
            } else if (pos.side == Side.front) {
              //TODO
            } else {
              List<Move> rememberedMoves = [];
              genericRotation(Move(PossibleRotations.line, i, true));
              genericRotation(Move(PossibleRotations.triangle, 0, false));
              //TODO
              genericRotation(Move(PossibleRotations.triangle, 0, true));
              genericRotation(Move(PossibleRotations.line, i, false));
              while (rememberedMoves.isNotEmpty) {
                genericRotation(rememberedMoves.removeLast());
              }
            }
          }
        }
      }
    }
    //go to next step
    step = 4;
  }

  //4 NxN side centers
  void rightCenterNxN() {
    //go to next step
    step = 5;
  }

  //5 NxN top sides
  void topSidesNxN() {
    //go to next step
    step = 6;
  }

  //6 NxN bottom sides
  void bottomSidesNxN() {
    //go to next step
    step = -1;
  }

  //100-200 solve 3x3
  //100 3x3 top plus
  void topCross3x3() {
    //align cube according to center if size is 3
    if (cube.size == 3) {
      Side topCenterPieceSide = Side.top;
      topCenterPieceSide = cube.piecePositions[Side.top]![1][1].side;
      if (topCenterPieceSide == Side.right) {
        for (int i = 0; i < cube.size; i++) {
          moves.add(Move(PossibleRotations.circle, i, false));
          cube.rotate(PossibleRotations.circle, i, false);
        }
      } else if (topCenterPieceSide == Side.bottom) {
        for (int i = 0; i < cube.size; i++) {
          moves.add(Move(PossibleRotations.circle, i, true));
          moves.add(Move(PossibleRotations.circle, i, true));
          cube.rotate(PossibleRotations.circle, i, true);
          cube.rotate(PossibleRotations.circle, i, true);
        }
      } else if (topCenterPieceSide == Side.left) {
        for (int i = 0; i < cube.size; i++) {
          moves.add(Move(PossibleRotations.circle, i, true));
          cube.rotate(PossibleRotations.circle, i, true);
        }
      } else if (topCenterPieceSide == Side.front) {
        for (int i = 0; i < cube.size; i++) {
          moves.add(Move(PossibleRotations.triangle, i, false));
          cube.rotate(PossibleRotations.triangle, i, false);
        }
      } else if (topCenterPieceSide == Side.back) {
        for (int i = 0; i < cube.size; i++) {
          moves.add(Move(PossibleRotations.triangle, i, true));
          cube.rotate(PossibleRotations.triangle, i, true);
        }
      }
      Side frontCenterPieceSide = cube.piecePositions[Side.front]![1][1].side;
      if (frontCenterPieceSide == Side.left) {
        for (int i = 0; i < cube.size; i++) {
          moves.add(Move(PossibleRotations.line, i, true));
          cube.rotate(PossibleRotations.line, i, true);
        }
      } else if (frontCenterPieceSide == Side.back) {
        for (int i = 0; i < cube.size; i++) {
          moves.add(Move(PossibleRotations.line, i, false));
          moves.add(Move(PossibleRotations.line, i, false));
          cube.rotate(PossibleRotations.line, i, false);
          cube.rotate(PossibleRotations.line, i, false);
        }
      } else if (frontCenterPieceSide == Side.right) {
        for (int i = 0; i < cube.size; i++) {
          moves.add(Move(PossibleRotations.line, i, false));
          cube.rotate(PossibleRotations.line, i, false);
        }
      }
    }
    //move all side top pieces
    List<List<int>> topSidePositions = [
      [1, 0],
      [cube.size - 1, 1],
      [cube.size - 2, cube.size - 1],
      [0, cube.size - 2]
    ];

    int debug = 0;
    for (int index = 0; index < 4; index++) {
      List<int> initPos = topSidePositions[index];
      while (cube.piecePositions[Side.top]![initPos[1]][initPos[0]].side !=
              Side.top ||
          cube.piecePositions[Side.top]![initPos[1]][initPos[0]].x !=
              initPos[0] ||
          cube.piecePositions[Side.top]![initPos[1]][initPos[0]].y !=
              initPos[1]) {
        PieceData pos = cube.piecePositions[Side.top]![initPos[1]][initPos[0]];
        if (debug < bugDetectionLimit) {
          debug++;
        } else {
          break;
        }
        //top algorithm
        if (pos.side == Side.top) {
          if (pos.x == 1 && pos.y == 0) {
            rotate3x3ByNotation("B B");
          }
          if (pos.x == cube.size - 1 && pos.y == 1) {
            rotate3x3ByNotation("R R");
          }
          if (pos.x == cube.size - 2 && pos.y == cube.size - 1) {
            rotate3x3ByNotation("F F");
          }
          if (pos.x == 0 && pos.y == cube.size - 2) {
            rotate3x3ByNotation("L L");
          }
        }
        //front algorithm
        if (pos.side == Side.front) {
          if (pos.x == 1 && pos.y == 0) {
            rotate3x3ByNotation("F");
          }
          if (pos.x == cube.size - 1 && pos.y == 1) {
            rotate3x3ByNotation("R' D R");
          }
          if (pos.x == cube.size - 2 && pos.y == cube.size - 1) {
            rotate3x3ByNotation("F' R' D R F");
          }
          if (pos.x == 0 && pos.y == cube.size - 2) {
            rotate3x3ByNotation("L D L'");
          }
        }
        //right algorithm
        if (pos.side == Side.right) {
          if (pos.x == 1 && pos.y == 0) {
            rotate3x3ByNotation("R");
          }
          if (pos.x == cube.size - 1 && pos.y == 1) {
            rotate3x3ByNotation("B' D B");
          }
          if (pos.x == cube.size - 2 && pos.y == cube.size - 1) {
            rotate3x3ByNotation("R' B' D' B R");
          }
          if (pos.x == 0 && pos.y == cube.size - 2) {
            rotate3x3ByNotation("F D F'");
          }
        }
        //back algorithm
        if (pos.side == Side.back) {
          if (pos.x == 1 && pos.y == 0) {
            rotate3x3ByNotation("B");
          }
          if (pos.x == cube.size - 1 && pos.y == 1) {
            rotate3x3ByNotation("L' D L");
          }
          if (pos.x == cube.size - 2 && pos.y == cube.size - 1) {
            rotate3x3ByNotation("B' L' D L B");
          }
          if (pos.x == 0 && pos.y == cube.size - 2) {
            rotate3x3ByNotation("R D R'");
          }
        }
        //left algorithm
        if (pos.side == Side.left) {
          if (pos.x == 1 && pos.y == 0) {
            rotate3x3ByNotation("L");
          }
          if (pos.x == cube.size - 1 && pos.y == 1) {
            rotate3x3ByNotation("F' D F");
          }
          if (pos.x == cube.size - 2 && pos.y == cube.size - 1) {
            rotate3x3ByNotation("L' F' D' F L");
          }
          if (pos.x == 0 && pos.y == cube.size - 2) {
            rotate3x3ByNotation("B D B'");
          }
        }
        //bottom algorithm
        if (pos.side == Side.bottom) {
          List<List<int>> bottomSidePositions = [
            [cube.size - 2, cube.size - 1],
            [cube.size - 1, 1],
            [1, 0],
            [0, cube.size - 2],
          ];
          if (pos.x != bottomSidePositions[index][0] ||
              pos.y != bottomSidePositions[index][1]) {
            rotate3x3ByNotation("D");
          } else {
            if (pos.x == 1 && pos.y == 0) {
              rotate3x3ByNotation("F F");
            }
            if (pos.x == cube.size - 1 && pos.y == 1) {
              rotate3x3ByNotation("R R");
            }
            if (pos.x == cube.size - 2 && pos.y == cube.size - 1) {
              rotate3x3ByNotation("B B");
            }
            if (pos.x == 0 && pos.y == cube.size - 2) {
              rotate3x3ByNotation("L L");
            }
          }
        }
      }
    }
    //go to next step
    step = 101;
  }

  //101 3x3 top corners
  void topCorners3x3() {
    //move the corners in place

    List<List<int>> topSidePositions = [
      [0, 0],
      [0, cube.size - 1],
      [cube.size - 1, cube.size - 1],
      [cube.size - 1, 0]
    ];
    int debug = 0;
    for (int index = 0; index < 4; index++) {
      List<int> initPos = topSidePositions[index];
      while (cube.piecePositions[Side.top]![initPos[1]][initPos[0]].side !=
              Side.top ||
          cube.piecePositions[Side.top]![initPos[1]][initPos[0]].x !=
              initPos[0] ||
          cube.piecePositions[Side.top]![initPos[1]][initPos[0]].y !=
              initPos[1]) {
        if (debug < bugDetectionLimit) {
          debug++;
        } else {
          break;
        }
        PieceData pos = cube.piecePositions[Side.top]![initPos[1]][initPos[0]];
        //top algorithm
        if (pos.side == Side.top) {
          if (pos.x == 0 && pos.y == 0) {
            rotate3x3ByNotation("L' D' L");
          }
          if (pos.x == cube.size - 1 && pos.y == 0) {
            rotate3x3ByNotation("B' D' B");
          }
          if (pos.x == cube.size - 1 && pos.y == cube.size - 1) {
            rotate3x3ByNotation("R' D' R");
          }
          if (pos.x == 0 && pos.y == cube.size - 1) {
            rotate3x3ByNotation("F' D' F");
          }
        }
        //front algorithm
        if (pos.side == Side.front) {
          if (pos.x == 0 && pos.y == 0) {
            rotate3x3ByNotation("F' D F");
          }
          if (pos.x == cube.size - 1 && pos.y == 0) {
            rotate3x3ByNotation("F D' F'");
          }
        }
        //right algorithm
        if (pos.side == Side.right) {
          if (pos.x == 0 && pos.y == 0) {
            rotate3x3ByNotation("R' D R");
          }
          if (pos.x == cube.size - 1 && pos.y == 0) {
            rotate3x3ByNotation("R D' R'");
          }
        }
        //back algorithm
        if (pos.side == Side.back) {
          if (pos.x == 0 && pos.y == 0) {
            rotate3x3ByNotation("B' D B");
          }
          if (pos.x == cube.size - 1 && pos.y == 0) {
            rotate3x3ByNotation("B D' B'");
          }
        }
        //left algorithm
        if (pos.side == Side.left) {
          if (pos.x == 0 && pos.y == 0) {
            rotate3x3ByNotation("L' D L");
          }
          if (pos.x == cube.size - 1 && pos.y == 0) {
            rotate3x3ByNotation("L D' L'");
          }
        }
        //individual corner algorithms
        if (pos.side != Side.top && pos.side != Side.bottom) {
          if (initPos[0] == 0 && initPos[1] == 0) {
            if (pos.x == 0 && pos.y == cube.size - 1) {
              if (pos.side == Side.front) {
                rotate3x3ByNotation("B D' B'");
              } else {
                rotate3x3ByNotation("D");
              }
            } else if (pos.x == cube.size - 1 && pos.y == cube.size - 1) {
              if (pos.side == Side.right) {
                rotate3x3ByNotation("L' D L");
              } else {
                rotate3x3ByNotation("D");
              }
            }
          } else if (initPos[0] == cube.size - 1 && initPos[1] == 0) {
            if (pos.x == 0 && pos.y == cube.size - 1) {
              if (pos.side == Side.left) {
                rotate3x3ByNotation("R D' R'");
              } else {
                rotate3x3ByNotation("D");
              }
            } else if (pos.x == cube.size - 1 && pos.y == cube.size - 1) {
              if (pos.side == Side.front) {
                rotate3x3ByNotation("B' D B");
              } else {
                rotate3x3ByNotation("D");
              }
            }
          } else if (initPos[0] == cube.size - 1 &&
              initPos[1] == cube.size - 1) {
            if (pos.x == 0 && pos.y == cube.size - 1) {
              if (pos.side == Side.back) {
                rotate3x3ByNotation("F D' F'");
              } else {
                rotate3x3ByNotation("D");
              }
            } else if (pos.x == cube.size - 1 && pos.y == cube.size - 1) {
              if (pos.side == Side.left) {
                rotate3x3ByNotation("R' D R");
              } else {
                rotate3x3ByNotation("D");
              }
            }
          } else if (initPos[0] == 0 && initPos[1] == cube.size - 1) {
            if (pos.x == 0 && pos.y == cube.size - 1) {
              if (pos.side == Side.right) {
                rotate3x3ByNotation("L D' L'");
              } else {
                rotate3x3ByNotation("D");
              }
            } else if (pos.x == cube.size - 1 && pos.y == cube.size - 1) {
              if (pos.side == Side.back) {
                rotate3x3ByNotation("F' D F");
              } else {
                rotate3x3ByNotation("D");
              }
            }
          }
        }
        //bottom algorithm
        if (pos.side == Side.bottom) {
          if (pos.x == 0 && pos.y == 0) {
            if (cube.cube[Side.top]![cube.size - 1][0].side == Side.top) {
              rotate3x3ByNotation("D");
            } else {
              rotate3x3ByNotation("F' D F");
            }
          } else if (pos.x == 0 && pos.y == cube.size - 1) {
            if (cube.cube[Side.top]![0][0].side == Side.top) {
              rotate3x3ByNotation("D");
            } else {
              rotate3x3ByNotation("L' D L");
            }
          } else if (pos.x == cube.size - 1 && pos.y == cube.size - 1) {
            if (cube.cube[Side.top]![0][cube.size - 1].side == Side.top) {
              rotate3x3ByNotation("D");
            } else {
              rotate3x3ByNotation("B' D B");
            }
          } else if (pos.x == cube.size - 1 && pos.y == 0) {
            if (cube.cube[Side.top]![cube.size - 1][cube.size - 1].side ==
                Side.top) {
              rotate3x3ByNotation("D");
            } else {
              rotate3x3ByNotation("R' D R");
            }
          }
        }
      }
    }
    //go to next step
    step = 102;
  }

  //102 3x3 sides middle
  void sideMiddleEdges3x3() {
    //moving the sides
    int debug = 0;
    const List<Side> sides = [
      Side.left,
      Side.front,
      Side.right,
      Side.back,
      Side.left
    ];
    for (Side side in sides) {
      for (List<int> initPos in [
        [0, 1],
        [cube.size - 1, cube.size - 2]
      ]) {
        while (
            cube.piecePositions[side]![initPos[1]][initPos[0]].side != side ||
                cube.piecePositions[side]![initPos[1]][initPos[0]].x !=
                    initPos[0] ||
                cube.piecePositions[side]![initPos[1]][initPos[0]].y !=
                    initPos[1]) {
          if (debug < bugDetectionLimit) {
            debug++;
          } else {
            break;
          }
          PieceData pos = cube.piecePositions[side]![initPos[1]][initPos[0]];
          if (pos.side == Side.bottom) break;
          //get side instruction
          String i1 = pos.side.toInstruction;
          if (pos.x == 0 && pos.y == 1) {
            int currentIndex = sides.lastIndexOf(pos.side);
            String i2 = sides[(currentIndex - 1) % 4].toInstruction;
            rotate3x3ByNotation("D $i2 D' $i2' D' $i1' D $i1");
          } else if (pos.x == cube.size - 1 && pos.y == cube.size - 2) {
            int currentIndex = sides.lastIndexOf(pos.side);
            String i2 = sides[(currentIndex + 1) % 4].toInstruction;
            rotate3x3ByNotation("D' $i2' D $i2 D $i1 D' $i1'");
          } else if (pos.side != side) {
            rotate3x3ByNotation("D");
          } else if (initPos[0] == 0 && initPos[1] == 1) {
            int currentIndex = sides.lastIndexOf(pos.side);
            String i2 = sides[(currentIndex - 1) % 4].toInstruction;
            rotate3x3ByNotation("D $i2 D' $i2' D' $i1' D $i1");
          } else {
            int currentIndex = sides.lastIndexOf(pos.side);
            String i2 = sides[(currentIndex + 1) % 4].toInstruction;
            rotate3x3ByNotation("D' $i2' D $i2 D $i1 D' $i1'");
          }
        }
      }
    }
    //go to next step
    step = 103;
  }

  //103 3x3 bottom plus
  void bottomPlus3x3() {
    //align the already existing bottom pieces
    int alignedEdges() {
      int alignedEdges = 0;

      for (List<int> pos in [
        [1, 0],
        [cube.size - 1, 1],
        [cube.size - 2, cube.size - 1],
        [0, cube.size - 2]
      ]) {
        if (cube.cube[Side.bottom]![pos[1]][pos[0]].side == Side.bottom) {
          alignedEdges++;
        }
      }
      return alignedEdges;
    }

    int debug = 0;
    for (int progress = alignedEdges();
        progress < 4;
        progress = alignedEdges()) {
      if (debug < 100) {
        debug++;
      } else {
        break;
      }
      if (progress == 2) {
        if (!(cube.cube[Side.bottom]![1][cube.size - 1].side == Side.bottom &&
            (cube.cube[Side.bottom]![cube.size - 1][cube.size - 2].side ==
                    Side.bottom ||
                cube.cube[Side.bottom]![cube.size - 2][0].side ==
                    Side.bottom))) {
          rotate3x3ByNotation("D");
        }
      }
      rotate3x3ByNotation("F D L D' L' F'");
    }

    //go to next step
    step = 104;
  }

  //104 3x3 bottom edges
  void bottomEdgesAlignment3x3() {
    //align left side
    int debug = 0;
    while (cube.piecePositions[Side.front]![cube.size - 1][1].side !=
            Side.front ||
        cube.piecePositions[Side.right]![cube.size - 1][1].side != Side.right ||
        cube.piecePositions[Side.left]![cube.size - 1][1].side != Side.left) {
      if (debug < bugDetectionLimit) {
        debug++;
      } else {
        break;
      }
      while (
          cube.piecePositions[Side.left]![cube.size - 1][1].side != Side.left) {
        if (debug < bugDetectionLimit) {
          debug++;
        } else {
          break;
        }
        rotate3x3ByNotation("D");
      }
      if (cube.piecePositions[Side.front]![cube.size - 1][1].side ==
          Side.right) {
        rotate3x3ByNotation("F D F' D F D D F' D D");
      }
      if (cube.piecePositions[Side.front]![cube.size - 1][1].side ==
          Side.back) {
        rotate3x3ByNotation("B D B' D B D D B'");
      }
      if (cube.piecePositions[Side.right]![cube.size - 1][1].side ==
          Side.back) {
        rotate3x3ByNotation("B D B' D B D D B'");
      }
    }
    //go to next step
    step = 105;
  }

  //105 3x3 bottom corners
  void bottomCorners3x3() {
    //corner validator algorithm
    bool cornerValidator(int index) {
      switch (index) {
        case 0:
          List<Side> leftFrontBottomCorner = [
            cube.cube[Side.left]![cube.size - 1][cube.size - 1].side,
            cube.cube[Side.front]![cube.size - 1][0].side,
            cube.cube[Side.bottom]![0][0].side
          ];
          return leftFrontBottomCorner.contains(Side.front) &&
              leftFrontBottomCorner.contains(Side.left) &&
              leftFrontBottomCorner.contains(Side.bottom);
        case 1:
          List<Side> frontRightBottomCorner = [
            cube.cube[Side.front]![cube.size - 1][cube.size - 1].side,
            cube.cube[Side.right]![cube.size - 1][0].side,
            cube.cube[Side.bottom]![0][cube.size - 1].side
          ];
          return frontRightBottomCorner.contains(Side.front) &&
              frontRightBottomCorner.contains(Side.right) &&
              frontRightBottomCorner.contains(Side.bottom);
        case 2:
          List<Side> rightBackBottomCorner = [
            cube.cube[Side.right]![cube.size - 1][cube.size - 1].side,
            cube.cube[Side.back]![cube.size - 1][0].side,
            cube.cube[Side.bottom]![cube.size - 1][cube.size - 1].side
          ];
          return rightBackBottomCorner.contains(Side.back) &&
              rightBackBottomCorner.contains(Side.right) &&
              rightBackBottomCorner.contains(Side.bottom);
        case 3:
          List<Side> backLeftBottomCorner = [
            cube.cube[Side.left]![cube.size - 1][0].side,
            cube.cube[Side.back]![cube.size - 1][cube.size - 1].side,
            cube.cube[Side.bottom]![cube.size - 1][0].side
          ];
          return backLeftBottomCorner.contains(Side.back) &&
              backLeftBottomCorner.contains(Side.left) &&
              backLeftBottomCorner.contains(Side.bottom);
        default:
          return false;
      }
    }

    //get valid corner
    int validCorner = -1;
    while (validCorner == -1) {
      for (int i = 0; i < 4; i++) {
        if (cornerValidator(i)) {
          validCorner = i;
          break;
        }
      }
      if (validCorner != -1) break;
      rotate3x3ByNotation("D R D' L' D R' D' L");
    }
    //rotate other corners until valid
    List<String> algorithms = [
      "D L D' R' D L' D' R",
      "D F D' B' D F' D' B",
      "D R D' L' D R' D' L",
      "D B D' F' D B' D' F",
    ];
    int debug = 0;
    while (!cornerValidator((validCorner + 1) % 4)) {
      if (debug < bugDetectionLimit) {
        debug++;
      } else {
        break;
      }
      rotate3x3ByNotation(algorithms[validCorner]);
    }
    //L' U L U'
    debug = 0;
    for (int i = 0; i < 4; i++) {
      while (cube.cube[Side.bottom]![0][0].side != Side.bottom) {
        if (debug < bugDetectionLimit) {
          debug++;
        } else {
          break;
        }
        rotate3x3ByNotation("L' U L U'");
      }
      rotate3x3ByNotation("D");
    }
    //end the 3x3 algorithm
    step = -1;
  }

  //200 solve 2x2
  void solve2x2() {
    topCorners3x3();
    bottomCorners3x3();
    //end the algorithm
    step = -1;
  }

  //-1 done;
  List<Move> moves = [];

  Algorithm(this.cube) {
    switch (cube.size) {
      case 1:
        step = -1;
        break;
      case 2:
        step = 200;
        break;
      case 3:
        step = 100;
        break;
      default:
    }
    final Map<int, void Function()> functions = {
      0: topCenterNxN,
      1: bottomCenterNxN,
      2: leftCenterNxN,
      3: frontCenterNxN,
      4: rightCenterNxN,
      5: topSidesNxN,
      6: bottomSidesNxN,
      100: topCross3x3,
      101: topCorners3x3,
      102: sideMiddleEdges3x3,
      103: bottomPlus3x3,
      104: bottomEdgesAlignment3x3,
      105: bottomCorners3x3,
      200: solve2x2,
    };
    while (step != -1) {
      functions[step]!();
    }
  }
}
