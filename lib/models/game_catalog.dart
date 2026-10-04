import 'package:flutter/material.dart';

import 'game.dart';

List<GamePackage> _tiered(String unit, List<int> amounts, double pricePerUnit) {
  return [
    for (final a in amounts)
      GamePackage(a, unit, ((a * pricePerUnit) / 100).round() * 100),
  ];
}

List<GamePackage> _wallet(List<int> amounts) {
  return [for (final a in amounts) GamePackage(a, 'Saldo', a)];
}

final List<GameInfo> gameCatalog = [
  GameInfo(
    'Mobile Legends',
    'asset/game/01_Mobile_Legends.png',
    const Color(0xFF1A2A6C),
    'Diamond',
    const [
      GamePackage(5, 'Diamond', 1500),
      GamePackage(11, 'Diamond', 3000),
      GamePackage(14, 'Diamond', 4000),
      GamePackage(28, 'Diamond', 8000),
      GamePackage(56, 'Diamond', 15000),
      GamePackage(86, 'Diamond', 23000),
      GamePackage(172, 'Diamond', 45000),
      GamePackage(257, 'Diamond', 65000),
      GamePackage(344, 'Diamond', 85000),
      GamePackage(429, 'Diamond', 105000),
      GamePackage(514, 'Diamond', 125000),
      GamePackage(706, 'Diamond', 165000),
    ],
  ),
  GameInfo(
    'Free Fire',
    'asset/game/02_Free_Fire.png',
    const Color(0xFFFF7A00),
    'Diamond',
    _tiered('Diamond', [10, 30, 50, 70, 100, 140, 210, 355, 500], 180),
  ),
  GameInfo(
    'PUBG Mobile',
    'asset/game/03_PUBG_Mobile.png',
    const Color(0xFFE8A33D),
    'UC',
    _tiered('UC', [60, 120, 180, 325, 385, 660, 1800, 3850], 165),
  ),
  GameInfo(
    'Genshin Impact',
    'asset/game/04_Genshin_Impact.png',
    const Color(0xFF2F5C8A),
    'Genesis Crystal',
    _tiered('Genesis Crystal', [60, 300, 980, 1980, 3280, 6480], 230),
  ),
  GameInfo(
    'Honor of Kings',
    'asset/game/05_Honor_of_Kings.png',
    const Color(0xFFB8860B),
    'Token',
    _tiered('Token', [60, 300, 980, 1980, 3280], 150),
  ),
  GameInfo(
    'Valorant',
    'asset/game/06_Valorant.png',
    const Color(0xFFFF4655),
    'VP',
    _tiered('VP', [125, 420, 700, 1375, 2400, 4000], 230),
  ),
  GameInfo(
    'Steam Wallet',
    'asset/game/07_Steam.png',
    const Color(0xFF1B2838),
    'Saldo',
    _wallet([12000, 45000, 60000, 90000, 120000, 250000, 450000]),
  ),
  GameInfo(
    'PlayStation Store',
    'asset/game/08_PlayStation_Store.png',
    const Color(0xFF003791),
    'Saldo',
    _wallet([60000, 100000, 200000, 300000, 500000, 700000]),
  ),
  GameInfo(
    'Garena',
    'asset/game/09_Garena.png',
    const Color(0xFFE2231A),
    'Shell',
    _tiered('Shell', [50, 100, 200, 500, 1000, 2000], 170),
  ),
  GameInfo(
    'Xbox Gift Card',
    'asset/game/10_Xbox.png',
    const Color(0xFF107C10),
    'Saldo',
    _wallet([60000, 100000, 150000, 250000, 400000, 600000]),
  ),
  GameInfo(
    'EA',
    'asset/game/11_EA.png',
    const Color(0xFFFF4747),
    'Saldo',
    _wallet([60000, 100000, 150000, 250000, 400000]),
  ),
  GameInfo(
    'Nintendo eShop',
    'asset/game/12_Nintendo_eShop.png',
    const Color(0xFFE60012),
    'Saldo',
    _wallet([50000, 100000, 200000, 300000, 500000]),
  ),
  GameInfo(
    'Roblox',
    'asset/game/13_Roblox.png',
    const Color(0xFF00A2FF),
    'Robux',
    _tiered('Robux', [80, 400, 800, 1700, 4500, 10000], 165),
  ),
  GameInfo(
    'Minecraft',
    'asset/game/14_Minecraft.png',
    const Color(0xFF3B8526),
    'Minecoin',
    _tiered('Minecoin', [320, 1020, 1720, 3500, 8800], 150),
  ),
  GameInfo(
    'Razer Gold',
    'asset/game/15_Razer_Gold.png',
    const Color(0xFF44D62C),
    'Saldo',
    _wallet([50000, 100000, 150000, 250000, 500000]),
  ),
];
