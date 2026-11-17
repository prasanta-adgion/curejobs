part of 'job_details_sections.dart';

/// "Why you're a match", from `matchReasons`.
class JobMatchSection extends StatelessWidget {
  const JobMatchSection({super.key, required this.reasons});

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final green = dark ? AppColors.successDark : AppColors.success;
    final greenBg = dark
        ? AppColors.successDark.withValues(alpha: 0.16)
        : AppColors.successLight;
    return _Section(
      icon: Icons.verified_outlined,
      iconColor: green,
      title: "Why you're a match",
      child: Column(
        children: [
          for (final reason in reasons)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: greenBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded, size: 14, color: green),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(reason, style: theme.textTheme.bodyMedium),
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
      if (job.qualificationText case final q?) ('Qualification', q),
      if (job.additionalRequirements case final a?) ('Also needed', a),
    ];
    return _Section(
      icon: Icons.school_outlined,
      title: 'Requirements',
      child: Column(
        children: [
          for (final item in items) ...[
            const ApplyRowDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 104,
                    child: Text(
                      item.$1,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.$2,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
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
  static const _collapsedHeight = 140.0;
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
          const SizedBox(height: 4),
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

/// Full address with an "Open in Maps" link.
class JobLocationSection extends StatelessWidget {
  const JobLocationSection({super.key, required this.job});

  final Job job;

  static bool hasAddress(Job job) =>
      job.address != null || job.area != null || job.postalCode != null;

  String get _fullAddress => [
    job.address,
    job.area,
    fullLocation(job),
    job.postalCode,
    job.country,
  ].whereType<String>().where((p) => p.trim().isNotEmpty).join(', ');

  Future<void> _openMaps() async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '${job.organization.name}, $_fullAddress',
    });
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

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
          const SizedBox(height: 4),
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
          TextButton.icon(
            onPressed: _openMaps,
            style: TextButton.styleFrom(
              foregroundColor: _brand(context),
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.map_outlined, size: 18),
            label: const Text('Open in Maps'),
          ),
        ],
      ),
    );
  }
}
