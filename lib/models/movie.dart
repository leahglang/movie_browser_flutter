import 'package:hive/hive.dart';

part 'movie.g.dart';

@HiveType(typeId: 0)
class Movie extends HiveObject {
  @HiveField(0)
  final String imdbID;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String year;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final String poster;

  @HiveField(5)
  final String? plot;

  Movie({
    required this.imdbID,
    required this.title,
    required this.year,
    required this.type,
    required this.poster,
    this.plot,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      imdbID: json['imdbID'] ?? '',
      title: json['Title'] ?? '',
      year: json['Year'] ?? '',
      type: json['Type'] ?? '',
      poster: json['Poster'] == 'N/A' ? '' : json['Poster'] ?? '',
      plot: json['Plot'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imdbID': imdbID,
      'Title': title,
      'Year': year,
      'Type': type,
      'Poster': poster,
      'Plot': plot,
    };
  }
}
