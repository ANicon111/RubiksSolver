import 'package:flutter/foundation.dart';
import 'package:rubikssolver/definitions.dart';
import 'package:rubikssolver/logic.dart';

class Move {
  final List<RotData> rotationList;
  final int index;
  final bool isReversed;

  Move(this.rotationList, this.index, this.isReversed);

  Move get reversed {
    return Move(rotationList, index, !isReversed);
  }

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
    return "$rotname,$index,$isReversed";
  }

  static Move fromInstruction(String value, int size) {
    String instruction = value[value.length - 1];
    if (instruction == "'") {
      instruction = value.substring(value.length - 2);
    }
    value = value.split(instruction)[0];
    int index = int.tryParse(value) ?? 0;
    switch (instruction) {
      case "F":
        return Move(PossibleRotations.circle, size - 1 - index, true);
      case "R":
        return Move(PossibleRotations.triangle, 0 + index, false);
      case "U":
        return Move(PossibleRotations.line, 0 + index, false);
      case "B":
        return Move(PossibleRotations.circle, 0 + index, false);
      case "L":
        return Move(PossibleRotations.triangle, size - 1 - index, true);
      case "D":
        return Move(PossibleRotations.line, size - 1 - index, true);
      case "F'":
        return Move(PossibleRotations.circle, size - 1 - index, false);
      case "R'":
        return Move(PossibleRotations.triangle, 0 + index, true);
      case "U'":
        return Move(PossibleRotations.line, 0 + index, true);
      case "B'":
        return Move(PossibleRotations.circle, 0 + index, true);
      case "L'":
        return Move(PossibleRotations.triangle, size - 1 - index, false);
      case "D'":
        return Move(PossibleRotations.line, size - 1 - index, false);
      default:
    }
    return Move(PossibleRotations.circle, index, false);
  }
}

class Algorithm {
  static const bugDetectionLimit = 1000;
  RubiksCube cube;
  int step = 0;
  void rotateByNotation(String instructions) {
    if (kDebugMode) {
      print(instructions);
    }
    cube.rotateFrom3x3Notation(instructions);
    instructions.split(" ").forEach((element) {
      moves.add(Move.fromInstruction(element, cube.size));
    });
  }

