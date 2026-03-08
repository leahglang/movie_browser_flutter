import 'package:flutter/material.dart';
import '../core/localization/app_localizations.dart';

class SearchInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final bool isLoading;

  const SearchInput({
    super.key,
    required this.controller,
    required this.onSearch,
    this.isLoading = false,
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final query = widget.controller.text.trim();
    if (query.isNotEmpty && !widget.isLoading) {
      widget.onSearch();
      widget.controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            autofocus: true,
            onSubmitted: (_) => _handleSearch(),
            decoration: InputDecoration(
              hintText: loc.translate('search_hint'),
              border: const OutlineInputBorder(),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.controller.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (text) {
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: widget.isLoading ? null : _handleSearch,
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(loc.translate('search_button')),
        ),
      ],
    );
  }
}
