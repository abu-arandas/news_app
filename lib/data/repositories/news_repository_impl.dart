import 'package:dio/dio.dart';
import 'package:news_app/config.dart';
import 'package:news_app/data/models/article_model.dart';
import 'package:news_app/domain/entities/article.dart';
import 'package:news_app/domain/repositories/news_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NewsRepositoryImpl implements NewsRepository {
  final Dio _dio;
  late Database _database;
  bool _isDatabaseInitialized = false;

  NewsRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio() {
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    if (_isDatabaseInitialized) return;

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'news_app.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE articles(id TEXT PRIMARY KEY, title TEXT, description TEXT, url TEXT, urlToImage TEXT, publishedAt TEXT, content TEXT, author TEXT, sourceName TEXT)');
      },
    );

    _isDatabaseInitialized = true;
  }

  @override
  Future<List<Article>> getTopHeadlines({
    String country = 'us',
    String category = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '${Config.newsAPIBaseURL}/top-headlines',
        queryParameters: {
          'apiKey': Config.newsAPIKey,
          'country': country,
          if (category.isNotEmpty) 'category': category,
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> articlesJson = response.data['articles'];
        return articlesJson.map((json) => ArticleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load top headlines');
      }
    } catch (e) {
      throw Exception('Failed to load top headlines: $e');
    }
  }

  @override
  Future<List<Article>> searchArticles({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '${Config.newsAPIBaseURL}/everything',
        queryParameters: {
          'apiKey': Config.newsAPIKey,
          'q': query,
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> articlesJson = response.data['articles'];
        return articlesJson.map((json) => ArticleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search articles');
      }
    } catch (e) {
      throw Exception('Failed to search articles: $e');
    }
  }

  @override
  Future<List<Article>> getSavedArticles() async {
    await _initDatabase();

    final List<Map<String, dynamic>> maps = await _database.query('articles');

    return List.generate(maps.length, (i) {
      return ArticleModel(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        url: maps[i]['url'],
        urlToImage: maps[i]['urlToImage'],
        publishedAt: maps[i]['publishedAt'],
        content: maps[i]['content'],
        author: maps[i]['author'],
        sourceName: maps[i]['sourceName'],
      );
    });
  }

  @override
  Future<void> saveArticle(Article article) async {
    await _initDatabase();

    await _database.insert(
      'articles',
      (article as ArticleModel).toJson()..addAll({'id': article.id}),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeArticle(String articleId) async {
    await _initDatabase();

    await _database.delete(
      'articles',
      where: 'id = ?',
      whereArgs: [articleId],
    );
  }
}
