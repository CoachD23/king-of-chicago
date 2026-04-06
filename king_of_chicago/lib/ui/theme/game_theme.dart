import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Art Deco Noir visual constants for the King of Chicago game UI.
///
/// Think: 1930s speakeasy menu meets film noir title card.
/// Gold leaf on obsidian. Sharp geometric borders.
class GameTheme {
  GameTheme._();

  // ── Core palette ──────────────────────────────────────────────────────

  /// Near-black with warmth, like old leather.
  static const Color backgroundColor = Color(0xFF0D0B08);

  /// Dark brown-black surface.
  static const Color surface = Color(0xFF1A1612);

  /// Aged gold accent.
  static const Color goldAccent = Color(0xFFC9A84C);

  /// Lighter gold for text highlights.
  static const Color goldHighlight = Color(0xFFE8D5A3);

  /// Dark crimson blood accent.
  static const Color bloodAccent = Color(0xFF8B1A1A);

  /// Smoke color for borders and dividers.
  static const Color smoke = Color(0xFF2A2520);

  /// Secondary text / ash color.
  static const Color ash = Color(0xFF9C9488);

  /// Primary text / parchment color.
  static const Color parchment = Color(0xFFD4C5A9);

  // ── Backward-compatibility aliases ────────────────────────────────────

  static const Color background = backgroundColor;
  static const Color accent = goldAccent;
  static const Color textColor = parchment;
  static const Color textPrimary = parchment;
  static const Color textSecondary = ash;
  static const Color borderColor = smoke;
  static const Color speakerGold = goldAccent;
  static const Color narratorDim = ash;
  static const Color lockedGrey = Color(0xFF5A5550);
  static const Color danger = bloodAccent;
  static const Color dialogueBackground = surface;

  // ── Text styles ───────────────────────────────────────────────────────

  /// Large title — Playfair Display, gold, letter-spaced.
  static TextStyle get titleStyle => GoogleFonts.playfairDisplay(
        color: goldHighlight,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 4.0,
      );

  /// Subtitle — Josefin Sans, ash/gold.
  static TextStyle get subtitleStyle => GoogleFonts.josefinSans(
        color: ash,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        letterSpacing: 6.0,
      );

  /// Speaker name — Josefin Sans, uppercase, gold.
  static TextStyle get speakerStyle => GoogleFonts.josefinSans(
        color: goldAccent,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 3.0,
      );

  /// Dialogue body — Crimson Text, parchment, generous line height.
  static TextStyle get dialogueStyle => GoogleFonts.crimsonText(
        color: parchment,
        fontSize: 17,
        height: 1.7,
      );

  /// Narrator — italic Crimson Text, slightly dimmer.
  static TextStyle get narratorStyle => GoogleFonts.crimsonText(
        color: ash,
        fontSize: 17,
        height: 1.7,
        fontStyle: FontStyle.italic,
      );

  /// Choice text — Crimson Text, parchment.
  static TextStyle get choiceStyle => GoogleFonts.crimsonText(
        color: parchment,
        fontSize: 16,
        height: 1.5,
      );

  /// Locked choice text.
  static TextStyle get lockedChoiceStyle => GoogleFonts.crimsonText(
        color: lockedGrey,
        fontSize: 16,
        height: 1.5,
      );

  /// Location header — Josefin Sans, uppercase, letter-spaced.
  static TextStyle get locationStyle => GoogleFonts.josefinSans(
        color: goldHighlight,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 6.0,
      );

  /// Delta hint text for choice consequences.
  static TextStyle get deltaHintStyle => GoogleFonts.josefinSans(
        color: ash,
        fontSize: 11,
        letterSpacing: 0.5,
      );

  /// Label text — Josefin Sans, small.
  static TextStyle get labelStyle => GoogleFonts.josefinSans(
        color: ash,
        fontSize: 9,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.0,
      );

  /// Veil value text — Josefin Sans.
  static TextStyle get veilValueStyle => GoogleFonts.josefinSans(
        color: goldHighlight,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      );

  // ── Box decorations ───────────────────────────────────────────────────

  /// Surface panel decoration.
  static BoxDecoration get surfaceDecoration => const BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(color: smoke, width: 0.5),
          bottom: BorderSide(color: smoke, width: 0.5),
        ),
      );

  /// Choice card decoration.
  static BoxDecoration choiceCardDecoration(Color veilColor) => BoxDecoration(
        color: surface,
        border: Border(
          left: BorderSide(color: veilColor, width: 3),
          top: BorderSide(color: smoke, width: 0.5),
          bottom: BorderSide(color: smoke, width: 0.5),
          right: BorderSide(color: smoke, width: 0.5),
        ),
      );

  /// Hovered choice card decoration.
  static BoxDecoration hoveredChoiceCardDecoration(Color veilColor) =>
      BoxDecoration(
        color: veilColor.withAlpha(20),
        border: Border(
          left: BorderSide(color: veilColor, width: 3),
          top: BorderSide(color: veilColor.withAlpha(80), width: 0.5),
          bottom: BorderSide(color: veilColor.withAlpha(80), width: 0.5),
          right: BorderSide(color: veilColor.withAlpha(80), width: 0.5),
        ),
      );
}
