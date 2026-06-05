import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  // ─── Durées ───────────────────────────────────────────
  static const Duration fast    = Duration(milliseconds: 150);
  static const Duration normal  = Duration(milliseconds: 300);
  static const Duration slow    = Duration(milliseconds: 500);
  static const Duration slower  = Duration(milliseconds: 800);

  // ─── Courbes ─────────────────────────────────────────
  static const Curve easeOut    = Curves.easeOut;
  static const Curve easeInOut  = Curves.easeInOut;
  static const Curve spring     = Curves.elasticOut;
  static const Curve smooth     = Curves.fastOutSlowIn;
}