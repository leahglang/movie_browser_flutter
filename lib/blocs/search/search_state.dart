import 'package:movie_browser/models/movie.dart';

abstract class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final List<Movie> movies;
  final int currentPage;
  final bool hasMore;

  const SearchLoaded({
    required this.movies,
    required this.currentPage,
    required this.hasMore,
  });
}

class SearchEmpty extends SearchState {
  const SearchEmpty();
}

enum SearchErrorType {
  network,
  loadMovie,
}

class SearchError extends SearchState {
  final SearchErrorType type;

  const SearchError(this.type);
}