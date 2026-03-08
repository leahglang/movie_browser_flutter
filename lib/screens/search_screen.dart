import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/localization/app_localizations.dart';
import '../blocs/search/search_bloc.dart';
import '../blocs/search/search_state.dart';
import '../core/utils/snackbar.dart';
import '../widgets/movie_card.dart';
import '../widgets/search_input.dart';
import 'details_screen.dart';
import 'favorites_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  late Box<String> historyBox;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    historyBox = Hive.box<String>('search_history');
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final bloc = context.read<SearchBloc>();

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      bloc.loadNextPage();
    }
  }

  void _onSearch() {
    final query = controller.text.trim();
    if (query.isEmpty) return;

    _saveQuery(query);
    context.read<SearchBloc>().searchMovies(query);
  }

  void _saveQuery(String query) {
    if (!historyBox.values.contains(query)) {
      if (historyBox.length >= 10) {
        historyBox.deleteAt(0);
      }
      historyBox.add(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('app_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: historyBox.listenable(),
            builder: (context, Box<String> box, _) {
              if (box.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () => box.clear(),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchInput(
              controller: controller,
              onSearch: _onSearch,
            ),
            ValueListenableBuilder(
              valueListenable: historyBox.listenable(),
              builder: (context, Box<String> box, _) {
                if (box.isEmpty) return const SizedBox.shrink();

                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        loc.translate('search_history'),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: box.length,
                        itemBuilder: (context, index) {
                          final actualIndex = box.length - 1 - index;
                          final item = box.getAt(actualIndex)!;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InputChip(
                              label: Text(item),
                              onPressed: () {
                                controller.text = item;
                                _onSearch();
                              },
                              onDeleted: () => box.deleteAt(actualIndex),
                              deleteIcon: const Icon(Icons.cancel, size: 16),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocConsumer<SearchBloc, SearchState>(
                listener: (context, state) {
                  final loc = AppLocalizations.of(context);

                  if (state is SearchError) {
                    final key = state.type == SearchErrorType.network
                        ? 'network_error'
                        : 'something_went_wrong';

                    showErrorSnackBar(
                      context,
                      loc.translate(key),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is SearchLoading && state is! SearchLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SearchError) {
                    return Center(
                      child: Text(loc.translate('something_went_wrong')),
                    );
                  }

                  if (state is SearchEmpty) {
                    return Center(child: Text(loc.translate('no_results')));
                  }

                  if (state is SearchLoaded) {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: state.movies.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.movies.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final movie = state.movies[index];
                        return MovieCard(
                          movie: movie,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailsScreen(imdbID: movie.imdbID),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return Center(
                      child: Text(loc.translate('search_for_movies')));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }
}