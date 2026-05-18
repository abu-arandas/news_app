import 'package:flutter/material.dart';
import 'package:news_app/presentation/providers/news_provider.dart';
import 'package:news_app/presentation/screens/article_detail_screen.dart';
import 'package:news_app/presentation/widgets/article_card.dart';
import 'package:news_app/presentation/widgets/category_filter.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> categories = [
    '',
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology',
  ];

  final List<String> categoryLabels = [
    'All',
    'Business',
    'Entertainment',
    'General',
    'Health',
    'Science',
    'Sports',
    'Technology',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final provider = context.read<NewsProvider>();
    Future.microtask(() {
      provider.fetchTopHeadlines();
      provider.loadSavedArticles();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final newsProvider = context.read<NewsProvider>();
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        newsProvider.hasMorePages &&
        newsProvider.headlinesStatus != NewsStatus.loading) {
      newsProvider.fetchTopHeadlines();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News App'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.pushNamed(context, '/saved');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          CategoryFilter(
            categories: categories,
            categoryLabels: categoryLabels,
            onCategorySelected: (category) {
              context.read<NewsProvider>().fetchTopHeadlines(
                    category: category,
                    refresh: true,
                  );
            },
          ),

          // News content
          Expanded(
            child: Consumer<NewsProvider>(
              builder: (context, newsProvider, child) {
                final status = newsProvider.headlinesStatus;
                final articles = newsProvider.headlines;

                if (status == NewsStatus.initial) {
                  return const Center(
                    child: Text('Select a category to view headlines'),
                  );
                } else if (status == NewsStatus.loading && articles.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (status == NewsStatus.error && articles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed to load headlines'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            newsProvider.fetchTopHeadlines(refresh: true);
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await newsProvider.fetchTopHeadlines(refresh: true);
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: articles.length + (newsProvider.hasMorePages ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == articles.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final article = articles[index];
                        return ArticleCard(
                          article: article,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArticleDetailScreen(article: article),
                              ),
                            );
                          },
                          onSaveToggle: () {
                            if (newsProvider.isArticleSaved(article.id)) {
                              newsProvider.removeSavedArticle(article.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Article removed from saved'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              newsProvider.saveArticle(article);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Article saved for later'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          isSaved: newsProvider.isArticleSaved(article.id),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
