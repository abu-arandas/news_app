import 'package:dio/dio.dart';

class RestAPI {
  static Future<NewsModel> fetchTopHeadline(String country) async {
    Response response = await Dio().get(
      'https://newsapi.org/v2/top-headlines?country=$country&category=business&apiKey=c084c12135e54fdab36e95e3b1b4394b',
    );

    return NewsModel.fromJson(response.data);
  }

  static Future<NewsModel> fetchGeneralNews(String country) async {
    Response response = await Dio().get(
      'https://newsapi.org/v2/everything?domains=wsj.com&apiKey=c084c12135e54fdab36e95e3b1b4394b',
    );

    return NewsModel.fromJson(response.data);
  }

  static List<Map<String, String>> countries = [
    {'code': 'ae', 'name': 'United Arab Emirates'},
    {'code': 'ar', 'name': 'Argentina'},
    {'code': 'au', 'name': 'Australia'},
    {'code': 'at', 'name': 'Austria'},
    {'code': 'be', 'name': 'Belgium'},
    {'code': 'bg', 'name': 'Bulgaria'},
    {'code': 'br', 'name': 'Brazil'},
    {'code': 'ca', 'name': 'Canada'},
    {'code': 'ch', 'name': 'Switzerland'},
    {'code': 'cn', 'name': 'China'},
    {'code': 'co', 'name': 'Colombia'},
    {'code': 'cz', 'name': 'Czech Republic'},
    {'code': 'de', 'name': 'Germany'},
    {'code': 'eg', 'name': 'Egypt'},
    {'code': 'fr', 'name': 'France'},
    {'code': 'gb', 'name': 'United Kingdom'},
    {'code': 'gr', 'name': 'Greece'},
  ];
}

class NewsModel {
  String? status;
  int? totalResults;
  List<Article>? articles;

  NewsModel({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
        status: json["status"],
        totalResults: json["totalResults"],
        articles: List<Article>.from(json["articles"].map((x) => Article.fromJson(x))),
      );
}

class Article {
  Source source;
  String? author;
  String? title;
  String? description;
  String? url;
  String? urlToImage;
  DateTime? publishedAt;
  String? content;

  Article({
    required this.source,
    this.author,
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    required this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        source: Source.fromJson(json["source"]),
        author: json["author"],
        title: json["title"],
        description: json["description"],
        url: json["url"],
        urlToImage: json["urlToImage"],
        publishedAt: DateTime.parse(json["publishedAt"]),
        content: json["content"],
      );
}

class Source {
  String? id, name;

  Source({this.id, required this.name});

  factory Source.fromJson(Map<String, dynamic> json) => Source(
        id: json["id"],
        name: json["name"],
      );
}
