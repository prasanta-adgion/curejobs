import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../applied_application/domain/entities/job_application.dart';
import '../../../applied_application/presentation/bloc/my_applications_bloc.dart';
import '../../../applied_application/presentation/page/my_applications_page.dart';
import '../../shared/widgets/profile_section.dart';

/// "My applications": one calm row of counts (Applied, In review,
/// Shortlisted) from [MyApplicationsBloc], with a "View all" link.
class MyApplicationsSection extends StatelessWidget {
  const MyApplicationsSection({super.key, this.showDivider = false});

  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<MyApplicationsBloc>()..add(const MyApplicationsRequested()),
      child: _MyApplicationsView(showDivider: showDivider),
    );
  }
}

class _MyApplicationsView extends StatelessWidget {
  const _MyApplicationsView({required this.showDivider});

  final bool showDivider;

  /// Opens the full list, then refreshes the counts in case the user
  /// withdrew an application there.
  Future<void> _openAll(BuildContext context) async {
    final bloc = context.read<MyApplicationsBloc>();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyApplicationsPage()),
    );
    if (!bloc.isClosed) bloc.add(const MyApplicationsRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ProfileSection(
      title: 'My applications',
      showDivider: showDivider,
      action: TextButton(
        onPressed: () => _openAll(context),
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'View all',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      child: BlocBuilder<MyApplicationsBloc, MyApplicationsState>(
        buildWhen: (a, b) => a.status != b.status || a.counts != b.counts,
        builder: (context, state) {
          final loading = state.isLoading && state.counts.isEmpty;
          final failed =
              state.status == MyApplicationsStatus.failure &&
              state.counts.isEmpty;

          if (failed) {
            return _Retry(
              onRetry: () => context.read<MyApplicationsBloc>().add(
                const MyApplicationsRequested(),
              ),
            );
          }

          // Every application sent, except withdrawn ones.
          final applied =
              state.totalCount - state.countOf(ApplicationStatus.withdrawn);

          return InkWell(
            onTap: () => _openAll(context),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: _Count(
                      value: loading ? null : applied,
                      label: 'Applied',
                    ),
                  ),
                  Expanded(
                    child: _Count(
                      value: loading
                          ? null
                          : state.countOf(ApplicationStatus.underReview),
                      label: 'In review',
                    ),
                  ),
                  Expanded(
                    child: _Count(
                      value: loading
                          ? null
                          : state.countOf(ApplicationStatus.shortlisted),
                      label: 'Shortlisted',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Bold number followed by a muted label, e.g. "26 Applied".
/// A null [value] shows a dash while loading.
class _Count extends StatelessWidget {
  const _Count({required this.value, required this.label});

  final int? value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${value ?? '–'} ',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            "Couldn't load your applications.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
