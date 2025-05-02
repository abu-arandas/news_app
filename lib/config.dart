// Configuration file for News App

class Config {
  // API Keys
  static const String newsAPIKey = "c084c12135e54fdab36e95e3b1b4394b";
  static const String newsAPIBaseURL = "https://newsapi.org/v2";

  // Feature Flags
  static const bool enablePushNotifications = true;
  static const bool enableOfflineReading = true;
  static const bool enableDarkMode = true;

  // Cache Configuration
  static const int maxCacheAgeHours = 24;
  static const int maxArticlesToCache = 100;

  // App Information
  static const String appVersion = "1.0.0";
  static const String appName = "News App";
}

// Example config file
// To use this app, replace YOUR_NEWS_API_KEY_HERE with your actual News API key
// You can get a key from https://newsapi.org/
