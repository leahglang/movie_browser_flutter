import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/favorites/favorites_bloc.dart';
import '../core/localization/app_localizations.dart';
import '../blocs/details/details_bloc.dart';
import '../core/utils/snackbar.dart';
import '../repositories/movie_repository.dart';

class DetailsScreen extends StatelessWidget {
  final String imdbID;
  const DetailsScreen({super.key, required this.imdbID});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) => DetailsBloc(
        context.read<MovieRepository>(),
        context.read<FavoritesBloc>(),
      )..loadMovie(imdbID),
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.translate('movie_details')),
        ),
        body: BlocConsumer<DetailsBloc, DetailsState>(
          listener: (context, state) {
            final loc = AppLocalizations.of(context);

            if (state is DetailsError) {
              showErrorSnackBar(
                context,
                loc.translate(state.message),
              );
            }
          },
          builder: (context, state) {
            if (state is DetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DetailsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    loc.translate(state.message),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is DetailsLoaded) {
              final movie = state.movie;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: '${movie.title} ${loc.translate('poster_label')}',
                      child: Center(
                        child: movie.poster.isNotEmpty && movie.poster != "N/A"
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  movie.poster,
                                  height: 300,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 100),
                                ),
                              )
                            : const Icon(Icons.movie, size: 100),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      movie.title,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Chip(label: Text(movie.year)),
                        const SizedBox(width: 10),
                        Chip(label: Text(loc.translate(movie.type))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      loc.translate('plot'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.plot != null && movie.plot != "N/A"
                          ? movie.plot!
                          : loc.translate('no_plot_available'),
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              state.isFavorite ? Colors.red.shade50 : null,
                          foregroundColor: state.isFavorite ? Colors.red : null,
                          side: state.isFavorite
                              ? const BorderSide(color: Colors.red)
                              : null,
                        ),
                        icon: Icon(
                          state.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        label: Text(
                          state.isFavorite
                              ? loc.translate('remove_favorite')
                              : loc.translate('add_favorite'),
                        ),
                        onPressed: () {
                          context.read<DetailsBloc>().toggleFavorite();
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
