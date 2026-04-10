import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ═══════════════════════════════════════════════════════════════
  // CORE BRAND — shared across both themes
  // ═══════════════════════════════════════════════════════════════
  static const Color primaryTeal        = Color(0xFF00C9A7);
  static const Color primaryCyan        = Color(0xFF00A8E8);
  static const Color primaryDeep        = Color(0xFF005F8A);
  static const Color primaryMint        = Color(0xFF00E5C3);

  // ═══════════════════════════════════════════════════════════════
  // DARK THEME SURFACES
  // ═══════════════════════════════════════════════════════════════
  static const Color backgroundDark     = Color(0xFF0B1120);
  static const Color surfaceL0          = Color(0xFF0B1120);
  static const Color surfaceL1          = Color(0xFF111827);
  static const Color surfaceL2          = Color(0xFF1A2436);
  static const Color surfaceL3          = Color(0xFF222F45);

  // Glass (dark)
  static const Color glassLight         = Color(0x14FFFFFF);
  static const Color glassMedium        = Color(0x20FFFFFF);
  static const Color glassBorder        = Color(0x25FFFFFF);
  static const Color glassBorderLight   = Color(0x14FFFFFF);

  // Text (dark)
  static const Color textPrimary        = Color(0xFFF1F5F9);
  static const Color textSecondary      = Color(0xFF94A3B8);
  static const Color textMuted          = Color(0xFF475569);
  static const Color textOnGradient     = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════
  // LIGHT THEME SURFACES
  // ═══════════════════════════════════════════════════════════════
  static const Color backgroundLight    = Color(0xFFF4F7FB);
  static const Color surfaceL1Light     = Color(0xFFFFFFFF);
  static const Color surfaceL2Light     = Color(0xFFF0F4F8);
  static const Color surfaceL3Light     = Color(0xFFE8EDF4);

  // Glass (light)
  static const Color glassBorderLightMode = Color(0x25000000);
  static const Color glassBorderLightModeSubtle = Color(0x12000000);

  // Text (light)
  static const Color textPrimaryLight   = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight     = Color(0xFF94A3B8);

  // ═══════════════════════════════════════════════════════════════
  // SEMANTIC / ACCENT COLORS — shared
  // ═══════════════════════════════════════════════════════════════
  static const Color accentGreen        = Color(0xFF10B981);
  static const Color accentGreenLight   = Color(0xFF34D399);
  static const Color accentGreenDark    = Color(0xFF059669);
  static const Color accentRed          = Color(0xFFEF4444);
  static const Color accentRedDark      = Color(0xFFDC2626);
  static const Color accentOrange       = Color(0xFFF97316);
  static const Color accentOrangeDark   = Color(0xFFEA580C);
  static const Color accentYellow       = Color(0xFFFBBF24);
  static const Color accentPurple       = Color(0xFF8B5CF6);
  static const Color accentPurpleLight  = Color(0xFFA78BFA);
  static const Color accentBlue         = Color(0xFF3B82F6);
  static const Color accentBlueDark     = Color(0xFF2563EB);
  static const Color accentPink         = Color(0xFFEC4899);

  // ═══════════════════════════════════════════════════════════════
  // COMPAT ALIASES
  // ═══════════════════════════════════════════════════════════════
  static const Color cardDark           = surfaceL1;
  static const Color surfaceDark        = surfaceL1;

  // ═══════════════════════════════════════════════════════════════
  // HEALTH STATUS
  // ═══════════════════════════════════════════════════════════════
  static const Color statusNormal       = accentGreen;
  static const Color statusElevated     = accentYellow;
  static const Color statusHigh         = accentOrange;
  static const Color statusCritical     = accentRed;

  // ═══════════════════════════════════════════════════════════════
  // SPACING SYSTEM
  // ═══════════════════════════════════════════════════════════════
  static const double sp2  = 2;
  static const double sp4  = 4;
  static const double sp6  = 6;
  static const double sp8  = 8;
  static const double sp12 = 12;
  static const double sp16 = 16;
  static const double sp20 = 20;
  static const double sp24 = 24;
  static const double sp32 = 32;
  static const double sp40 = 40;
  static const double sp48 = 48;
  static const double sp64 = 64;

  // ═══════════════════════════════════════════════════════════════
  // BORDER RADII
  // ═══════════════════════════════════════════════════════════════
  static const double radiusSm  = 8;
  static const double radiusMd  = 12;
  static const double radiusLg  = 16;
  static const double radiusXl  = 20;
  static const double radiusXxl = 28;

  // ═══════════════════════════════════════════════════════════════
  // ANIMATION
  // ═══════════════════════════════════════════════════════════════
  static const Duration durationFast   = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow   = Duration(milliseconds: 500);
  static const Duration durationSplash = Duration(milliseconds: 800);
  static const Curve curveSmooth       = Curves.easeInOutCubic;
  static const Curve curveSpring       = Curves.elasticOut;

  // ═══════════════════════════════════════════════════════════════
  // GRADIENTS — shared
  // ═══════════════════════════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryTeal, primaryCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0B1120), Color(0xFF0D1526), Color(0xFF0B1120)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0B2A40), Color(0xFF0B1120)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF00C9A7), Color(0xFF0097C4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient healthGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient bpGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient sugarGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient weightGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient symptomsGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient activityGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient chatGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient stepsGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF00C9A7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient remindersGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient sleepGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient waterGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════════
  // SHADOWS
  // ═══════════════════════════════════════════════════════════════
  static List<BoxShadow> glowTeal({double blur = 24, double opacity = 0.3}) => [
    BoxShadow(color: primaryTeal.withValues(alpha: opacity), blurRadius: blur, spreadRadius: -6),
  ];
  static List<BoxShadow> glowRed({double blur = 20, double opacity = 0.3}) => [
    BoxShadow(color: accentRed.withValues(alpha: opacity), blurRadius: blur, spreadRadius: -6),
  ];
  static List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> cardShadowLight = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 3)),
  ];

  // ═══════════════════════════════════════════════════════════════
  // DARK THEME DATA
  // ═══════════════════════════════════════════════════════════════
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: primaryTeal,
    colorScheme: const ColorScheme.dark(
      primary: primaryTeal,
      secondary: primaryCyan,
      surface: surfaceL1,
      error: accentRed,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: textPrimary, letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: surfaceL1,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        elevation: 0,
        textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryTeal,
        side: const BorderSide(color: glassBorder, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceL2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: glassBorderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primaryTeal, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
      labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
      prefixIconColor: textMuted,
      suffixIconColor: textSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: _buildTextTheme(textPrimary, textSecondary, textMuted),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceL1,
      indicatorColor: primaryTeal.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: primaryTeal);
        }
        return GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: textMuted);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryTeal, size: 22);
        }
        return const IconThemeData(color: textMuted, size: 22);
      }),
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceL2,
      contentTextStyle: GoogleFonts.inter(color: textPrimary, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceL3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXl)),
      titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: textSecondary),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceL2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(color: glassBorderLight, thickness: 1),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? primaryTeal : textMuted),
      trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? primaryTeal.withValues(alpha: 0.3) : surfaceL3),
    ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );

  // ═══════════════════════════════════════════════════════════════
  // LIGHT THEME DATA
  // ═══════════════════════════════════════════════════════════════
  static ThemeData get lightTheme => ThemeData.light().copyWith(
    scaffoldBackgroundColor: backgroundLight,
    primaryColor: primaryTeal,
    colorScheme: const ColorScheme.light(
      primary: primaryTeal,
      secondary: primaryCyan,
      surface: surfaceL1Light,
      error: accentRed,
      onPrimary: Colors.white,
      onSurface: textPrimaryLight,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: textPrimaryLight, letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: textPrimaryLight),
    ),
    cardTheme: CardThemeData(
      color: surfaceL1Light,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        elevation: 0,
        textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryTeal,
        side: BorderSide(color: glassBorderLightMode, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceL2Light,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: glassBorderLightMode),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: glassBorderLightModeSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primaryTeal, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(color: textMutedLight, fontSize: 14),
      labelStyle: GoogleFonts.inter(color: textSecondaryLight, fontSize: 14),
      prefixIconColor: textMutedLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: _buildTextTheme(textPrimaryLight, textSecondaryLight, textMutedLight),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceL1Light,
      indicatorColor: primaryTeal.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: primaryTeal);
        }
        return GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: textMutedLight);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryTeal, size: 22);
        }
        return const IconThemeData(color: textMutedLight, size: 22);
      }),
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceL2Light,
      contentTextStyle: GoogleFonts.inter(color: textPrimaryLight, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceL3Light,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXl)),
      titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimaryLight),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: textSecondaryLight),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceL1Light,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(color: glassBorderLightModeSubtle, thickness: 1),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? primaryTeal : textMutedLight),
      trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? primaryTeal.withValues(alpha: 0.25) : surfaceL2Light),
    ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );

  // ═══════════════════════════════════════════════════════════════
  // SHARED TEXT THEME BUILDER
  // ═══════════════════════════════════════════════════════════════
  static TextTheme _buildTextTheme(Color primary, Color secondary, Color muted) {
    return TextTheme(
      displayLarge:   GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w800, color: primary, letterSpacing: -1.5),
      displayMedium:  GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w700, color: primary, letterSpacing: -1.0),
      headlineLarge:  GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5),
      headlineMedium: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.3),
      headlineSmall:  GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      titleLarge:     GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w600, color: primary),
      titleMedium:    GoogleFonts.inter(fontSize: 15,  fontWeight: FontWeight.w600, color: primary),
      titleSmall:     GoogleFonts.inter(fontSize: 13,  fontWeight: FontWeight.w500, color: secondary),
      bodyLarge:      GoogleFonts.inter(fontSize: 16,  fontWeight: FontWeight.w400, color: primary,   height: 1.6),
      bodyMedium:     GoogleFonts.inter(fontSize: 14,  fontWeight: FontWeight.w400, color: secondary, height: 1.5),
      bodySmall:      GoogleFonts.inter(fontSize: 12,  fontWeight: FontWeight.w400, color: muted,     height: 1.4),
      labelLarge:     GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: primary),
      labelMedium:    GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: secondary, letterSpacing: 0.5),
      labelSmall:     GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: muted,     letterSpacing: 1.0),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILITIES
  // ═══════════════════════════════════════════════════════════════
  static Color healthStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'normal': case 'optimal': case 'green': return statusNormal;
      case 'elevated': case 'yellow':               return statusElevated;
      case 'high': case 'orange':                   return statusHigh;
      case 'critical': case 'hypertensive': case 'red': return statusCritical;
      default: return const Color(0xFF94A3B8);
    }
  }

  static LinearGradient metricGradient(String metric) {
    switch (metric) {
      case 'bp':        return bpGradient;
      case 'sugar':     return sugarGradient;
      case 'weight':    return weightGradient;
      case 'symptoms':  return symptomsGradient;
      case 'steps':     return stepsGradient;
      case 'reminders': return remindersGradient;
      case 'chat':      return chatGradient;
      case 'sleep':     return sleepGradient;
      case 'water':     return waterGradient;
      default:          return primaryGradient;
    }
  }

  /// Card background color helper — picks the correct surface based on theme
  static Color cardBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? surfaceL1 : surfaceL1Light;
  }

  static Color cardBg2(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? surfaceL2 : surfaceL2Light;
  }

  static Color borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? glassBorderLight
        : glassBorderLightModeSubtle;
  }

  static Color textPrimaryOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? textPrimary : textPrimaryLight;

  static Color textSecondaryOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? textSecondary : textSecondaryLight;

  static Color textMutedOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? textMuted : textMutedLight;

  static Color bgOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? backgroundDark : backgroundLight;
}
