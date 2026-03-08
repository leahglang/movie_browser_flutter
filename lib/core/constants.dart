import 'package:flutter_dotenv/flutter_dotenv.dart';

final String apiKey =  dotenv.env['OMDB_API_KEY'] ?? '';
final String baseUrl = dotenv.env['BASE_URL'] ?? '';