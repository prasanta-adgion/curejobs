import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../sections/certification_licences/presentation/bloc/certifications_bloc.dart';
import '../../sections/certification_licences/presentation/widgets/certifications_section.dart';
import '../../sections/certification_licences/presentation/widgets/expiring_certificate_banner.dart';
import '../../sections/education/presentation/page/education_tab.dart';

/// Third tab: what the candidate is qualified to do. A renewal warning at
/// the top, then education, then certifications and licences.
class QualificationsTab extends StatelessWidget {
  const QualificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // One bloc shared by the banner and the section.
    return BlocProvider(
      create: (_) =>
          sl<CertificationsBloc>()..add(const CertificationsRequested()),
      child: const EducationTab(
        leading: [ExpiringCertificateBanner()],
        trailing: [CertificationsSection()],
      ),
    );
  }
}
