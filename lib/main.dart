import 'package:flutter/material.dart';
import 'package:news_app/config.dart';
import 'package:news_app/data/repositories/news_repository_impl.dart';
import 'package:news_app/domain/usecases/get_top_headlines_usecase.dart';
import 'package:news_app/presentation/providers/news_provider.dart';
import 'package:news_app/presentation/screens/home_screen.dart';
import 'package:news_app/presentation/screens/saved_articles_screen.dart';
import 'package:news_app/presentation/screens/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

void main() {
  // Set up dependencies
  final dio = Dio();
  final newsRepository = NewsRepositoryImpl(dio: dio);

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
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
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
