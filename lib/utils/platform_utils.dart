// Platform utility functions for cross-platform compatibility
import 'package:flutter/foundation.dart';

class PlatformUtils {
  // Check if running on web platform
  static bool get isWeb => kIsWeb;
  
  // Check if running on mobile platform
  static bool get isMobile => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  
  // Check if running on desktop platform
  static bool get isDesktop => !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux);
  
  // Get platform-specific message
  static String get platformMessage {
    if (isWeb) return 'Running on Web';
    if (isMobile) return 'Running on Mobile';
    if (isDesktop) return 'Running on Desktop';
    return 'Unknown platform';
  }
}