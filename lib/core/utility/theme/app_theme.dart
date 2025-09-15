import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryPurple = Color(0xFFB983FF);
  static const Color primaryPurpleDark = Color(0xFF8B5CF6);
  static const Color darkBackground = Color.fromARGB(255, 17, 0, 37);
  static const Color darkBackgroundSecondary = Color(0xFF2E0249);
  static const Color darkBackgroundTertiary = Color(0xFF3A0CA3);
  
  // Light Theme Colors
  static const Color lightBackground =  Color.fromARGB(255, 255, 255, 255);
  static const Color lightSurface = Color(0xFFF8F9FA);
  static const Color lightPrimary = Color(0xFF8E2DE2);
  static const Color lightSecondary = Color(0xFF4A00E0);
  
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    fontFamily: 'Manrope',
    
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightSecondary,
      surface: lightSurface,
      background: lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
    ),
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: Colors.black87,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: const Color.fromARGB(255, 185, 212, 238),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // // Input Decoration Theme
    // inputDecorationTheme: InputDecorationTheme(
    //   filled: true,
    //   fillColor: lightSurface,
    //   // border: OutlineInputBorder(
    //   //   borderRadius: BorderRadius.circular(12),
    //   //   borderSide: BorderSide.none,
    //   // ),
    //   // enabledBorder: OutlineInputBorder(
    //   //   borderRadius: BorderRadius.circular(12),
    //   //   // borderSide: BorderSide(color: Colors.grey.shade300),
    //   // ),
    //   // focusedBorder: OutlineInputBorder(
    //   //   borderRadius: BorderRadius.circular(12),
    //   //   // borderSide: const BorderSide(color: lightPrimary, width: 2),
    //   // ),
    //   // errorBorder: OutlineInputBorder(
    //   //   borderRadius: BorderRadius.circular(12),
    //   //   borderSide: BorderSide(color: Colors.red.shade300),
    //   // ),
    //   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    // ),

    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontFamily: 'Manrope'),
      bodyMedium: TextStyle(fontFamily: 'Manrope'),
      bodySmall: TextStyle(fontFamily: 'Manrope'),
      labelLarge: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontFamily: 'Manrope'),
      labelSmall: TextStyle(fontFamily: 'Manrope'),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: lightPrimary,
      unselectedItemColor: Colors.red,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: lightPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
      thickness: 1,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    fontFamily: 'Manrope',
    
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: primaryPurpleDark,
      surface: darkBackgroundSecondary,
      background: darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: darkBackgroundSecondary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 93, 65, 130),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // // Input Decoration Theme
    // inputDecorationTheme: InputDecorationTheme(
    //   filled: true,
    //   fillColor: darkBackgroundSecondary,
    //   border: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(12),
    //     borderSide: BorderSide.none,
    //   ),
    //   enabledBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(12),
    //     borderSide: BorderSide(color: Colors.grey.shade700),
    //   ),
    //   focusedBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(12),
    //     borderSide: const BorderSide(color: primaryPurple, width: 2),
    //   ),
    //   errorBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(12),
    //     borderSide: BorderSide(color: Colors.red.shade400),
    //   ),
    //   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    // ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, color: Colors.white),
      displaySmall: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, color: Colors.white),
      headlineLarge: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600, color: Colors.white),
      headlineMedium: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600, color: Colors.white),
      headlineSmall: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600, color: Colors.white),
      titleLarge: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w500, color: Colors.white),
      titleSmall: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w500, color: Colors.white),
      bodyLarge: TextStyle(fontFamily: 'Manrope', color: Colors.white),
      bodyMedium: TextStyle(fontFamily: 'Manrope', color: Colors.white),
      bodySmall: TextStyle(fontFamily: 'Manrope', color: Colors.white70),
      labelLarge: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w500, color: Colors.white),
      labelMedium: TextStyle(fontFamily: 'Manrope', color: Colors.white),
      labelSmall: TextStyle(fontFamily: 'Manrope', color: Colors.white70),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBackground,
      selectedItemColor: primaryPurple,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryPurple,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade700,
      thickness: 1,
    ),
    
    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: darkBackgroundSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkBackgroundSecondary,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
