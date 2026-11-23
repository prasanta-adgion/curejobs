import 'package:flutter/material.dart';

import '../../../domain/entities/job_alert_preferences.dart';

/// Location filter: a search bar that opens the city / state search, an
/// "anywhere" note and popular picks when empty, and one row per place.
class LocationSection extends StatelessWidget {
  const LocationSection({
    super.key,
    required this.locations,
    required this.onSearch,
    required this.onAdd,
    required this.onRemove,
  });

  final List<AlertLocation> locations;

  /// Opens the search page.
  final VoidCallback onSearch;

  /// Adds a place straight away (popular picks).
  final ValueChanged<AlertLocation> onAdd;
  final ValueChanged<AlertLocation> onRemove;

  static const popular = [
    AlertLocation(city: 'Kolkata', state: 'West Bengal'),
    AlertLocation(city: 'Bengaluru', state: 'Karnataka'),
    AlertLocation(city: 'Mumbai', state: 'Maharashtra'),
    AlertLocation(city: 'New Delhi', state: 'Delhi'),
    AlertLocation(city: 'Chennai', state: 'Tamil Nadu'),
    AlertLocation(city: 'Hyderabad', state: 'Telangana'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const max = JobAlertPreferences.maxLocations;
    final full = locations.length >= max;
    final empty = locations.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Where do you want to work?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (empty) ...[const AnywhereNote(), const SizedBox(height: 10)],
        LocationSearchBar(
          label: full
              ? 'Remove a place to add another'
              : empty
              ? 'Search a city or state'
              : 'Add another city or state',
          onTap: full ? null : onSearch,
        ),
        if (empty)
          PopularPlaces(places: popular, onPick: onAdd)
        else ...[
          const SizedBox(height: 4),
          for (final l in locations)
            LocationRow(location: l, onRemove: () => onRemove(l)),
          const SizedBox(height: 8),
          Text(
            '${locations.length} of $max places',
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(
              color: full ? scheme.error : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Green "Showing jobs from anywhere" note for an empty list.
class AnywhereNote extends StatelessWidget {
  const AnywhereNote({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = scheme.brightness == Brightness.dark
        ? Colors.green.shade200
        : Colors.green.shade800;
    final bg = scheme.brightness == Brightness.dark
        ? Colors.green.shade900.withValues(alpha: 0.4)
        : Colors.green.shade50;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.public_rounded, size: 18, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing jobs from anywhere',
              style: theme.textTheme.bodySmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Looks like a search field; tapping it opens the search page.
class LocationSearchBar extends StatelessWidget {
  const LocationSearchBar({super.key, required this.label, this.onTap});

  final String label;

  /// Disabled (greyed) when null.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(12);
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: scheme.surfaceContainerLowest,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: onTap == null ? scheme.outlineVariant : scheme.outline,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: onTap == null ? scheme.outline : scheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Popular" one-tap suggestions shown while the list is empty.
class PopularPlaces extends StatelessWidget {
  const PopularPlaces({super.key, required this.places, required this.onPick});

  final List<AlertLocation> places;
  final ValueChanged<AlertLocation> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Text(
            'Popular',
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final p in places)
              ActionChip(
                avatar: Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: scheme.primary,
                ),
                label: Text(p.city ?? p.state ?? ''),
                tooltip: p.label,
                onPressed: () => onPick(p),
                visualDensity: VisualDensity.compact,
                shape: const StadiumBorder(),
              ),
          ],
        ),
      ],
    );
  }
}

/// One added place: icon, name, state (or "All cities"), City/State tag, ✕.
class LocationRow extends StatelessWidget {
  const LocationRow({
    super.key,
    required this.location,
    required this.onRemove,
  });

  final AlertLocation location;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final whole = location.isWholeState;
    final title = whole ? location.state! : (location.city ?? '');
    final subtitle = whole ? 'All cities' : location.state;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              whole ? Icons.map_outlined : Icons.location_on_outlined,
              size: 20,
              color: scheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            PlaceTypeTag(isState: whole),
            IconButton(
              tooltip: 'Remove ${location.label}',
              onPressed: onRemove,
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small grey "City" / "State" pill.
class PlaceTypeTag extends StatelessWidget {
  const PlaceTypeTag({super.key, required this.isState});

  final bool isState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isState ? 'State' : 'City',
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
