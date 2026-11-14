import 'package:flutter/material.dart';

/// Small grey caption above a group of rows, e.g. "Recent searches".
class SearchSectionHeader extends StatelessWidget {
  const SearchSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A plain tappable row: icon, title (the part matching [query] in bold),
/// an optional grey second line, and optional grey text or a remove button
/// on the right.
class SearchRowTile extends StatelessWidget {
  const SearchRowTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.query = '',
    this.accent = false,
    this.trailingText,
    this.onRemove,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String query;

  /// Primary-coloured row, used for "Use my current location".
  final bool accent;

  /// Grey text on the right, e.g. "8 jobs".
  final String? trailingText;

  /// Shows a ✕ on the right that calls this.
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = accent ? scheme.primary : scheme.onSurface;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, onRemove == null ? 20 : 4, 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: accent ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HighlightedText(
                      text: title,
                      query: query,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: color,
                        fontWeight: accent ? FontWeight.w600 : null,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: muted,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailingText != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(trailingText!, style: muted),
                ),
              if (onRemove != null)
                IconButton(
                  tooltip: 'Remove',
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bolds every case-insensitive match of [query] inside [text].
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({required this.text, required this.query, this.style});

  final String text;
  final String query;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }
    final lower = text.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;
    while (true) {
      final index = lower.indexOf(needle, start);
      if (index < 0) break;
      if (index > start)
        spans.add(TextSpan(text: text.substring(start, index)));
      spans.add(
        TextSpan(
          text: text.substring(index, index + needle.length),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
      start = index + needle.length;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Small grey line in a suggestion list, with an optional action such as
/// "Retry".
class SearchListNote extends StatelessWidget {
  const SearchListNote(this.text, {super.key, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
