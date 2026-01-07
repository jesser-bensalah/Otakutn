import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../providers/auth_provider.dart';
import '../providers/anime_provider.dart';
import '../models/anime.dart';
import '../screens/anime/anime_list_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Anime List'),
              floating: true,
              pinned: true,
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (String value) async {
                    switch (value) {
                      case 'favorites':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FavoritesScreen()),
                        );
                        break;
                      case 'settings':
                        // Navigate to settings screen
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                        break;
                      case 'logout':
                        await context.read<AuthProvider>().signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'favorites',
                      child: Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Favorites'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings, size: 20),
                          SizedBox(width: 8),
                          Text('Settings'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search anime...',
                      hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      if (context.mounted) {
                        Provider.of<AnimeProvider>(context, listen: false).searchAnimes(value);
                      }
                    },
                  ),
                ),
              ),
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            // Carousel Section
            SliverToBoxAdapter(
              child: Consumer<AnimeProvider>(
                builder: (context, animeProvider, _) {
                  final featuredAnimeTitles = [
                    'One Piece',
                    'Detective Conan',
                    'Boku no Hero Academia',
                    'Kaijuu 8-gou',
                    'Chainsaw Man'
                  ];

                  if (animeProvider.isLoading && animeProvider.animes.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // Filter the anime list to only include our featured anime
                  final featuredAnime = animeProvider.animes
                      .where((anime) => featuredAnimeTitles.any(
                            (title) => anime.title.toLowerCase().contains(title.toLowerCase()),
                          ))
                      .toList();

                  if (featuredAnime.isEmpty) {
                    // If no featured anime found, try to load them
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      animeProvider.getAnimeByTitles(featuredAnimeTitles).then((animes) {
                        animeProvider.animes.addAll(animes);
                        if (animes.isNotEmpty) {
                          animeProvider.notifyListeners();
                        }
                      });
                    });
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Text('Loading featured anime...')),
                    );
                  }
                  
                  return SizedBox(
                    height: 220, 
                    child: CarouselSlider.builder(
                      itemCount: featuredAnime.length,
                      options: CarouselOptions(
                        height: 200,
                        aspectRatio: 16/9,
                        viewportFraction: 0.8,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final anime = featuredAnime[index % featuredAnime.length];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (anime.imageUrl?.isNotEmpty ?? false)
                                  Image.network(
                                    anime.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => 
                                        const Center(child: Icon(Icons.error, size: 40)),
                                  )
                                else
                                  const Center(child: Icon(Icons.movie, size: 60, color: Colors.grey)),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.8),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      anime.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Anime List Section
            SliverFillRemaining(
              child: AnimeListScreen(showHeader: false),
            ),
          ],
        ),
      ),
    );
  }
}