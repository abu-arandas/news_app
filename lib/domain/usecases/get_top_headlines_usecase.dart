import 'package:news_app/domain/entities/article.dart';
import 'package:news_app/domain/repositories/news_repository.dart';

class GetTopHeadlinesUseCase {
  final NewsRepository repository;

  GetTopHeadlinesUseCase(this.repository);

  Future<List<Article>> execute({
    String country = 'us',
    String category = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    return await repository.getTopHeadlines(
      country: country,
      category: category,
      page: page,
      pageSize: pageSize,
    );
  }
}

class SearchArticlesUseCase {
  final NewsRepository repository;

  SearchArticlesUseCase(this.repository);

  Future<List<Article>> execute({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await repository.searchArticles(
      query: query,
      page: page,
      pageSize: pageSize,
    );
  }
}

class GetSavedArticlesUseCase {
  final NewsRepository repository;

  GetSavedArticlesUseCase(this.repository);

  Future<List<Article>> execute() async {
    return await repository.getSavedArticles();
  }
}

class SaveArticleUseCase {
  final NewsRepository repository;

  SaveArticleUseCase(this.repository);

  Future<void> execute(Article article) async {
    return await repository.saveArticle(article);
  }
}

class RemoveArticleUseCase {
  final NewsRepository repository;

  RemoveArticleUseCase(this.repository);

  Future<void> execute(String articleId) async {
    return await repository.removeArticle(articleId);
  }
}
