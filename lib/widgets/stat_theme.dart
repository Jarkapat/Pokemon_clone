import 'package:flutter/material.dart';

class StatPalette {
  final Color hp, atk, def, spAtk, spDef, speed;
  const StatPalette({
    required this.hp,
    required this.atk,
    required this.def,
    required this.spAtk,
    required this.spDef,
    required this.speed,
  });

  // โทนที่เข้ากับธีมเขียว/มิ้นต์แบบโปเกมอน GO
  static const harmonious = StatPalette(
    hp: Color(0xFFE94E3D),       // แดงอมส้ม
    atk: Color(0xFFF39C12),      // ส้มอุ่น
    def: Color(0xFF3A86FF),      // น้ำเงินสด
    spAtk: Color(0xFF9B59B6),    // ม่วงนุ่ม
    spDef: Color(0xFF2AB7A9),    // เขียวน้ำทะเล
    speed: Color(0xFFFFC300),    // เหลืองอำพัน
  );
}
