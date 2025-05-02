import 'package:flutter/material.dart';
import 'package:news_app/domain/entities/article.dart';
import 'package:news_app/domain/usecases/get_top_headlines_usecase.dart';

enum NewsStatus { initial, loading, loaded, error }

class NewsProvider extends ChangeNotifier {
  final GetTopHeadlinesUseCase getTopHeadlinesUseCase;
  final SearchArticlesUseCase searchArticlesUseCase;
  final GetSavedArticlesUseCase getSavedArticlesUseCase;
  final SaveArticleUseCase saveArticleUseCase;
  final RemoveArticleUseCase removeArticleUseCase;

  NewsProvider({
    required this.getTopHeadlinesUseCase,
    required this.searchArticlesUseCase,
    required this.getSavedArticlesUseCase,
    required this.saveArticleUseCase,
    required this.removeArticleUseCase,
  });

  // Top Headlines
  List<Article> _headlines = [];
  List<Article> get headlines => _headlines;

  NewsStatus _headlinesStatus = NewsStatus.initial;
  NewsStatus get headlinesStatus => _headlinesStatus;

  String _headlinesError = '';
  String get headlinesError => _headlinesError;

  // Search Results
  List<Article> _searchResults = [];
  List<Article> get searchResults => _searchResults;

  NewsStatus _searchStatus = NewsStatus.initial;
  NewsStatus get searchStatus => _searchStatus;

  String _searchError = '';
  String get searchError => _searchError;

  // Saved Articles
  List<Article> _savedArticles = [];
  List<Article> get savedArticles => _savedArticles;

  NewsStatus _savedArticlesStatus = NewsStatus.initial;
  NewsStatus get savedArticlesStatus => _savedArticlesStatus;

  String _savedArticlesError = '';
  String get savedArticlesError => _savedArticlesError;

  // Current category and country
  String _currentCategory = '';
  String get currentCategory => _currentCategory;

  String _currentCountry = 'us';
  String get currentCountry => _currentCountry;

  // Pagination
  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  // Fetch top headlines
  Future<void> fetchTopHeadlines({
    String? country,
    String? category,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePages = true;
    }

    if (country != null) _currentCountry = country;
    if (category != null) _currentCategory = category;

    if (_headlinesStatus == NewsStatus.loading || (!_hasMorePages && !refresh)) {
      return;
    }

    _headlinesStatus = NewsStatus.loading;
    if (_currentPage == 1) {
      _headlines = [];
    }
    notifyListeners();

    try {
      final articles = await getTopHeadlinesUseCase.execute(
        country: _currentCountry,
        category: _currentCategory,
        page: _currentPage,
      );

      if (articles.isEmpty) {
        _hasMorePages = false;
      } else {
        if (_currentPage == 1) {
          _headlines = articles;
        } else {
          _headlines.addAll(articles);
        }
        _currentPage++;
      }

      _headlinesStatus = NewsStatus.loaded;
    } catch (e) {
      _headlinesStatus = NewsStatus.error;
      _headlinesError = e.toString();
    }

    notifyListeners();
  }

  // Search articles
  Future<void> searchArticles(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchStatus = NewsStatus.initial;
      notifyListeners();
      return;
    }

    _searchStatus = NewsStatus.loading;
    notifyListeners();

    try {
      final articles = await searchArticlesUseCase.execute(query: query);
      _searchResults = articles;
      _searchStatus = NewsStatus.loaded;
    } catch (e) {
      _searchStatus = NewsStatus.error;
      _searchError = e.toString();
    }

    notifyListeners();
  }

  // Load saved articles
  Future<void> loadSavedArticles() async {
    _savedArticlesStatus = NewsStatus.loading;
    notifyListeners();

    try {
      final articles = await getSavedArticlesUseCase.execute();
      _savedArticles = articles;
      _savedArticlesStatus = NewsStatus.loaded;
    } catch (e) {
      _savedArticlesStatus = NewsStatus.error;
      _savedArticlesError = e.toString();
    }

    notifyListeners();
  }

  // Save article
  Future<void> saveArticle(Article article) async {
    try {
      await saveArticleUseCase.execute(article);
      if (!_savedArticles.any((a) => a.id == article.id)) {
        _savedArticles.add(article);
        notifyListeners();
      }
    } catch (e) {
      _savedArticlesError = e.toString();
      notifyListeners();
    }
  }

  // Remove saved article
  Future<void> removeSavedArticle(String articleId) async {
    try {
      await removeArticleUseCase.execute(articleId);
      _savedArticles.removeWhere((a) => a.id == articleId);
      notifyListeners();
    } catch (e) {
      _savedArticlesError = e.toString();
      notifyListeners();
    }
  }

  // Check if article is saved
  bool isArticleSaved(String articleId) {
    return _savedArticles.any((article) => article.id == articleId);
  }
}
