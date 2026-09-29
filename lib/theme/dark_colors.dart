import 'package:flutter/painting.dart';
import 'package:product_catalog/theme/app_colors.dart';

/// Dark palette. noon.com has no dark mode, so this keeps its accents (yellow,
/// blue, green, coral) on deep navy greys instead of plain black.
const AppColors darkColors = AppColors(
  primary: Color(0xFF6E93F5),
  secondary: Color(0xFF22252E),
  background: Color(0xFF0E0F13),
  surface: Color(0xFF181A21),
  surfaceHighlight: Color(0xFF22252E),
  text: Color(0xFFF5F6F8),
  textSecondary: Color(0xFFC3C7D1),
  textTertiary: Color(0xFF8A90A2),
  buttonPrimaryText: Color(0xFFFFFFFF),
  border: Color(0xFF2A2D37),
  borderSecondary: Color(0xFF454A58),
  success: Color(0xFF3DD26A),
  error: Color(0xFFFF6B6B),
  warning: Color(0xFFFFB340),
  brand: Color(0xFFFEEE00),
  onBrand: Color(0xFF101628),
  header: Color(0xFF15171E),
  onHeader: Color(0xFFF5F6F8),
  searchField: Color(0xFF262933),
  chipSelected: Color(0xFFFEEE00),
  onChipSelected: Color(0xFF101628),
  sale: Color(0xFFFF6A57),
  rating: Color(0xFF3DD26A),
);
