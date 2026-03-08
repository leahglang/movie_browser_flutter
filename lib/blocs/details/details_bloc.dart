import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/movie.dart';
import '../../repositories/movie_repository.dart';
import '../favorites/favorites_bloc.dart';

abstract class DetailsState {}

class DetailsInitial extends DetailsState {}

class DetailsLoading extends DetailsState {}

class DetailsLoaded extends DetailsState {
  final Movie movie;
  final bool isFavorite;
  DetailsLoaded({required this.movie, required this.isFavorite});
}

class DetailsError extends DetailsState {
  final String message;
  DetailsError(this.message);
}

class DetailsBloc extends Cubit<DetailsState> {
  final MovieRepository repository;
  final FavoritesBloc favoritesBloc;

  DetailsBloc(this.repository, this.favoritesBloc) : super(DetailsInitial());

  late Movie _currentMovie;
  bool _isFavorite = false;

  Future<void> loadMovie(String imdbID) async {
    emit(DetailsLoading());
    try {
      final movie = await repository.getMovieDetails(imdbID);
      if (isClosed) return;
      if (movie == null) {
        emit(DetailsError("movie_not_found"));
        return;
      }
      _currentMovie = movie;
      _isFavorite = repository.isFavorite(movie.imdbID);
      emit(DetailsLoaded(movie: movie, isFavorite: _isFavorite));
    } catch (e) {
      if (!isClosed) {
        emit(DetailsError("error_load_movie"));
      }
    }
  }

  Future<void> toggleFavorite() async {
    if (_isFavorite) {
      await repository.removeFavorite(_currentMovie.imdbID);
      _isFavorite = false;
    } else {
      await repository.addFavorite(_currentMovie);
      _isFavorite = true;
    }
    favoritesBloc.loadFavorites();
    emit(DetailsLoaded(movie: _currentMovie, isFavorite: _isFavorite));
  }
}
