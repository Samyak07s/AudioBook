import 'package:flutter/material.dart';
import 'app_colors.dart' as AppColors;
import 'book_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LikedBooksPage extends StatefulWidget {
  @override
  _LikedBooksPageState createState() => _LikedBooksPageState();
}

class _LikedBooksPageState extends State<LikedBooksPage> {
  List<dynamic> likedBooks = [];

  @override
  void initState() {
    super.initState();
    _loadLikedBooks();
  }

  Future<void> _loadLikedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? likedBooksData = prefs.getStringList('liked_books');
    setState(() {
      likedBooks = likedBooksData != null
          ? likedBooksData.map((bookJson) => json.decode(bookJson)).toList()
          : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liked Books'),
        backgroundColor: AppColors.sliverBackground,
      ),
      body: likedBooks.isEmpty
          ? Center(child: Text('No liked books yet!'))
          : ListView.builder(
              itemCount: likedBooks.length,
              itemBuilder: (context, index) {
                var book = likedBooks[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailPage(book: book),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.tabVarViewColor,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 2,
                          color: Colors.grey.withOpacity(0.2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: AssetImage(book["img"]),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, size: 24, color: AppColors.starColor),
                                SizedBox(width: 5),
                                Text(book["rating"],
                                    style: TextStyle(color: AppColors.menu2Color)),
                              ],
                            ),
                            Text(
                              book["title"],
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Avenir",
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              book["text"],
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Avenir",
                                  color: AppColors.subTitleText),
                            ),
                            Container(
                              width: 50,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: AppColors.loveColor,
                              ),
                              child: Text(
                                "Love",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Avenir",
                                    color: Colors.white),
                              ),
                              alignment: Alignment.center,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