  void genericRotation(Move move) {
    cube.rotate(move.rotationList, move.index, move.isReversed, true);
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
              rotateByNotation(pos.side.toInstruction);
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
          void flipFR(bool reversed) {
            genericRotation(Move(PossibleRotations.triangle, 0, !reversed));
            genericRotation(Move(PossibleRotations.line, pos.y, false));
            genericRotation(
                Move(PossibleRotations.circle, cube.size - 1, reversed));
            genericRotation(Move(PossibleRotations.line,
                reversed ? pos.x : cube.size - 1 - pos.x, false));
            genericRotation(
                Move(PossibleRotations.circle, cube.size - 1, !reversed));
            genericRotation(Move(PossibleRotations.line, pos.y, true));
            genericRotation(
                Move(PossibleRotations.circle, cube.size - 1, reversed));
            genericRotation(Move(PossibleRotations.line,
                reversed ? pos.x : cube.size - 1 - pos.x, true));
            genericRotation(
                Move(PossibleRotations.circle, cube.size - 1, !reversed));
            genericRotation(Move(PossibleRotations.triangle, 0, reversed));
          }

          if (pos.side == Side.right) {
            if ((pos.y != i || pos.x != j)) {
              rotateByNotation("R");
            } else {
              while (cube.piecePositions[Side.front]![i][j].toString() !=
                  PieceData(Side.front, i, j).toString()) {
                flipFR(pos.x != pos.y);
              }
            }
          } else if (pos.side == Side.front) {
            while (cube.piecePositions[Side.front]![i][j].side == Side.front) {
              flipFR(pos.x != pos.y);
            }
          } else {
            genericRotation(Move(PossibleRotations.line, pos.y, false));
            while (cube.piecePositions[Side.front]![i][j].y == pos.y) {
              genericRotation(Move(PossibleRotations.triangle, 0, false));
            }
            genericRotation(Move(PossibleRotations.line, pos.y, true));
          }
        }
      }
    }
    //go to next step
    step = 4;
  }

  //4 NxN right and back centers
  void rightAndBackCentersNxN() {
    //switch their places until done
    int debug = 0;
    for (int i = 1; i < cube.size - 1; i++) {
      for (int j = 1; j < cube.size - 1; j++) {
        while (cube.piecePositions[Side.right]![i][j].side != Side.right ||
            cube.piecePositions[Side.right]![i][j].x != j ||
            cube.piecePositions[Side.right]![i][j].y != i) {
          PieceData pos = cube.piecePositions[Side.right]![i][j];
          if (debug < bugDetectionLimit * cube.size * cube.size) {
            debug++;
          } else {
            break;
          }
          void flipRB(bool reversed) {
            genericRotation(Move(PossibleRotations.circle, 0, !reversed));
            genericRotation(Move(PossibleRotations.line, pos.y, false));
            genericRotation(Move(PossibleRotations.triangle, 0, !reversed));
            genericRotation(Move(PossibleRotations.line,
                reversed ? pos.x : cube.size - 1 - pos.x, false));
            genericRotation(Move(PossibleRotations.triangle, 0, reversed));
            genericRotation(Move(PossibleRotations.line, pos.y, true));
            genericRotation(Move(PossibleRotations.triangle, 0, !reversed));
            genericRotation(Move(PossibleRotations.line,
                reversed ? pos.x : cube.size - 1 - pos.x, true));
            genericRotation(Move(PossibleRotations.triangle, 0, reversed));
            genericRotation(Move(PossibleRotations.circle, 0, reversed));
          }

          if (pos.side == Side.back) {
            if ((pos.y != i || pos.x != j)) {
              rotateByNotation("B");
            } else {
              while (cube.piecePositions[Side.right]![i][j].toString() !=
                  PieceData(Side.right, i, j).toString()) {
                flipRB(pos.x != pos.y);
              }
            }
          } else if (pos.side == Side.right) {
            while (cube.piecePositions[Side.right]![i][j].side == Side.right) {
              flipRB(pos.x != pos.y);
            }
          }
        }
      }
    }
    //go to next step
    step = 5;
  }

  //String getCycle(PieceData initPos) {}

  //5 NxN top sides
  void topSidesNxN() {
    List<List<int>> sides = [
      [0, 1],
      [1, 0],
      [cube.size - 1, 1],
      [1, cube.size - 1],
    ];
    int debug = 0;
    List<Move> rememberedMoves = [];
    for (int index = 0; index < cube.size - 2; index++) {
      for (List<int> sidePos in sides) {
        int j = sidePos[0] == 1 ? sidePos[0] + index : sidePos[0];
        int i = sidePos[1] == 1 ? sidePos[1] + index : sidePos[1];
        while (cube.piecePositions[Side.top]![i][j].side != Side.top ||
            cube.piecePositions[Side.top]![i][j].x != j ||
            cube.piecePositions[Side.top]![i][j].y != i) {
          PieceData pos = cube.piecePositions[Side.top]![i][j];
          if (debug < bugDetectionLimit * cube.size * cube.size) {
            debug++;
          } else {
            break;
          }
          //bottom algorithm
          if (pos.side == Side.bottom) {
            if (pos.x != 0) {
              rotateByNotation("D");
              rememberedMoves.add(Move.fromInstruction("D'", cube.size));
            } else {
              rotateByNotation("F' L' F' L F");
            }
          }
          //top algorithm
          else if (pos.side == Side.top) {
            while (cube.piecePositions[Side.top]![i][j].y != cube.size - 1) {
              rotateByNotation("U");
            }
            rotateByNotation(
                "${cube.piecePositions[Side.top]![i][j].x}L' F' L' F ${cube.piecePositions[Side.top]![i][j].x}L F' L F");
            while (cube.piecePositions[Side.top]![1][1].x != 1 ||
                cube.piecePositions[Side.top]![1][1].y != 1) {
              rotateByNotation("U");
            }
          }
          //side algorithm
          else if (pos.side != Side.front) {
            if (cube.piecePositions[Side.top]![i][j].y == 0) {
              while (cube.piecePositions[Side.top]![i][j].side != Side.front) {
                rotateByNotation("U");
              }
              rotateByNotation(
                  "${cube.piecePositions[Side.top]![i][j].x}L' F' L' F ${cube.piecePositions[Side.top]![i][j].x}L F' L F");
              while (cube.piecePositions[Side.top]![1][1].x != 1 ||
                  cube.piecePositions[Side.top]![1][1].y != 1) {
                rotateByNotation("U");
              }
            } else if (pos.x == 0) {
              rotateByNotation(
                  "${pos.side.toInstruction}' D ${pos.side.toInstruction}");
              "${pos.side.toInstruction} D' ${pos.side.toInstruction}'"
                  .split(" ")
                  .forEach((element) {
                rememberedMoves.add(Move.fromInstruction(element, cube.size));
              });
            } else if (pos.x == cube.size - 1) {
              rotateByNotation(
                  "${pos.side.toInstruction} D ${pos.side.toInstruction}'");
              "${pos.side.toInstruction}' D' ${pos.side.toInstruction}"
                  .split(" ")
                  .forEach((element) {
                rememberedMoves.add(Move.fromInstruction(element, cube.size));
              });
            } else {
              rotateByNotation("D");
              rememberedMoves.add(Move.fromInstruction("D'", cube.size));
            }
          }
          //front algorithm
          else {
            if (pos.y == 0) {
              rotateByNotation(
                  "${cube.piecePositions[Side.top]![i][j].x}L' F' L' F ${cube.piecePositions[Side.top]![i][j].x}L F' L F");
            } else if (pos.x == 0) {
              rotateByNotation("F' D F");
              "F D' F'".split(" ").forEach((element) {
                rememberedMoves.add(Move.fromInstruction(element, cube.size));
              });
            } else if (pos.x == cube.size - 1) {
              rotateByNotation("F D F'");
              "F' D' F".split(" ").forEach((element) {
                rememberedMoves.add(Move.fromInstruction(element, cube.size));
              });
            } else {
              if (sidePos[0] == 0) {
                rotateByNotation("U'");
                rememberedMoves.add(Move.fromInstruction("U", cube.size));
              }
              if (sidePos[1] == 0) {
                rotateByNotation("U U");
                rememberedMoves.add(Move.fromInstruction("U", cube.size));
                rememberedMoves.add(Move.fromInstruction("U", cube.size));
              }
              if (sidePos[0] == cube.size - 1) {
                rotateByNotation("U");
                rememberedMoves.add(Move.fromInstruction("U'", cube.size));
              }
              rotateByNotation("${pos.x}L' F' L' F ${pos.x}L F' L F");
              while (rememberedMoves.isNotEmpty) {
                genericRotation(rememberedMoves.removeLast());
              }
            }
          }
        }
      }
    }
    //go to next step
    step = 6;
  }

  //6 NxN side sides
  void sideSidesNxN() {
    const List<Side> sides = [
      Side.back,
      Side.left,
      Side.front,
      Side.right,
    ];
    int debug = 0;
    for (int repeat = 0; repeat < 2; repeat++) {
      for (Side side in sides) {
        for (int i = 1; i < cube.size - 1; i++) {
          while (cube.piecePositions[side]![i][0].side != side ||
              cube.piecePositions[side]![i][0].x != 0 ||
              cube.piecePositions[side]![i][0].y != i) {
            PieceData pos = cube.piecePositions[side]![i][0];
            String ins = pos.side.toInstruction;
            if (debug < 1000 /*bugDetectionLimit * cube.size * cube.size*/) {
              debug++;
            } else {
              break;
            }
            //bottom algorithm
            if (pos.side == Side.bottom) {
              if (pos.x != 0) {
                rotateByNotation("D");
              } else {
                rotateByNotation("L' ${pos.y}U' R' D R ${pos.y}U R' D' R L");
              }
            }
            //generic side algorithm
            else {
              if (pos.y == cube.size - 1 &&
                  sides[(sides.indexOf(side) + 1) % 4] != pos.side) {
                rotateByNotation("D");
                continue;
              }
              if (pos.x == cube.size - 1) {
                rotateByNotation("$ins $ins");
              }
              if (pos.y == cube.size - 1) {
                rotateByNotation(ins);
              }
              rotateByNotation(
                  "$ins' D $ins ${cube.piecePositions[side]![i][0].y}U' $ins' D' $ins ${cube.piecePositions[side]![i][0].y}U");
              if (pos.x == cube.size - 1) {
                rotateByNotation("$ins' $ins'");
              }
              if (pos.y == cube.size - 1) {
                rotateByNotation("$ins'");
              }
            }
          }
        }
      }
    }
    //go to next step
    step = 7;
  }

  //7 NxN bottom sides
  void bottomSidesNxN() {
    String getCycle(String name, int i) {
      int j = cube.size - 1 - i;
      if (kDebugMode) print(name);
      switch (name) {
        case "FLs":
          return "D' F D ${j}F' D' F' D ${j}F D' D' F D ${j}F' D' F' D ${j}F D ${j}F' D' F D ${j}F D' F' D";
        //Front->Left->Bottom(south)
        case "FRs":
          return "D F' D' ${i}F D F D' ${i}F' D D F' D' ${i}F D F D' ${i}F' D' ${i}F D F' D' ${i}F' D F D'";
        //Front->Right->Bottom(south)
        case "RFw":
          return "D' R D ${j}R' D' R' D ${j}R D' D' R D ${j}R' D' R' D ${j}R D ${j}R' D' R D ${j}R D' R' D";
        //Right->Front->Bottom(west)
        case "RBw":
          return "D R' D' ${i}R D R D' ${i}R' D D R' D' ${i}R D R D' ${i}R' D' ${i}R D R' D' ${i}R' D R D'";
        //Right->Back->Bottom(west)
        case "BRn":
          return "D' B D ${j}B' D' B' D ${j}B D' D' B D ${j}B' D' B' D ${j}B D ${j}B' D' B D ${j}B D' B' D";
        //Back->Right->Bottom(north)
        case "BLn":
          return "D B' D' ${i}B D B D' ${i}B' D D B' D' ${i}B D B D' ${i}B' D' ${i}B D B' D' ${i}B' D B D'";
        //Back->Left->Bottom(north)
        case "LBe":
          return "D' L D ${j}L' D' L' D ${j}L D' D' L D ${j}L' D' L' D ${j}L D ${j}L' D' L D ${j}L D' L' D";
        //Left->Back->Bottom(east)
        case "LFe":
          return "D L' D' ${i}L D L D' ${i}L' D D L' D' ${i}L D L D' ${i}L' D' ${i}L D L' D' ${i}L' D L D'";
        //Left->Front->Bottom(east)
        case "flipRight":
          return "R F R' D R' D' R";
        case "rFlipRight":
          return "R' D R D' R F' R'";
        default:
          return "D";
      }
    }

    //left side
    int debug = 0;
    for (int i = 1; i < cube.size - 1; i++) {
      while (
          cube.piecePositions[Side.left]![cube.size - 1][i].side != Side.left ||
              cube.piecePositions[Side.left]![cube.size - 1][i].x != i ||
              cube.piecePositions[Side.left]![cube.size - 1][i].y !=
                  cube.size - 1) {
        PieceData pos = cube.piecePositions[Side.left]![cube.size - 1][i];
        if (debug < bugDetectionLimit * cube.size * cube.size) {
          debug++;
        } else {
          break;
        }
        //bottom algorithm
        if (pos.side == Side.bottom) {
          if (pos.x == 0) {
            rotateByNotation(getCycle("RFw", i));
          }
          if (pos.y == 0) {
            rotateByNotation(getCycle("BRn", i));
          }
          if (pos.x == cube.size - 1) {
            rotateByNotation(getCycle("LFe", i));
          }
          if (pos.y == cube.size - 1) {
            rotateByNotation(getCycle("FRs", i));
          }
        }
        //front algorithm
        else if (pos.side == Side.front) {
          rotateByNotation(getCycle("FLs", i));
        }
        //right algorithm
        else if (pos.side == Side.right) {
          rotateByNotation("${getCycle("FRs", i)} ${getCycle("FRs", i)}");
        }
        //back algorithm
        else {
          rotateByNotation(getCycle("BLn", i));
        }
      }
    }

    //front side
    for (int i = 1; i < cube.size - 1; i++) {
      while (cube.piecePositions[Side.front]![cube.size - 1][i].side !=
              Side.front ||
          cube.piecePositions[Side.front]![cube.size - 1][i].x != i ||
          cube.piecePositions[Side.front]![cube.size - 1][i].y !=
              cube.size - 1) {
        PieceData pos = cube.piecePositions[Side.front]![cube.size - 1][i];
        if (debug < bugDetectionLimit * cube.size * cube.size) {
          debug++;
        } else {
          break;
        }
        //bottom algorithm
        if (pos.side == Side.bottom) {
          if (pos.y == 0) {
            rotateByNotation(getCycle("BRn", i));
          }
          if (pos.x == cube.size - 1) {
            rotateByNotation(
                "${getCycle("LBe", i)} ${getCycle("LBe", i)} ${getCycle("LFe", i)}");
          }
          if (pos.y == cube.size - 1) {
            rotateByNotation(getCycle("FRs", i));
          }
        }
        //right algorithm
        else if (pos.side == Side.right) {
          rotateByNotation("${getCycle("FRs", i)} ${getCycle("FRs", i)}");
        }
        //back algorithm
        else {
          rotateByNotation(
              "${getCycle("BRn", i)} ${getCycle("FRs", cube.size - 1 - i)}");
        }
      }
    }
    if (cube.piecePositions[Side.right]![cube.size - 1][cube.size ~/ 2].x !=
            cube.size - 1 &&
        cube.piecePositions[Side.right]![cube.size - 1][cube.size ~/ 2].side !=
            Side.right &&
        debug != 1) {
      rotateByNotation("D");
      return;
    }

    //right and back sides
    if (debug != 1) {
      for (int repeat = 0;
          repeat < cube.size * cube.size * bugDetectionLimit;
          repeat++) {
        for (int i = 1; i < cube.size - 1; i++) {
          if (cube.piecePositions[Side.right]![cube.size - 1][i].side !=
                  Side.right ||
              cube.piecePositions[Side.right]![cube.size - 1][i].x != i ||
              cube.piecePositions[Side.right]![cube.size - 1][i].y !=
                  cube.size - 1) {
            PieceData pos = cube.piecePositions[Side.right]![cube.size - 1][i];
            //bottom algorithm
            if (pos.side == Side.bottom) {
              if (pos.x == cube.size - 1) {
                //center exception
                if (i == cube.size / 2 - 1 / 2) {
                  rotateByNotation(
                      "${getCycle("flipRight", i)} ${getCycle("RBw", i)} ${getCycle("RBw", i)} ${getCycle("rFlipRight", i)} ${getCycle("RBw", i)}");
                }
                //parity exception
                else if (cube
                        .piecePositions[Side.right]![cube.size - 1]
                            [cube.size - 1 - i]
                        .x ==
                    cube.size - 1) {
                  if (i >= cube.size / 2) {
                    i = cube.size - i - 1;
                  }
                  String bW = "B";
                  String rBW = "B'";
                  String fW = "F";
                  String rFW = "F'";
                  for (int j = 1; j <= i; j++) {
                    bW += " ${j}B";
                    rBW += " ${j}B'";
                    fW += " ${j}F";
                    rFW += " ${j}F'";
                  }
                  rotateByNotation(
                      "$bW R R $bW D D $bW D D $rBW D D $fW D D $rFW R R $bW R R $rBW R R $rBW");
                } else {
                  rotateByNotation(
                      "${getCycle("flipRight", i)} ${getCycle("RBw", i)} ${getCycle("RBw", i)} ${getCycle("rFlipRight", i)} ${getCycle("RBw", i)}");
                }
              }
              if (pos.y == cube.size - 1) {
                rotateByNotation(
                    "${getCycle("flipRight", i)} ${getCycle("RBw", cube.size - 1 - i)} ${getCycle("RBw", cube.size - 1 - i)} ${getCycle("rFlipRight", i)} ${getCycle("RBw", cube.size - 1 - i)}");
              }
            }
            //back algorithm
            else {
              rotateByNotation(
                  "${getCycle("flipRight", i)} ${getCycle("RBw", i)} ${getCycle("RBw", i)} ${getCycle("rFlipRight", i)} ${getCycle("RBw", i)}");
            }
          }
        }
      }
    }

    //parity
    if (debug != 1) {
      for (int i = (cube.size - 1) ~/ 2; i > 0; i--) {
        PieceData pos = cube.piecePositions[Side.back]![cube.size - 1][i];
        if (pos.side == Side.bottom) {
          String bW = "B";
          String rBW = "B'";
          String fW = "F";
          String rFW = "F'";
          for (int j = 1; j <= i; j++) {
            bW += " ${j}B";
            rBW += " ${j}B'";
            fW += " ${j}F";
            rFW += " ${j}F'";
          }
          rotateByNotation(
              "D' $bW R R $bW D D $bW D D $rBW D D $fW D D $rFW R R $bW R R $rBW R R $rBW D");
        }
      }
    }

    //go to next step
    step = 100;
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
            rotateByNotation("B B");
          }
          if (pos.x == cube.size - 1 && pos.y == 1) {
            rotateByNotation("R R");
          }
          if (pos.x == cube.size - 2 && pos.y == cube.size - 1) {
            rotateByNotation("F F");
          }
          if (pos.x == 0 && pos.y == cube.size - 2) {
            rotateByNotation("L L");
          }
        }
        //front algorithm
        if (pos.side == Side.front) {
          if (pos.x == 1 && pos.y == 0) {
            rotateByNotation("F");
          }
          if (pos.x == cube.size - 1 && pos.y == 1) {
            rotateByNotation("R' D R");
          }
          if (pos.x == cube.size - 2 && pos.y == cube.size - 1) {
            rotateByNotation("F' R' D R F");
          }
          if (pos.x == 0 && pos.y == cube.size - 2) {
            rotateByNotation("L D L'");
          }
        }
        //right algorithm
        if (pos.side == Side.right) {
          if (pos.x == 1 && pos.y == 0) {
            rotateByNotation("R");
          }
          if (pos.x == cube.size - 1 && pos.y == 1) {
            rotateByNotation("B' D B");
          }
          if (pos.x == cube.size - 2 && pos.y == cube.size - 1) {
            rotateByNotation("R' B' D' B R");
          }
          if (pos.x == 0 && pos.y == cube.size - 2) {
            rotateByNotation("F D F'");
          }
        }
        //back algorithm
        if (pos.side == Side.back) {
          if (pos.x == 1 && pos.y == 0) {
            rotateByNotation("B");
          }
          if (pos.x == cube.size - 1 && pos.y == 1) {
            rotateByNotation("L' D L");
          }
          if (pos.x == cube.size - 2 && pos.y == cube.size - 1) {
            rotateByNotation("B' L' D L B");
          }
          if (pos.x == 0 && pos.y == cube.size - 2) {
            rotateByNotation("R D R'");
          }
        }
        //left algorithm
        if (pos.side == Side.left) {
          if (pos.x == 1 && pos.y == 0) {
            rotateByNotation("L");
          }
          if (pos.x == cube.size - 1 && pos.y == 1) {
            rotateByNotation("F' D F");
          }
          if (pos.x == cube.size - 2 && pos.y == cube.size - 1) {
            rotateByNotation("L' F' D' F L");
          }
          if (pos.x == 0 && pos.y == cube.size - 2) {
            rotateByNotation("B D B'");
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
            rotateByNotation("D");
          } else {
            if (pos.x == 1 && pos.y == 0) {
              rotateByNotation("F F");
            }
            if (pos.x == cube.size - 1 && pos.y == 1) {
              rotateByNotation("R R");
            }
            if (pos.x == cube.size - 2 && pos.y == cube.size - 1) {
              rotateByNotation("B B");
            }
            if (pos.x == 0 && pos.y == cube.size - 2) {
              rotateByNotation("L L");
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
            rotateByNotation("L' D' L");
          }
          if (pos.x == cube.size - 1 && pos.y == 0) {
            rotateByNotation("B' D' B");
          }
          if (pos.x == cube.size - 1 && pos.y == cube.size - 1) {
            rotateByNotation("R' D' R");
          }
          if (pos.x == 0 && pos.y == cube.size - 1) {
            rotateByNotation("F' D' F");
          }
        }
        //front algorithm
        if (pos.side == Side.front) {
          if (pos.x == 0 && pos.y == 0) {
            rotateByNotation("F' D F");
          }
          if (pos.x == cube.size - 1 && pos.y == 0) {
            rotateByNotation("F D' F'");
          }
        }
        //right algorithm
        if (pos.side == Side.right) {
          if (pos.x == 0 && pos.y == 0) {
            rotateByNotation("R' D R");
          }
          if (pos.x == cube.size - 1 && pos.y == 0) {
            rotateByNotation("R D' R'");
          }
        }
        //back algorithm
        if (pos.side == Side.back) {
          if (pos.x == 0 && pos.y == 0) {
            rotateByNotation("B' D B");
          }
          if (pos.x == cube.size - 1 && pos.y == 0) {
            rotateByNotation("B D' B'");
          }
        }
        //left algorithm
        if (pos.side == Side.left) {
          if (pos.x == 0 && pos.y == 0) {
            rotateByNotation("L' D L");
          }
          if (pos.x == cube.size - 1 && pos.y == 0) {
            rotateByNotation("L D' L'");
          }
        }
        //individual corner algorithms
        if (pos.side != Side.top && pos.side != Side.bottom) {
          if (initPos[0] == 0 && initPos[1] == 0) {
            if (pos.x == 0 && pos.y == cube.size - 1) {
              if (pos.side == Side.front) {
                rotateByNotation("B D' B'");
              } else {
                rotateByNotation("D");
              }
            } else if (pos.x == cube.size - 1 && pos.y == cube.size - 1) {
              if (pos.side == Side.right) {
                rotateByNotation("L' D L");
              } else {
                rotateByNotation("D");
              }
            }
          } else if (initPos[0] == cube.size - 1 && initPos[1] == 0) {
            if (pos.x == 0 && pos.y == cube.size - 1) {
              if (pos.side == Side.left) {
                rotateByNotation("R D' R'");
              } else {
                rotateByNotation("D");
              }
            } else if (pos.x == cube.size - 1 && pos.y == cube.size - 1) {
              if (pos.side == Side.front) {
                rotateByNotation("B' D B");
              } else {
                rotateByNotation("D");
              }
            }
          } else if (initPos[0] == cube.size - 1 &&
              initPos[1] == cube.size - 1) {
            if (pos.x == 0 && pos.y == cube.size - 1) {
              if (pos.side == Side.back) {
                rotateByNotation("F D' F'");
              } else {
                rotateByNotation("D");
              }
            } else if (pos.x == cube.size - 1 && pos.y == cube.size - 1) {
              if (pos.side == Side.left) {
                rotateByNotation("R' D R");
              } else {
                rotateByNotation("D");
              }
            }
          } else if (initPos[0] == 0 && initPos[1] == cube.size - 1) {
            if (pos.x == 0 && pos.y == cube.size - 1) {
              if (pos.side == Side.right) {
                rotateByNotation("L D' L'");
              } else {
                rotateByNotation("D");
              }
            } else if (pos.x == cube.size - 1 && pos.y == cube.size - 1) {
              if (pos.side == Side.back) {
                rotateByNotation("F' D F");
              } else {
                rotateByNotation("D");
              }
            }
          }
        }
        //bottom algorithm
        if (pos.side == Side.bottom) {
          if (pos.x == 0 && pos.y == 0) {
            if (cube.cube[Side.top]![cube.size - 1][0].side == Side.top) {
              rotateByNotation("D");
            } else {
              rotateByNotation("F' D F");
            }
          } else if (pos.x == 0 && pos.y == cube.size - 1) {
            if (cube.cube[Side.top]![0][0].side == Side.top) {
              rotateByNotation("D");
            } else {
              rotateByNotation("L' D L");
            }
          } else if (pos.x == cube.size - 1 && pos.y == cube.size - 1) {
            if (cube.cube[Side.top]![0][cube.size - 1].side == Side.top) {
              rotateByNotation("D");
            } else {
              rotateByNotation("B' D B");
            }
          } else if (pos.x == cube.size - 1 && pos.y == 0) {
            if (cube.cube[Side.top]![cube.size - 1][cube.size - 1].side ==
                Side.top) {
              rotateByNotation("D");
            } else {
              rotateByNotation("R' D R");
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
            rotateByNotation("D $i2 D' $i2' D' $i1' D $i1");
          } else if (pos.x == cube.size - 1 && pos.y == cube.size - 2) {
            int currentIndex = sides.lastIndexOf(pos.side);
            String i2 = sides[(currentIndex + 1) % 4].toInstruction;
            rotateByNotation("D' $i2' D $i2 D $i1 D' $i1'");
          } else if (pos.side != side) {
            rotateByNotation("D");
          } else if (initPos[0] == 0 && initPos[1] == 1) {
            int currentIndex = sides.lastIndexOf(pos.side);
            String i2 = sides[(currentIndex - 1) % 4].toInstruction;
            rotateByNotation("D $i2 D' $i2' D' $i1' D $i1");
          } else {
            int currentIndex = sides.lastIndexOf(pos.side);
            String i2 = sides[(currentIndex + 1) % 4].toInstruction;
            rotateByNotation("D' $i2' D $i2 D $i1 D' $i1'");
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
          rotateByNotation("D");
        }
      }
      rotateByNotation("F D L D' L' F'");
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
        rotateByNotation("D");
      }
      if (cube.piecePositions[Side.front]![cube.size - 1][1].side ==
          Side.right) {
        rotateByNotation("F D F' D F D D F' D D");
      }
      if (cube.piecePositions[Side.front]![cube.size - 1][1].side ==
          Side.back) {
        rotateByNotation("B D B' D B D D B'");
      }
      if (cube.piecePositions[Side.right]![cube.size - 1][1].side ==
          Side.back) {
        rotateByNotation("B D B' D B D D B'");
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
      rotateByNotation("D R D' L' D R' D' L");
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
      rotateByNotation(algorithms[validCorner]);
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
        rotateByNotation("L' U L U'");
      }
      rotateByNotation("D");
    }
    //even sized cube parity fix
    if (cube.size % 2 == 0 && cube.size > 2) {
      if (cube.piecePositions[Side.back]![cube.size - 1][cube.size - 1].side ==
              Side.left ||
          cube.piecePositions[Side.back]![cube.size - 1][cube.size - 1].side ==
              Side.right) {
        String fW = "F";
        String dW = "D";
        for (int j = 1; j < cube.size ~/ 2; j++) {
          fW += " ${j}F";
          dW += " ${j}D";
        }
        rotateByNotation(
            "$fW $fW F F D D $fW $fW F F $dW $dW $fW $fW F F $dW $dW D D");
        step = 100;
        return;
      }
    }
    //end the 3x3 algorithm
    step = -1;
  }

  //200 solve 2x2
  void solve2x2() {
    //top
    topCorners3x3();
    //align bottom
    while (cube.piecePositions[Side.bottom]![0][0] !=
            PieceData(Side.bottom, 0, 0) &&
        cube.piecePositions[Side.front]![1][0] !=
            PieceData(Side.bottom, 0, 0) &&
        cube.piecePositions[Side.left]![1][1] != PieceData(Side.bottom, 0, 0)) {
      rotateByNotation("D");
    }

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
      rotateByNotation("D R D' L' D R' D' L");
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
      rotateByNotation(algorithms[validCorner]);
    }

    //3x3 cube alignment algorithm
    int edgeFlipDetector = 0;
    for (int i = 0; i < 4; i++) {
      while (cube.cube[Side.bottom]![0][0].side != Side.bottom) {
        if (edgeFlipDetector < 20) {
          edgeFlipDetector++;
        } else {
          break;
        }
        rotateByNotation("L' U L U'");
      }
      rotateByNotation("D");
    }
    if (cube.piecePositions[Side.back]![1][0].side == Side.left) {
      rotateByNotation("U R U' F U U F' U R F F R R U D'");
    }
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
      4: rightAndBackCentersNxN,
      5: topSidesNxN,
      6: sideSidesNxN,
      7: bottomSidesNxN,
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
