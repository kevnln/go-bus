import 'package:flutter/material.dart';
import '../presentation/ai_chatbot_screen/ai_chatbot_screen.dart';

import '../presentation/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  static const String aiChatbotScreen = '/ai_chatbot_screen';

  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
        aiChatbotScreen: (context) => AiChatbotScreen(),
        appNavigationScreen: (context) => AppNavigationScreen(),
        initialRoute: (context) => AppNavigationScreen()
      };
}
