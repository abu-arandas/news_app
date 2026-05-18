import 'package:flutter/material.dart';
import 'package:news_app/config.dart';
import 'package:news_app/data/repositories/news_repository_impl.dart';
import 'package:news_app/domain/usecases/get_top_headlines_usecase.dart';
import 'package:news_app/presentation/providers/news_provider.dart';
import 'package:news_app/presentation/screens/home_screen.dart';
import 'package:news_app/presentation/screens/saved_articles_screen.dart';
import 'package:news_app/presentation/screens/search_screen.dart';
import 'package:news_app/utils/network_info.dart';
import 'package:news_app/utils/dio_interceptors.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

void main() {
  // Set up dependencies
  final dio = Dio(BaseOptions(
    baseUrl: Config.newsAPIBaseURL,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
  ));

  dio.interceptors.add(RetryInterceptor(dio));

  final networkInfo = NetworkInfo(InternetConnectionChecker.instance);
  final newsRepository = NewsRepositoryImpl(dio: dio, networkInfo: networkInfo);

  // Set up use cases
  final getTopHeadlinesUseCase = GetTopHeadlinesUseCase(newsRepository);
  final searchArticlesUseCase = SearchArticlesUseCase(newsRepository);
  final getSavedArticlesUseCase = GetSavedArticlesUseCase(newsRepository);
  final saveArticleUseCase = SaveArticleUseCase(newsRepository);
  final removeArticleUseCase = RemoveArticleUseCase(newsRepository);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => NewsProvider(
          getTopHeadlinesUseCase: getTopHeadlinesUseCase,
          searchArticlesUseCase: searchArticlesUseCase,
          getSavedArticlesUseCase: getSavedArticlesUseCase,
          saveArticleUseCase: saveArticleUseCase,
          removeArticleUseCase: removeArticleUseCase,
        ),
      ),
    ],
    child: const NewsApp(),
  ));
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/search': (context) => const SearchScreen(),
        '/saved': (context) => const SavedArticlesScreen(),
      },
    );
  }
}
