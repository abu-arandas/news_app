import 'package:flutter/material.dart';
import 'package:news_app/domain/entities/article.dart';
import 'package:news_app/presentation/providers/news_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // Format the published date
    String formattedDate = '';
    try {
      final dateTime = DateTime.parse(article.publishedAt);
      formattedDate = DateFormat('MMMM dd, yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      formattedDate = article.publishedAt;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(article.sourceName),
        elevation: 0,
        actions: [
          Consumer<NewsProvider>(
            builder: (context, newsProvider, child) {
              final isSaved = newsProvider.isArticleSaved(article.id);
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? Colors.blue : null,
                ),
                onPressed: () {
                  if (isSaved) {
                    newsProvider.removeSavedArticle(article.id);
                  } else {
                    newsProvider.saveArticle(article);
                  }
                },
                tooltip: isSaved ? 'Remove from saved' : 'Save for later',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                'Check out this article: ${article.title}\n${article.url}',
                subject: article.title,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article image
            if (article.urlToImage.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: Image.network(
                  article.urlToImage,
                  fit: BoxFit.cover,
                  height: 250,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 50),
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Author and date
                  Text(
                    'By ${article.author} | $formattedDate',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (article.description.isNotEmpty) ...[
                    Text(
                      article.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Content
                  Text(
                    article.content,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Read more button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final Uri url = Uri.parse(article.url);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open article URL')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Read Full Article'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
