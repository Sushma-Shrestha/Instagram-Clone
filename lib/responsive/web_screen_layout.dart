import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/models/user_model.dart' as _user;
import 'package:instagram_clone/screens/screens.dart';
import 'package:mdi/mdi.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../utils/global_variables.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({Key? key}) : super(key: key);

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
  int _page = 0;
  late PageController pageController;
  final searchController = TextEditingController();
  bool isSearch = false;
  bool isShowUsers = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    searchController.dispose();
  }

  void onTap(int page) {
    pageController.jumpToPage(page);
    setState(() {
      _page = page;
    });
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final _user.User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: mobileBackgroundColor,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'Assets/ic_instagram.svg',
                color: Colors.white,
                height: 32,
              ),
              SizedBox(
                width: width * 0.095,
              ),
              SizedBox(
                width: 250,
                height: 35,
                child: TextField(
                  onChanged: (data) {
                    setState(() {
                      isSearch = true;
                    });
                  },
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  cursorWidth: 1,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                      suffixIcon: isSearch
                          ? Container(
                              margin: const EdgeInsets.all(10),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSearch = false;
                                    searchController.text = '';
                                  });
                                },
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : null,
                      contentPadding: const EdgeInsets.all(10),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      fillColor: Colors.grey,
                      focusColor: Colors.white,
                      hintText: 'Search '),
                ),
              ),
              SizedBox(
                width: width * 0.095,
              ),
              IconButton(
                iconSize: 30,
                onPressed: () {
                  onTap(0);
                },
                icon: Icon(
                  Icons.home,
                  color: _page == 0 ? primaryColor : secondaryColor,
                ),
              ),
              IconButton(
                iconSize: 30,
                onPressed: () {
                  onTap(1);
                },
                icon: Icon(
                  Mdi.facebookMessenger,
                  color: _page == 1 ? primaryColor : secondaryColor,
                ),
              ),
              IconButton(
                iconSize: 30,
                onPressed: () {
                  onTap(2);
                },
                icon: Icon(
                  Mdi.compassOutline,
                  color: _page == 2 ? primaryColor : secondaryColor,
                ),
              ),
              IconButton(
                iconSize: 30,
                onPressed: () {
                  onTap(3);
                },
                icon: Icon(
                  Icons.add_circle_outline,
                  color: _page == 3 ? primaryColor : secondaryColor,
                ),
              ),
              IconButton(
                iconSize: 30,
                onPressed: () {
                  onTap(4);
                },
                icon: Icon(
                  Mdi.heartOutline,
                  color: _page == 4 ? primaryColor : secondaryColor,
                ),
              ),
              TextButton(
                  onPressed: () {
                    onTap(5);
                  },
                  child: CircleAvatar(
                    radius: 14,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  )),
            ],
          )),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isSearch = false;
              });
            },
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              children:
                  width > webScreenSize ? webHomeScreenItems : homeScreenItems,
              controller: pageController,
            ),
          ),
          isSearch
              ? Positioned(
                  right: width * 0.4,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[700]),
                    height: 300,
                    width: width * 0.3,
                    child: SearchScreen(
                      searchData: searchController.text,
                      isMessage: true,
                    ),
                  ),
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }
}
