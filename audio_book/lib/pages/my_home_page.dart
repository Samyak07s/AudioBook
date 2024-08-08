import 'package:ebook/my_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart' as AppColors;
import 'dart:convert';
import 'book_detail.dart';
import 'LikedBooksPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{

  late List<dynamic> popularbook;
  late List<dynamic> book;
  late List<dynamic> likedBooks = [];
  late ScrollController _scrollController;
  late TabController _tabController;
  late TextEditingController _searchController;
  bool _isSearching = false;

  Future<void> ReadData()async{
    await DefaultAssetBundle.of(context).loadString('json/popbook.json').then((s){
      setState(() {
        popularbook= json.decode(s) as List<dynamic>;
      });
    });

    await DefaultAssetBundle.of(context).loadString('json/book.json').then((s){
      setState(() {
        book= json.decode(s) as List<dynamic>;
      });
    });
  }

  Future<void> _loadLikedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? likedBooksData = prefs.getStringList('liked_books');

    if (likedBooksData != null) {
      setState(() {
        likedBooks = likedBooksData.map((bookJson) => json.decode(bookJson)).toList();
      });
    }
  }

  @override
  void initState(){
    super.initState();
    _tabController=TabController(length: 3, vsync: this);
    _scrollController=ScrollController();
     _searchController = TextEditingController();
    ReadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  void _navigateTo(String route) {
    Navigator.pop(context); // Close the drawer
    // Navigate based on the selected route
    switch (route) {
      case 'Home':
        // Implement navigation to home if needed
        break;
      case 'Liked Books':
        // Navigate to liked books page
        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LikedBooksPage(),
  ),
);

        break;
      case 'Settings':
        // Navigate to settings page
        print("Setting button pressed");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppColors.sliverBackground,
                  ),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () => _navigateTo('Home'),
                ),
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('Liked Books'),
                  onTap: () => _navigateTo('Liked Books'),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () => _navigateTo('Settings'),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Top bar with menu, search, and notifications icons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: Icon(Icons.menu_rounded, size: 28, color: Colors.black),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    Row(
                      children: [
                         IconButton(
                          icon: Icon(Icons.search),
                          onPressed: _toggleSearch,
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.notifications),
                      ],
                    ),
                  ],
                ),
              ),
              if (_isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Enter Book name",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: _toggleSearch,
                      ),
                    ),
                    onSubmitted: (value) {
                      // Handle the search action
                      _toggleSearch();
                    },
                  ),
                ),
              SizedBox(height: 10),
              // Section title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Text("Popular Books", style: TextStyle(fontSize: 30)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // PageView for books Slideable one
              Container(
                height: 200,
                child: Stack(
                 children: [
                    Positioned(
                      top: 0,
                      left: -20,
                      right: 0,
                      child: Container(
                      height: 180,
                      child: PageView.builder(
                        controller: PageController(viewportFraction: 0.8),
                        itemCount: popularbook==null?0:popularbook.length,
                        itemBuilder: (_, i) {
                          return Container(
                            height: 180,
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage(popularbook[i]["img"]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                                        ),
                    ),
            ]
            ),
              ),
              //New Popular Trending..... buttons section

              //books scrollable section
              Expanded(child: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (BuildContext context,bool isScrolled) {
                  return[
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: AppColors.sliverBackground,
                      bottom: PreferredSize(preferredSize: Size.fromHeight(50), 
                       child: Container(height: 100,
                       child: Stack(
                            children: [
                              Positioned(
                                left: -20,
                                right:0,
                                child: TabBar(
                          indicatorPadding: const EdgeInsets.all(0),
                          indicatorSize: TabBarIndicatorSize.label, 
                          labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                          controller: _tabController,
                          isScrollable: true,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 7,
                                offset: Offset(0.0, 0.0),
                              )
                            ]
                          ),
                          tabs: [
                            AppTabs(color: AppColors.menu1Color, text: 'New'),
                            AppTabs(color: AppColors.menu2Color, text: 'Trending'),
                            AppTabs(color: AppColors.menu3Color, text: 'Popular'),
                          ],
                                ),
                              ),
                            ],
                          ),)
                        ),
                      ),
                    ];
                  },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    //new books list 
                    ListView.builder(
                      itemCount: book==null?0:book.length,
                      itemBuilder: (_,i){
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => BookDetailPage(book: book[i]),),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.tabVarViewColor,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 2,
                                  color: Colors.grey.withOpacity(0.2),
                                )
                              ]
                            ),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 120,
                                    decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(10),
                                       image: DecorationImage(
                                        image: AssetImage(book[i]["img"]),
                                        
                                       )
                                    )   ,
                                  ),
                                  SizedBox(width: 5,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 24, color:AppColors.starColor,),
                                          SizedBox(width: 5,),
                                          Text(book[i]["rating"], style: TextStyle(color: AppColors.menu2Color),)
                                        ],
                                      ),
                                      Text(book[i]["title"], style: TextStyle(fontSize: 16, fontFamily: "Avenir", fontWeight: FontWeight.bold),),
                                      Text(book[i]["text"], style: TextStyle(fontSize: 16, fontFamily: "Avenir", color: AppColors.subTitleText),),
                                      Container(
                                        width: 50,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3),
                                          color: AppColors.loveColor,
                                        ),
                                        child: Text('Love', style: TextStyle(fontSize: 10, color: Colors.white),)
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    //trending books list
                    ListView.builder(
                      itemCount: book==null?0:book.length,
                      itemBuilder: (_,i){
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => BookDetailPage(book: book[i]),),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.tabVarViewColor,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 2,
                                  color: Colors.grey.withOpacity(0.2),
                                )
                              ]
                            ),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 120,
                                    decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(10),
                                       image: DecorationImage(
                                        image: AssetImage(book[i]["img"]),
                                        
                                       )
                                    )   ,
                                  ),
                                  SizedBox(width: 5,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 24, color:AppColors.starColor,),
                                          SizedBox(width: 5,),
                                          Text(book[i]["rating"], style: TextStyle(color: AppColors.menu2Color),)
                                        ],
                                      ),
                                      Text(book[i]["title"], style: TextStyle(fontSize: 16, fontFamily: "Avenir", fontWeight: FontWeight.bold),),
                                      Text(book[i]["text"], style: TextStyle(fontSize: 16, fontFamily: "Avenir", color: AppColors.subTitleText),),
                                      Container(
                                        width: 50,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3),
                                          color: AppColors.loveColor,
                                        ),
                                        child: Text('Love', style: TextStyle(fontSize: 10, color: Colors.white),)
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    //popular books list
                    ListView.builder(
                      itemCount: book==null?0:book.length,
                      itemBuilder: (_,i){
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => BookDetailPage(book: book[i]),),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.tabVarViewColor,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 2,
                                  color: Colors.grey.withOpacity(0.2),
                                )
                              ]
                            ),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 120,
                                    decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(10),
                                       image: DecorationImage(
                                        image: AssetImage(book[i]["img"]),
                                        
                                       )
                                    )   ,
                                  ),
                                  SizedBox(width: 5,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 24, color:AppColors.starColor,),
                                          SizedBox(width: 5,),
                                          Text(book[i]["rating"], style: TextStyle(color: AppColors.menu2Color),)
                                        ],
                                      ),
                                      Text(book[i]["title"], style: TextStyle(fontSize: 16, fontFamily: "Avenir", fontWeight: FontWeight.bold),),
                                      Text(book[i]["text"], style: TextStyle(fontSize: 16, fontFamily: "Avenir", color: AppColors.subTitleText),),
                                      Container(
                                        width: 50,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3),
                                          color: AppColors.loveColor,
                                        ),
                                        child: Text('Love', style: TextStyle(fontSize: 10, color: Colors.white),)
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

