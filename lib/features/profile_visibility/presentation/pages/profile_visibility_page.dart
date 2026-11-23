import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/widgets/navy_page_header.dart';
import '../../../subscription_packages/presentation/pages/subscription_packages_page.dart';
import '../bloc/profile_visibility_bloc.dart';
import '../widgets/profile_visibility_widgets.dart';

class ProfileVisibilityPage extends StatelessWidget {
  const ProfileVisibilityPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const ProfileVisibilityPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ProfileVisibilityBloc>()..add(const ProfileVisibilityRequested()),
      child: const _ProfileVisibilityView(),
    );
  }
}

class _ProfileVisibilityView extends StatelessWidget {
  const _ProfileVisibilityView();

  Future<void> _upgrade(BuildContext context) async {
    final bloc = context.read<ProfileVisibilityBloc>();
    await Navigator.of(context).push(SubscriptionPackagesPage.route());
    // The plan may have changed.
    bloc.add(const ProfileVisibilityRequested());
  }

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<ProfileVisibilityBloc>()
      ..add(const ProfileVisibilityRequested());
    try {
      await bloc.stream.firstWhere(
        (s) => s.status != ProfileVisibilityStatus.loading,
      );
    } on StateError {
      // Bloc closed first.
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileVisibilityBloc, ProfileVisibilityState>(
      listenWhen: (p, c) =>
          c.updateFailure != null && p.updateFailure != c.updateFailure,
      listener: (context, state) => AppSnackbar.error(
        title: "Couldn't save",
        message: state.updateFailure!.message,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: Column(
            children: [
              BlocBuilder<ProfileVisibilityBloc, ProfileVisibilityState>(
                buildWhen: (p, c) => p.planName != c.planName,
                builder: (context, state) => NavyPageHeader(
                  title: 'Profile visibility',
                  subtitle: state.planName == null
                      ? 'Who can find you'
                      : '${state.planName} plan',
                ),
              ),
              Expanded(
                child:
                    BlocBuilder<ProfileVisibilityBloc, ProfileVisibilityState>(
                      builder: (context, state) {
                        final loadingFirst =
                            state.status == ProfileVisibilityStatus.loading &&
                            state.planName == null;
                        if (loadingFirst) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state.status == ProfileVisibilityStatus.failure &&
                            state.planName == null) {
                          return AppErrorView(
                            failure: state.failure!,
                            onRetry: () => context
                                .read<ProfileVisibilityBloc>()
                                .add(const ProfileVisibilityRequested()),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () => _refresh(context),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 24),
                            children: [
                              if (state.hasProfileVisibility)
                                MatchPrivacySection(
                                  showDivider: false,
                                  privacy: state.privacy,
                                  savingSetting: state.savingSetting,
                                  onDiscoverableChanged: (v) => context
                                      .read<ProfileVisibilityBloc>()
                                      .add(MatchDiscoverableToggled(v)),
                                  onShareContactChanged: (v) => context
                                      .read<ProfileVisibilityBloc>()
                                      .add(ShareContactOnRevealToggled(v)),
                                )
                              else
                                LockedFeatureSection(
                                  showDivider: false,
                                  title: 'Profile visibility',
                                  body:
                                      'Upgrade to let hospitals and clinics find your profile '
                                      'and contact you.',
                                  onUpgrade: () => _upgrade(context),
                                ),
                              if (state.hasResumeVisibility)
                                ProfileActivitySection(activity: state.activity)
                              else
                                LockedFeatureSection(
                                  title: 'Resume visibility',
                                  body:
                                      'Upgrade to see which hospitals and clinics viewed '
                                      'your full profile.',
                                  onUpgrade: () => _upgrade(context),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
