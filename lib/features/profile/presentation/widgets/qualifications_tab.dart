import 'package:flutter/material.dart';

import '../../sections/certification_licences/presentation/widgets/certifications_section.dart';
import '../../sections/certification_licences/presentation/widgets/expiring_certificate_banner.dart';
import '../../sections/education/presentation/widgets/education_tab.dart';
import '../models/candidate_profile.dart';

/// Third tab: what the candidate is qualified to do. An expiry warning at
/// the top, then education, then certifications and licences.
class QualificationsTab extends StatelessWidget {
  const QualificationsTab({super.key, required this.profile});

  /// Sample certificates until there's a certificates API.
  final CandidateProfile profile;

  @override
  Widget build(BuildContext context) {
    return EducationTab(
      leading: [ExpiringCertificateBanner(certificates: profile.certificates)],
      trailing: [CertificationsSection(certificates: profile.certificates)],
    );
  }
}
