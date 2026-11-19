import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'app_back_button.dart';

/// Navy page header used in place of an `AppBar`: back button (when the
/// route can pop), title, optional subtitle and trailing action, and an
/// optional [bottom] row such as filter chips. Colours are fixed to match
/// the dashboard header.
class NavyPageHeader extends StatelessWidget {
  const NavyPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
  });

  static const background = AppColors.logoNavy;

  final String title;
  final String? subtitle;
  final Widget? trailing;

  /// Shown under the title row, e.g. a [HeaderFilterChips] row.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Container(
      color: background,
      padding: EdgeInsets.fromLTRB(canPop ? 4 : 16, top + 6, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (canPop) const AppBackButton(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle case final s? when s.isNotEmpty)
                      Text(
                        s,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          if (bottom != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: canPop ? 12 : 0),
              child: bottom,
            ),
          ],
        ],
      ),
    );
  }
}

/// One item for [HeaderFilterChips].
class HeaderFilterItem<T> {
  const HeaderFilterItem({
    required this.value,
    required this.label,
    required this.count,
    this.highlightCount = false,
  });

  final T value;
  final String label;
  final int count;

  /// Red count badge when above zero (e.g. Unread).
  final bool highlightCount;
}

/// Horizontally scrolling pill chips for a [NavyPageHeader].
class HeaderFilterChips<T> extends StatelessWidget {
  const HeaderFilterChips({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<HeaderFilterItem<T>> items;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final item = items[i];
          return HeaderFilterChip(
            label: item.label,
            count: item.count,
            selected: item.value == selected,
            highlightCount: item.highlightCount,
            onTap: () => onSelected(item.value),
          );
        },
      ),
    );
  }
}

/// White-on-navy pill with a count badge; filled white when selected and
/// faded when the count is zero.
class HeaderFilterChip extends StatelessWidget {
  const HeaderFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.highlightCount = false,
  });

  final String label;
  final int count;
  final bool selected;
  final bool highlightCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.labelLarge;
    final fg = selected ? AppColors.logoNavy : AppColors.white;
    final dim = count == 0 && !selected;

    final Color badgeBg;
    if (highlightCount && count > 0) {
      badgeBg = AppColors.error;
    } else if (selected) {
      badgeBg = AppColors.logoNavy;
    } else {
      badgeBg = AppColors.white.withValues(alpha: 0.12);
    }

    return Opacity(
      opacity: dim ? 0.55 : 1,
      child: Material(
        color: selected ? AppColors.white : AppColors.transparent,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected
                ? AppColors.white
                : AppColors.white.withValues(alpha: 0.25),
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(label, style: text?.copyWith(color: fg)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: text?.copyWith(color: AppColors.white, fontSize: 11),
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
