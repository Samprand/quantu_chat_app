import 'package:flutter/material.dart';

import 'presentation/pages/ai_chat_page.dart';
import 'core/theme/chat_theme.dart';
import 'core/di/service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 App starting - initializing dependency injection...');
  
  // Initialize dependency injection
  await di.init();
  
  print('✅ Dependency injection initialized successfully');
  print('🎯 Starting MyApp...');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomChatTheme.primaryColor,
          primary: CustomChatTheme.primaryColor,
          secondary: CustomChatTheme.secondaryColor,
          surface: CustomChatTheme.bgWidget,
          background: CustomChatTheme.bgMain,
        ),
        useMaterial3: true,
        fontFamily: 'Inter', // Updated to use Inter font
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: CustomChatTheme.textDefault,
            fontFamily: 'Inter',
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: CustomChatTheme.textDefault,
            fontFamily: 'Inter',
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: CustomChatTheme.textSecondary,
            fontFamily: 'Inter',
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CustomChatTheme.textDefault,
            fontFamily: 'Inter',
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: CustomChatTheme.bgWidget,
          foregroundColor: CustomChatTheme.textDefault,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CustomChatTheme.textDefault,
            fontFamily: 'Inter',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomChatTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: CustomChatTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: CustomChatTheme.bgWidget,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: CustomChatTheme.borderBase, width: 1),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: CustomChatTheme.borderBase,
          thickness: 1,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomChatTheme.primaryColor,
          brightness: Brightness.dark,
          primary: CustomChatTheme.primaryColor,
          secondary: CustomChatTheme.secondaryColor,
          surface: CustomChatTheme.darkBgWidget,
          background: CustomChatTheme.darkBgMain,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: CustomChatTheme.darkTextDefault,
            fontFamily: 'Inter',
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: CustomChatTheme.darkTextDefault,
            fontFamily: 'Inter',
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: CustomChatTheme.darkPlaceholder,
            fontFamily: 'Inter',
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CustomChatTheme.darkTextDefault,
            fontFamily: 'Inter',
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: CustomChatTheme.darkBgWidget,
          foregroundColor: CustomChatTheme.darkTextDefault,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CustomChatTheme.darkTextDefault,
            fontFamily: 'Inter',
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const AIChatPage(),
    );
  }
}
