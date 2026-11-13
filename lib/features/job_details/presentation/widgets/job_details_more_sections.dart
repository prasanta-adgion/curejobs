part of 'job_details_sections.dart';

/// "Why this job matches you", from `matchReasons`.
class JobMatchSection extends StatelessWidget {
  const JobMatchSection({super.key, required this.reasons});

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final green = dark ? AppColors.successDark : AppColors.success;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? green.withValues(alpha: 0.12) : AppColors.successLight,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined, size: 18, color: green),
              const SizedBox(width: 6),
              Text(
                'Why this job matches you',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final reason in reasons)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_rounded, size: 16, color: green),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      reason,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Qualification and additional requirements.
class JobRequirementsSection extends StatelessWidget {
  const JobRequirementsSection({super.key, required this.job});

  final Job job;

  static bool hasAny(Job job) =>
      job.qualificationText != null || job.additionalRequirements != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final items = [
      if (job.qualificationText case final q?)
        (Icons.school_outlined, 'Qualification', q),
      if (job.additionalRequirements case final a?)
        (Icons.info_outline_rounded, 'Also required', a),
    ];
    return _Section(
      icon: Icons.fact_check_outlined,
      title: 'Requirements',
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 21, color: _border(context)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(items[i].$1, size: 18, color: scheme.outline),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].$2,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].$3,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The HTML description, shown as a preview with "Read more".
class JobDescriptionSection extends StatefulWidget {
  const JobDescriptionSection({super.key, required this.html});

  final String html;

  @override
  State<JobDescriptionSection> createState() => _JobDescriptionSectionState();
}

class _JobDescriptionSectionState extends State<JobDescriptionSection> {
  static const _collapsedHeight = 180.0;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final body = HtmlWidget(
      widget.html,
      textStyle: theme.textTheme.bodyMedium?.copyWith(
        color: scheme.onSurface,
        height: 1.5,
      ),
      customStylesBuilder: (e) => switch (e.localName) {
        'h1' || 'h2' || 'h3' || 'h4' => {
          'font-size': '15px',
          'font-weight': '600',
          'margin': '0 0 6px 0',
        },
        'p' => {'margin': '0 0 8px 0'},
        'ul' || 'ol' => {'margin': '0 0 8px 0', 'padding-left': '18px'},
        // Links in descriptions are often junk (e.g. "http://B.Sc").
        'a' => {'color': 'inherit', 'text-decoration': 'none'},
        _ => null,
      },
      // Ignore link taps.
      onTapUrl: (_) => true,
    );

    return _Section(
      icon: Icons.description_outlined,
      title: 'About the job',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _expanded
                ? body
                : ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.black, Colors.transparent],
                      stops: [0, 0.65, 1],
                    ).createShader(rect),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: _collapsedHeight,
                      ),
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: body,
                      ),
                    ),
                  ),
          ),
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            style: TextButton.styleFrom(
              foregroundColor: _brand(context),
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            iconAlignment: IconAlignment.end,
            icon: Icon(
              _expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 18,
            ),
            label: Text(_expanded ? 'Show less' : 'Read more'),
          ),
        ],
      ),
    );
  }
}

/// Full address: street, area, city, state, postal code and country.
class JobLocationSection extends StatelessWidget {
  const JobLocationSection({super.key, required this.job});

  final Job job;

  static bool hasAddress(Job job) =>
      job.address != null || job.area != null || job.postalCode != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final street = [job.address, job.area].whereType<String>().join(', ');
    final region = [
      fullLocation(job),
      job.postalCode,
    ].whereType<String>().join(' – ');

    return _Section(
      icon: Icons.location_on_outlined,
      title: 'Location',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (street.isNotEmpty)
            Text(
              street,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          if (region.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(region, style: muted),
          ],
          if (job.country case final c?) Text(c, style: muted),
        ],
      ),
    );
  }
}
