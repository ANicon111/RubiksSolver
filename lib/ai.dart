import 'package:rubikssolver/definitions.dart';
import 'package:rubikssolver/logic.dart';

class AIMove {
  final List<RotData> rotationList;
  final int index;
  final bool reversed;

  AIMove(this.rotationList, this.index, this.reversed);
}

class AI {
  final RubiksCube cube;
  final int maxDepth;
  List<AIMove> currentChange = [];
  List<AIMove> bestChange = [];
  int bestChangeScore = 0;
  int initScore = 0;

  AI(
    this.cube, [
    this.maxDepth = 0,
  ]);

  List<AIMove> dfs([int currentDepth = 0]) {
    //TODO: to implement not crap algorithm
    if (currentDepth == 0) {
      return bestChange;
    } else {
      return [];
    }
  }
}
