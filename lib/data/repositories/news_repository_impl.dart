import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:news_app/config.dart';
import 'package:news_app/data/models/article_model.dart';
import 'package:news_app/domain/entities/article.dart';
import 'package:news_app/domain/repositories/news_repository.dart';
import 'package:news_app/utils/network_info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NewsRepositoryImpl implements NewsRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;
  Database? _database;
  Future<void>? _dbInitFuture;

  NewsRepositoryImpl({required Dio dio, NetworkInfo? networkInfo})
      : _dio = dio,
        _networkInfo = networkInfo ?? NetworkInfo(InternetConnectionChecker.instance);

  Future<void> _initDatabase() async {
    if (_database != null) return;
    _dbInitFuture ??= _initDatabaseInternal();
    return _dbInitFuture;
  }

  Future<void> _initDatabaseInternal() async {
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
  }

  @override
  Future<List<Article>> getTopHeadlines({
    String country = 'us',
    String category = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await _dio.get(
        '/top-headlines',
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
    } on DioException {
      rethrow;
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
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await _dio.get(
        '/everything',
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
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to search articles: $e');
    }
  }

  @override
  Future<List<Article>> getSavedArticles() async {
    await _initDatabase();
    final db = _database!;

    final List<Map<String, dynamic>> maps = await db.query('articles');

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
    final db = _database!;

    await db.insert(
      'articles',
      {
        'id': article.id,
        'title': article.title,
        'description': article.description,
        'url': article.url,
        'urlToImage': article.urlToImage,
        'publishedAt': article.publishedAt,
        'content': article.content,
        'author': article.author,
        'sourceName': article.sourceName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeArticle(String articleId) async {
    await _initDatabase();
    final db = _database!;

    await db.delete(
      'articles',
      where: 'id = ?',
      whereArgs: [articleId],
    );
  }
}
