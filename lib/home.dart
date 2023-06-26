import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'api.dart';
import 'details.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String country = 'ae';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(title: const Text("Find the Latest News Updates")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Heading
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Top Headlines",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff121212),
                    ),
                  ),
                  PopupMenuButton(
                    onSelected: (value) => setState(() => country = value),
                    child: const Text(
                      "Select a Country",
                      style: TextStyle(fontSize: 14, color: Color(0xff121212)),
                    ),
                    itemBuilder: (context) => RestAPI.countries
                        .map((country) => PopupMenuItem(
                              value: country['code'],
                              child: Text(country['name']!),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future: RestAPI.fetchTopHeadline(country),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CarouselSlider.builder(
                    itemCount: snapshot.data!.articles!.length,
                    options: CarouselOptions(
                      autoPlay: true,
                      height: MediaQuery.of(context).size.height / 3.5,
                    ),
                    itemBuilder: (context, index, realIndex) => Stack(
                      children: [
                        snapshot.data!.articles![index].urlToImage == null
                            ? Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(right: 20),
                                width: MediaQuery.of(context).size.width / 1.2,
                                height: MediaQuery.of(context).size.height / 3,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text(
                                  "Image Preview Unavailable",
                                  style: TextStyle(fontSize: 14, color: Colors.white),
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width / 1.2,
                                height: MediaQuery.of(context).size.height / 3,
                                margin: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorDark,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        snapshot.data!.articles![index].urlToImage.toString()),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            margin: const EdgeInsets.only(right: 20),
                            height: MediaQuery.of(context).size.height / 13,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    snapshot.data!.articles![index].title.toString(),
                                    style: const TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ArticleDetails(article: snapshot.data!.articles![index]),
                                    ),
                                  ),
                                  icon: const Icon(Icons.info, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),

            // General
            Padding(
              padding: const EdgeInsets.all(20).copyWith(bottom: 0),
              child: const Text(
                "General News",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff121212),
                ),
              ),
            ),
            FutureBuilder(
              future: RestAPI.fetchGeneralNews(country),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.articles!.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data!.articles![i].title.toString(),
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      snapshot.data!.articles![i].source.name.toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ArticleDetails(article: snapshot.data!.articles![i]),
                                        ),
                                      ),
                                      child: const Text('Read More'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: snapshot.data!.articles![i].urlToImage != null
                                    ? Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              snapshot.data!.articles![i].urlToImage.toString(),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      )
                                    : Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Theme.of(context).primaryColorDark,
                                  Theme.of(context).dividerColor,
                                  Colors.transparent
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
