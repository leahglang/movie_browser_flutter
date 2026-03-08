import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/movie.dart';
import '../../repositories/movie_repository.dart';

abstract class FavoritesState {
  const FavoritesState();
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Movie> movies;
  const FavoritesLoaded(this.movies);
}

class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError(this.message);
}

class FavoritesBloc extends Cubit<FavoritesState> {
  final MovieRepository repository;

  FavoritesBloc(this.repository) : super(FavoritesInitial());

  void loadFavorites() {
    try {
      emit(FavoritesLoading());
      final favorites = repository.getFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(const FavoritesError('error_load_favorites'));
    }
  }

  Future<void> removeFavorite(String imdbID) async {
    try {
      await repository.removeFavorite(imdbID);

      final updatedFavorites = repository.getFavorites();
      emit(FavoritesLoaded(updatedFavorites));
    } catch (e) {
      emit(const FavoritesError('error_remove_favorite'));
    }
  }
}
