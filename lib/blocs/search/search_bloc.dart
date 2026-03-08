import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_state.dart';
import '../../repositories/movie_repository.dart';
import '../../models/movie.dart';

class SearchBloc extends Cubit<SearchState> {
  final MovieRepository repository;
  bool isLoading = false;
  bool hasMore = true;

  List<Movie> allMovies = [];
  String lastQuery = '';
  int currentPage = 1;

  SearchBloc(this.repository) : super(const SearchInitial());

  Future<void> searchMovies(String query, {int page = 1}) async {
    if (isLoading) return;

    if (query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }

    isLoading = true;

    try {
      if (page == 1) {
        emit(const SearchLoading());
        allMovies.clear();
        lastQuery = query;
        currentPage = 1;
        hasMore = true;
      }

      final List<Movie> movies = await repository.searchMovies(query, page);

      if (movies.isEmpty && page == 1) {
        emit(const SearchEmpty());
      } else {
        allMovies.addAll(movies);
        currentPage = page;
        hasMore = movies.length == 10;

        emit(SearchLoaded(
          movies: allMovies,
          currentPage: currentPage,
          hasMore: hasMore,
        ));
      }
    } catch (e) {
      final errorString = e.toString();

      if (errorString.contains("network_error")) {
        emit(const SearchError(SearchErrorType.network));
      } else if (errorString.contains("api_error")) {
        emit(const SearchError(SearchErrorType.loadMovie));
      } else {
        emit(const SearchError(SearchErrorType.loadMovie));
      }
    } finally {
      isLoading = false;
    }
  }

  Future<void> loadNextPage() async {
    if (state is SearchLoaded && !isLoading && hasMore) {
      await searchMovies(lastQuery, page: currentPage + 1);
    }
  }
}
