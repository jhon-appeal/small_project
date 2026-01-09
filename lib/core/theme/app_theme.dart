import 'package:flutter/material.dart';

class AppTheme {
  // Color scheme based on roles
  static const Color homeownerColor = Color(0xFF2196F3); // Blue
  static const Color roofingColor = Color(0xFF4CAF50); // Green
  static const Color assessDirectColor = Color(0xFFFF9800); // Orange

  // Status colors
  static const Color pendingColor = Color(0xFF9E9E9E); // Grey
  static const Color inProgressColor = Color(0xFF2196F3); // Blue
  static const Color completedColor = Color(0xFF4CAF50); // Green
  static const Color approvedColor = Color(0xFF4CAF50); // Green
  static const Color inspectionColor = Color(0xFFFFC107); // Amber
  static const Color claimApprovedColor = Color(0xFF4CAF50); // Green
  static const Color constructionColor = Color(0xFFFF9800); // Orange

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: homeownerColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static Color getRoleColor(String role) {
    switch (role) {
      case 'homeowner':
        return homeownerColor;
      case 'roofing_company':
        return roofingColor;
      case 'assess_direct':
        return assessDirectColor;
      default:
        return Colors.grey;
    }
  }

  static Color getStatusColor(String status) {
    // Status should match milestone_status ENUM: pending, in_progress, completed, approved
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return pendingColor;
      case 'in_progress':
        return inProgressColor;
      case 'completed':
        return completedColor;
      case 'approved':
        return approvedColor;
      default:
        return Colors.grey;
    }
  }
}

