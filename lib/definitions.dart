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

  Direction(this.val);

  @override
  int get hashCode => val;

  @override
  bool operator ==(Object other) =>
      other is Direction && other.runtimeType == Direction && other.val == val;

  static final Direction top = Direction(0);
  static final Direction right = Direction(1);
  static final Direction bottom = Direction(2);
  static final Direction left = Direction(3);
}

class Side {
  final int val;

  Side(this.val);

  @override
  int get hashCode => val;

  @override
  bool operator ==(Object other) =>
      other is Side && other.runtimeType == Side && other.val == val;

  static final Side front = Side(0);
  static final Side top = Side(1);
  static final Side left = Side(2);
  static final Side back = Side(3);
  static final Side bottom = Side(4);
  static final Side right = Side(5);
}

class RotData {
  final Side side;
  final Direction startingDirection;

  RotData(this.side, this.startingDirection);
}
