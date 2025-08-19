import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class CustomChatTheme {
  // Color palette from user's CSS variables
  static const Color primaryColor = Color(0xFFfb4601);     // --color-primary
  static const Color secondaryColor = Color(0xFFff8c1f);   // --color-secondary
  static const Color tertiaryColor = Color(0xFFfa5757);    // --color-tertiary
  
  static const Color darkColor = Color(0xFF000000);        // --color-dark
  static const Color lightColor = Color(0xFFfafafa);       // --color-light
  
  static const Color textDefault = Color(0xFF343434);      // --text-default
  static const Color textSecondary = Color(0xFF747474);    // --text-secondary
  static const Color placeholder = Color(0xFFafafaf);      // --placeholder
  
  static const Color borderBase = Color(0xFFe9e9e9);       // --border-base
  static const Color borderDark = Color(0xFF404040);       // --border-dark
  
  static const Color bgMain = Color(0xFFfafafc);           // --bg-main
  static const Color bgWidget = Color(0xFFffffff);         // --bg-widget
  static const Color bgWidgetBlue = Color(0xFFe4f5ff);     // --bg-widget-blue
  static const Color bgWidgetGray = Color(0xFFe5edf5);     // --bg-widget-gray
  static const Color bgWidgetDark = Color(0xFF292d30);     // --bg-widget-dark

  // Dark theme colors
  static const Color darkTextDefault = Color(0xFFffffff);
  static const Color darkBorderBase = Color(0xFF292d30);
  static const Color darkBgMain = Color(0xFF212121);
  static const Color darkBgWidget = Color(0xFF090806);
  static const Color darkBgWidgetBlue = Color(0xFF032822);
  static const Color darkBgWidgetGray = Color(0xFF090806);
  static const Color darkPlaceholder = Color(0xFF8d8d8d);

  static DefaultChatTheme getLightTheme() {
    return const DefaultChatTheme(
      // Background colors
      backgroundColor: bgMain,
      primaryColor: primaryColor,
      secondaryColor: bgWidgetGray,
      
      // Input theme
      inputBackgroundColor: bgWidget,
      inputBorderRadius: BorderRadius.all(Radius.circular(24)),
      inputTextColor: textDefault,
      inputTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textDefault,
        fontFamily: 'Inter',
      ),
      inputPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      inputMargin: EdgeInsets.all(16),
      
      // Message themes
      sentMessageBodyTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      ),
      receivedMessageBodyTextStyle: TextStyle(
        color: textDefault,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      ),
      
      // Typography
      dateDividerTextStyle: TextStyle(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
      
      // User avatar colors
      userAvatarNameColors: [primaryColor, secondaryColor, tertiaryColor],
      
      // Send button styling
      sendButtonIcon: Icon(
        Icons.send_rounded,
        color: primaryColor,
        size: 26,
      ),
      
      // Input decoration
      inputTextDecoration: InputDecoration(
        hintText: 'Ask Anything',
        hintStyle: TextStyle(
          color: placeholder,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'Inter',
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: true,
        fillColor: bgWidget,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      
      // Message spacing
      messageInsetsHorizontal: 16,
      messageInsetsVertical: 8,
    );
  }

  static DefaultChatTheme getDarkTheme() {
    return const DefaultChatTheme(
      // Background colors
      backgroundColor: darkBgMain,
      primaryColor: primaryColor,
      secondaryColor: darkBgWidgetGray,
      
      // Input theme - dark rounded input like in the image
      inputBackgroundColor: Color(0xFF3A3A3A), // Darker gray for input
      inputBorderRadius: BorderRadius.all(Radius.circular(30)),
      inputTextColor: darkTextDefault,
      inputTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: darkTextDefault,
        fontFamily: 'Inter',
      ),
      inputPadding: EdgeInsets.only(left: 60, right: 60, top: 14, bottom: 14), // Space for left icon and right button
      inputMargin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      
      // Message themes
      sentMessageBodyTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      ),
      receivedMessageBodyTextStyle: TextStyle(
        color: darkTextDefault,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      ),
      
      // Typography
      dateDividerTextStyle: TextStyle(
        color: darkPlaceholder,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
      
      // User avatar colors
      userAvatarNameColors: [primaryColor, secondaryColor, tertiaryColor],
      
      // Send button styling - using arrow icon
      sendButtonIcon: Icon(
        Icons.arrow_forward,
        color: Colors.white,
        size: 20,
      ),
      
      // Input decoration - custom styling to match image
      inputTextDecoration: InputDecoration(
        hintText: 'Ask Anything',
        hintStyle: TextStyle(
          color: Color(0xFF8A8A8A), // Lighter gray for hint
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'Inter',
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: true,
        fillColor: Color(0xFF3A3A3A), // Dark gray background
        contentPadding: EdgeInsets.only(left: 60, right: 60, top: 14, bottom: 14),
      ),
      
      // Message spacing
      messageInsetsHorizontal: 16,
      messageInsetsVertical: 8,
    );
  }
} 