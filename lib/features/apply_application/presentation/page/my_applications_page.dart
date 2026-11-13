import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/my_applications_bloc.dart';
import '../models/application_ui_model.dart';
import '../widgets/application_card.dart';
import '../widgets/application_filter_chips.dart';
import '../widgets/withdraw_application_sheet.dart';

/// "My applications" screen, backed by `GET api/v1/applications/me`.
class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<MyApplicationsBloc>()..add(const MyApplicationsRequested()),
      child: const _MyApplicationsView(),
    );
  }
}

class _MyApplicationsView extends StatefulWidget {
  const _MyApplicationsView();

  @override
  State<_MyApplicationsView> createState() => _MyApplicationsViewState();
}

class _MyApplicationsViewState extends State<_MyApplicationsView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 300) {
      context.read<MyApplicationsBloc>().add(
        const MyApplicationsNextPageRequested(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return BlocListener<MyApplicationsBloc, MyApplicationsState>(
      listenWhen: (prev, curr) =>
          curr.withdrawResult != null &&
          curr.withdrawResult != prev.withdrawResult,
      listener: (context, state) {
        final result = state.withdrawResult!;
        if (result.isSuccess) {
          AppSnackbar.success(title: 'Application withdrawn');
        } else {
          AppSnackbar.error(
            title: "Couldn't withdraw application",
            message: result.failure!.message,
          );
        }
      },
      child: _buildConsumer(theme, scheme),
    );
  }

  Widget _buildConsumer(ThemeData theme, ColorScheme scheme) {
    return BlocConsumer<MyApplicationsBloc, MyApplicationsState>(
      listenWhen: (prev, curr) =>
          curr.failure != null &&
          curr.failure != prev.failure &&
          curr.status == MyApplicationsStatus.success,
      listener: (context, state) => AppSnackbar.error(
        title: "Couldn't load applications",
        message: state.failure!.message,
      ),
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My applications',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (state.status == MyApplicationsStatus.success)
                  Text(
                    '${state.totalCount} jobs applied',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          body: switch (state.status) {
            MyApplicationsStatus.initial || MyApplicationsStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            MyApplicationsStatus.failure => AppErrorView(
              failure: state.failure!,
              onRetry: () => context.read<MyApplicationsBloc>().add(
                const MyApplicationsRequested(),
              ),
            ),
            MyApplicationsStatus.success => _buildList(context, state),
          },
        );
      },
    );
  }

  Future<void> _confirmWithdraw(
    BuildContext context,
    JobApplication application,
  ) async {
    final bloc = context.read<MyApplicationsBloc>();
    final confirmed = await showWithdrawApplicationSheet(context, application);
    if (confirmed) bloc.add(MyApplicationWithdrawRequested(application));
  }

  Widget _buildList(BuildContext context, MyApplicationsState state) {
    final bloc = context.read<MyApplicationsBloc>();
    final items = state.visibleItems;

    return RefreshIndicator(
      onRefresh: () async {
        bloc.add(const MyApplicationsRefreshed());
        await bloc.stream.firstWhere((s) => !s.isLoading && !s.isFiltering);
      },
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: ApplicationFilterChips(
                total: state.totalCount,
                counts: state.counts,
                selected: state.filter,
                onSelected: (s) => bloc.add(MyApplicationsFilterChanged(s)),
              ),
            ),
          ),
          if (state.isFiltering)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(filtered: state.filter != null),
            )
          else
            // Separate cards with gaps, like the dashboard job list.
            SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => ApplicationCard(
                item: items[i],
                // TODO: open job details with items[i].jobSlug.
                onTap: () {},
                isWithdrawing: state.withdrawingIds.contains(items[i].id),
                onWithdraw: () => _confirmWithdraw(context, items[i]),
                // TODO: hook up reapply once the endpoint exists.
                onReapply: () {},
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: state.isLoadingMore
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline_rounded, size: 44, color: muted),
          const SizedBox(height: 12),
          Text(
            filtered ? 'No applications here' : 'Start applying to jobs',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            filtered
                ? 'Try another filter.'
                : 'Jobs you apply to will show up here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}
