import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../apply_job/presentation/widgets/apply_flow_widgets.dart';
import '../../domain/entities/organization_details.dart';

Color _brand(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.darkPrimary
    : AppColors.primary;

Color _brandTint(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.darkPrimary.withValues(alpha: 0.16)
    : AppColors.primaryLight;

/// Logo, name with verified tick, location and website.
class OrganizationHeader extends StatelessWidget {
  const OrganizationHeader({super.key, required this.org, this.logoUrl});

  final OrganizationDetails org;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final brand = _brand(context);
    final location = org.location;
    final website = org.website;

    return ApplySection(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrganizationLogo(name: org.name, url: logoUrl, size: 64),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            org.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                        ),
                        if (org.verified) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.verified_rounded, size: 20, color: brand),
                        ],
                      ],
                    ),
                    if (location != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (website != null && website.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _openWebsite(website),
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.language_rounded, size: 18, color: brand),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _host(website),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: brand,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _host(String website) {
    final host = Uri.tryParse(website)?.host ?? '';
    return host.isNotEmpty ? host : website;
  }

  static Future<void> _openWebsite(String website) async {
    final uri = Uri.tryParse(
      website.startsWith('http') ? website : 'https://$website',
    );
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// "About the employer" with the description.
class OrganizationAboutSection extends StatelessWidget {
  const OrganizationAboutSection({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return ApplySection(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ApplySectionHeader(
            icon: Icons.local_hospital_outlined,
            title: 'About the employer',
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// Section header above the job cards: "Open jobs (12)".
class OrganizationJobsHeader extends StatelessWidget {
  const OrganizationJobsHeader({super.key, this.total});

  /// Null while the count isn't known yet.
  final int? total;

  @override
  Widget build(BuildContext context) {
    return ApplySection(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ApplySectionHeader(
        icon: Icons.work_outline_rounded,
        title: total == null ? 'Open jobs' : 'Open jobs ($total)',
      ),
    );
  }
}

/// Logo from the signed URL, or initials while loading / when missing.
class OrganizationLogo extends StatelessWidget {
  const OrganizationLogo({
    super.key,
    required this.name,
    required this.size,
    this.url,
  });

  final String name;
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = Center(
      child: Text(
        _initials(name),
        style: TextStyle(
          color: _brand(context),
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final url = this.url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: Container(
        width: size,
        height: size,
        color: _brandTint(context),
        child: url == null
            ? initials
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => initials,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : initials,
              ),
      ),
    );
  }

  static String _initials(String name) {
    final words = name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && RegExp(r'[A-Za-z]').hasMatch(w[0]))
        .toList();
    if (words.isEmpty) return '?';
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }
}
