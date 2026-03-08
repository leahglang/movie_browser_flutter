import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../core/localization/app_localizations.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const MovieCard(
      {super.key, required this.movie, required this.onTap, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Semantics(
      button: true,
      hint: loc.translate('tap_to_view_details'),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: SizedBox(
            width: 50,
            height: 70,
            child: movie.poster.isNotEmpty && movie.poster != "N/A"
                ? Image.network(
                    movie.poster,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, color: Colors.grey),
                  )
                : const Icon(Icons.movie),
          ),
          title: Text(movie.title),
          subtitle: Text(
              "${loc.translate('year')}: ${movie.year} • ${loc.translate(movie.type)}"),
          onTap: onTap,
          trailing: onRemove != null
              ? IconButton(
                  tooltip: loc.translate('remove_favorite'),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                )
              : const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}
