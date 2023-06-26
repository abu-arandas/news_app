import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api.dart';

class ArticleDetails extends StatelessWidget {
  final Article article;
  const ArticleDetails({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.title!)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: SlideOpacityTransition(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 15,
                      width: 3,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatDate(article.publishedAt.toString()),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.source.name!,
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                article.title ?? "",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16).copyWith(top: 0),
              child: const Text(
                "Description:",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(article.description ?? "", textAlign: TextAlign.justify),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Read News",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            article.urlToImage == null
                ? Container(
                    margin: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: MediaQuery.of(context).size.height / 3,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Image Preview Unavailable"),
                  )
                : Container(
                    margin: const EdgeInsets.all(16),
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: MediaQuery.of(context).size.height / 3,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        image: DecorationImage(
                          image: NetworkImage(article.urlToImage!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(20)),
                  ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(article.content ?? "", textAlign: TextAlign.justify),
            ),
            if (article.url != null)
              TextButton(
                onPressed: () async => await launchUrl(Uri.parse(article.url!)),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Got to Source Link",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SlideOpacityTransition extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  const SlideOpacityTransition({Key? key, required this.child, this.duration}) : super(key: key);

  @override
  State<SlideOpacityTransition> createState() => _SlideOpacityTransitionState();
}

class _SlideOpacityTransitionState extends State<SlideOpacityTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  final slideTween = Tween<Offset>(begin: const Offset(1, 0.15), end: Offset.zero);

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 700),
    );
    controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: widget.child,
      builder: (_, child) {
        return Opacity(
          opacity: controller.value,
          child: SlideTransition(
            position: slideTween.animate(controller),
            child: child!,
          ),
        );
      },
    );
  }
}

String formatDate(String dateString) {
  final DateTime dateTime = DateTime.parse(dateString);
  final DateFormat formatter = DateFormat("MMMM dd, yyyy");
  final String formattedDate = formatter.format(dateTime);

  return formattedDate;
}
