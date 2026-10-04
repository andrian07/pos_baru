import 'package:flutter/material.dart';

class GamePackage {
  final int amount;
  final String unit;
  final int price;
  const GamePackage(this.amount, this.unit, this.price);
}

class GameInfo {
  final String name;
  final String asset;
  final Color color;
  final String unit;
  final List<GamePackage> packages;
  const GameInfo(this.name, this.asset, this.color, this.unit, this.packages);
}
