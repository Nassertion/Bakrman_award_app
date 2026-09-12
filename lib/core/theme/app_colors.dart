import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette (Emerald & Deep Teal)
  static const Color primary = Color(0xFF0F766E);       // Emerald 700
  static const Color primaryDark = Color(0xFF115E59);   // Teal 800
  static const Color primaryLight = Color(0xFF2DD4BF);  // Teal 400
  static const Color primaryContainer = Color(0xFFECFDF5); // Mint Soft

  // Accent Gold / Amber Palette
  static const Color accent = Color(0xFFD97706);        // Amber 600
  static const Color accentLight = Color(0xFFFBBF24);   // Amber 300
  static const Color accentContainer = Color(0xFFFEF3C7); // Amber Soft

  // Surface & Neutral Colors
  static const Color background = Color(0xFFF8FAFC);   // Slate 50
  static const Color surface = Color(0xFFFFFFFF);      // Pure White
  static const Color surfaceVariant = Color(0xFFF1F5F9);// Slate 100
  static const Color border = Color(0xFFE2E8F0);        // Slate 200

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);  // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8);     // Slate 400

  // Status Colors
  static const Color success = Color(0xFF10B981);       // Emerald 500
  static const Color error = Color(0xFFEF4444);         // Red 500
  static const Color warning = Color(0xFFF59E0B);       // Amber 500
  static const Color info = Color(0xFF3B82F6);          // Blue 500
}
