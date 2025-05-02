import 'package:news_app/domain/entities/article.dart';

abstract class NewsRepository {
  /// Get top headlines from the News API
  ///
  /// [country] is the 2-letter ISO 3166-1 code of the country (e.g. 'us', 'gb')
  /// [category] is the category to get headlines for (e.g. 'business', 'technology')
  Future<List<Article>> getTopHeadlines({
    String country = 'us',
    String category = '',
    int page = 1,
    int pageSize = 20,
  });

  /// Search for articles
  ///
  /// [query] is the search query
  Future<List<Article>> searchArticles({
    required String query,
    int page = 1,
    int pageSize = 20,
  });

  /// Get saved articles for offline reading
  Future<List<Article>> getSavedArticles();

  /// Save an article for offline reading
  Future<void> saveArticle(Article article);

  /// Remove an article from saved articles
  Future<void> removeArticle(String articleId);
}
