import 'package:hive/hive.dart';

class HiveService {
  static const String searchHistoryBox = 'search_history';
  static const String favoritesBox = 'favorites';
  static const String movieCacheBox = 'movie_cache';

  static Box getSearchHistoryBox() {
    return Hive.box(searchHistoryBox);
  }

  static Box getFavoritesBox() {
    return Hive.box(favoritesBox);
  }

  static Box getMovieCacheBox() {
    return Hive.box(movieCacheBox);
  }
}
