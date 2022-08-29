import 'package:flutter/material.dart';

class RelSize {
  final BuildContext context;
  RelSize(this.context);
  double get vmin {
    return MediaQuery.of(context).size.shortestSide / 100;
  }

  double get vmax {
    return MediaQuery.of(context).size.longestSide / 100;
  }

  double get pixel {
    return MediaQuery.of(context).size.shortestSide / 1080;
  }
}

class Direction {
  final int val;

  const Direction(this.val);

  @override
  int get hashCode => val;

  @override
  bool operator ==(Object other) =>
      other is Direction && other.runtimeType == Direction && other.val == val;

  static const Direction top = Direction(0);
  static const Direction right = Direction(1);
  static const Direction bottom = Direction(2);
  static const Direction left = Direction(3);
}

class Side {
  final int val;

  const Side(this.val);

  @override
  int get hashCode => val;

  @override
  bool operator ==(Object other) =>
      other is Side && other.runtimeType == Side && other.val == val;

  String get toInstruction => (const ["F", "U", "L", "B", "D", "R"])[val];
  @override
  String toString() {
    return const ["front", "top", "left", "back", "bottom", "right"][val];
  }

  static const Side front = Side(0);
  static const Side top = Side(1);
  static const Side left = Side(2);
  static const Side back = Side(3);
  static const Side bottom = Side(4);
  static const Side right = Side(5);
}

class PieceData {
  final Side side;
  final int x, y;
  PieceData(this.side, this.y, this.x);

  @override
  String toString() {
    return "${const [
      "front",
      "top",
      "left",
      "back",
      "bottom",
      "right"
    ][side.hashCode]},x:$x,y:$y";
  }

  @override
  int get hashCode => side.hashCode + 6 * x + 60000 * y;

  @override
  bool operator ==(Object other) =>
      other is PieceData &&
      other.runtimeType == PieceData &&
      other.hashCode == hashCode;
}

class RotData {
  final Side side;
  final Direction startingDirection;

  const RotData(this.side, this.startingDirection);
}
