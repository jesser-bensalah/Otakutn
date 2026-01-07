import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/anime_provider.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/loading_indicator.dart';

class AnimeListScreen extends StatelessWidget {
  final bool showHeader;
  
  const AnimeListScreen({
    Key? key,
    this.showHeader = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AnimeListScreenContent(showHeader: showHeader);
  }
}

class _AnimeListScreenContent extends StatefulWidget {
  final bool showHeader;
  
  const _AnimeListScreenContent({
    Key? key,
    required this.showHeader,
  }) : super(key: key);

  @override
  _AnimeListScreenState createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends State<_AnimeListScreenContent> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    // Load initial animes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final animeProvider = context.read<AnimeProvider>();
      if (animeProvider.animes.isEmpty) {
        animeProvider.loadTopAnimes();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final threshold = 0.8 * maxScroll;

    if (currentScroll >= threshold) {
      _loadMoreAnimes();
    }
  }

  Future<void> _loadMoreAnimes() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      await context.read<AnimeProvider>().loadMoreAnimes();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimeProvider>(
      builder: (context, animeProvider, _) {
        //  search results, even if empty
        final items = animeProvider.isSearching
            ? animeProvider.searchResults
            : animeProvider.animes;
            
        // Track the current search query to detect changes
        final currentSearchQuery = animeProvider.currentSearchQuery;

        // Only show loading indicator if we don't have any data yet
        if (animeProvider.isLoading && items.isEmpty) {
          return const Center(child: LoadingIndicator());
        }
        
        // If we're searching but have no results, show a message
        if (animeProvider.isSearching && items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No results found'),
            ),
          );
        }

        if (animeProvider.error.isNotEmpty && items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${animeProvider.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: animeProvider.loadTopAnimes,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (items.isEmpty) {
          return const Center(
            child: Text('No anime found'),
          );
        }

        final showSearchResults = animeProvider.isSearching;

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            if (widget.showHeader)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    showSearchResults ? 'Search Results' : 'Populaire',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 12.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= items.length) {
                      return _buildLoadMoreIndicator(animeProvider);
                    }
                    final anime = items[index];
                    return AnimeCard(anime: anime);
                  },
                  childCount: items.length + (animeProvider.hasMore && !showSearchResults ? 1 : 0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadMoreIndicator(AnimeProvider animeProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: animeProvider.isLoadingMore
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _loadMoreAnimes,
                child: const Text('Load More'),
              ),
      ),
    );
  }

  Widget _buildErrorWidget(AnimeProvider animeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: ${animeProvider.error}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (animeProvider.isSearching) {
                animeProvider.searchAnimes('');
              } else {
                animeProvider.loadTopAnimes();
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}