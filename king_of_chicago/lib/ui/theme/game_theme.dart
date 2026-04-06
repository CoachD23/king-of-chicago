import 'package:flutter/material.dart';

/// Visual constants for the King of Chicago game UI.
class GameTheme {
  GameTheme._();

  // Core palette
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color textColor = Color(0xFFE0D5C0);
  static const Color dialogueBackground = Color(0xFF1A1A1A);
  static const Color borderColor = Color(0xFF3A3A3A);
  static const Color speakerGold = Color(0xFFD4AF37);
  static const Color narratorDim = Color(0xFFB0A890);
  static const Color lockedGrey = Color(0xFF666666);

  // Aliases kept for backward compatibility
  static const Color background = backgroundColor;
  static const Color surface = Color(0xFF1A1A2E);
  static const Color accent = speakerGold;
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color danger = Color(0xFF8B0000);

  // Text styles
  static const TextStyle titleStyle = TextStyle(
    color: accent,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
  );

  static const TextStyle dialogueStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 16,
    height: 1.5,
    color: textColor,
  );

  static const TextStyle speakerStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: speakerGold,
  );

  static const TextStyle narratorStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 16,
    height: 1.5,
    fontStyle: FontStyle.italic,
    color: narratorDim,
  );

  static const TextStyle choiceStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 15,
    height: 1.4,
    color: textColor,
  );

  static const TextStyle lockedChoiceStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 15,
    height: 1.4,
    color: lockedGrey,
  );

  static const TextStyle locationStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 3.0,
    color: narratorDim,
  );

  static const TextStyle deltaHintStyle = TextStyle(
    fontFamily: 'Serif',
    fontSize: 11,
    color: narratorDim,
  );
}
