import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../core/constants.dart';
import '../models/movie.dart';

class MovieRepository {
  final Dio dio;
  final Box<Movie> _favoriteBox = Hive.box<Movie>('favorites');
  final Box<Movie> _cacheBox = Hive.box<Movie>('movie_cache');

  MovieRepository(this.dio);

  Future<List<Movie>> searchMovies(String query, int page) async {
    try {
      final response = await dio.get('/', queryParameters: {
        'apikey': apiKey,
        's': query,
        'page': page,
      });

      if (response.data['Response'] == 'False') {
        final String error = response.data['Error'] ?? '';

        if (error == "Movie not found!") {
          return [];
        }

        if (error == "Invalid API key!") {
          throw Exception('api_key_error');
        }

        throw Exception('server_error');
      }

      final List list = response.data['Search'] ?? [];
      return list.map((movie) => Movie.fromJson(movie)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('something_went_wrong');
    }
  }

  Future<Movie?> getMovieDetails(String imdbID) async {
    try {
      final response = await dio.get('/', queryParameters: {
        'apikey': apiKey,
        'i': imdbID,
        'plot': 'full',
      });

      if (response.data['Response'] == 'False') return null;

      final movie = Movie.fromJson(response.data);
      await _cacheBox.put(imdbID, movie);
      return movie;
    } catch (e) {
      final cached = _cacheBox.get(imdbID);
      if (cached != null) return cached;

      if (e is DioException) {
        throw _handleDioError(e);
      }
      throw Exception('something_went_wrong');
    }
  }

  List<Movie> getFavorites() => _favoriteBox.values.toList();
  bool isFavorite(String imdbID) => _favoriteBox.containsKey(imdbID);

  Future<void> removeFavorite(String imdbID) async {
    final box = Hive.box<Movie>('favorites');
    await box.delete(imdbID);
  }

  Future<void> addFavorite(Movie movie) async {
    try {
      final box = Hive.box<Movie>('favorites');

      final movieCopy = Movie(
        title: movie.title,
        year: movie.year,
        imdbID: movie.imdbID,
        type: movie.type,
        poster: movie.poster,
        plot: movie.plot,
      );

      await box.put(movieCopy.imdbID, movieCopy);
    } catch (e) {
      debugPrint('Error adding to favorites: $e');

      throw Exception('failed_to_add_favorite');
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('network_error');
    }

    if (e.response != null) {
      switch (e.response?.statusCode) {
        case 401:
          return Exception('api_key_error');
        case 404:
          return Exception('not_found_error');
        case 500:
          return Exception('server_error');
      }
    }

    return Exception('something_went_wrong');
  }
}
