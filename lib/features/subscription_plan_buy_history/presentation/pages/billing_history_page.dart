import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_back_button.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../subscription_packages/presentation/widgets/package_widgets.dart';
import '../../domain/entities/payment_record.dart';
import '../bloc/payments_bloc.dart';
import '../bloc/plan_history_bloc.dart';
import '../widgets/billing_widgets.dart';

/// Billing history: navy header with total spent, then Payments and
/// Plan history tabs. Plan history loads page by page.
class BillingHistoryPage extends StatelessWidget {
  const BillingHistoryPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const BillingHistoryPage());

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<PaymentsBloc>()..add(const PaymentsRequested()),
        ),
        BlocProvider(
          create: (_) =>
              sl<PlanHistoryBloc>()..add(const PlanHistoryRequested()),
        ),
      ],
      child: const _BillingView(),
    );
  }
}

class _BillingView extends StatelessWidget {
  const _BillingView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: scheme.surface,
          body: Column(
            children: [
              const _Header(),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(
                    bottom: BorderSide(color: scheme.outlineVariant),
                  ),
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  labelColor: scheme.onSurface,
                  unselectedLabelColor: scheme.onSurfaceVariant,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  indicatorColor: PlanColors.of(context).accentText,
                  indicatorWeight: 2.5,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerHeight: 0,
                  tabs: const [
                    Tab(text: 'Payments'),
                    Tab(text: 'Plan history'),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [_PaymentsTab(), _PlanHistoryTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navy header with back button and title.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.logoNavy,
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const AppBackButton(padding: EdgeInsets.fromLTRB(4, 8, 8, 8)),
            Text(
              'Billing history',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payments
// ---------------------------------------------------------------------------

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab();

  Future<void> _refresh(BuildContext context) {
    final bloc = context.read<PaymentsBloc>()..add(const PaymentsRequested());
    return bloc.stream.firstWhere((s) => s.status != PaymentsStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentsBloc, PaymentsState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return switch (state.status) {
            PaymentsStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            PaymentsStatus.failure => _Message(
              icon: Icons.cloud_off_rounded,
              text: state.failure?.message ?? "Couldn't load your payments.",
              onRetry: () =>
                  context.read<PaymentsBloc>().add(const PaymentsRequested()),
            ),
            PaymentsStatus.success => const _Message(
              icon: Icons.receipt_long_outlined,
              text: 'Your payments will show up here.',
            ),
          };
        }

        final groups = _byMonth(state.items);
        return RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Stats(
                successful: state.successful.length,
                failed: state.failedCount,
              ),
              for (final g in groups)
                PlanSection(
                  title: BillingFormat.monthTitle(g.first.date),
                  trailing: Text(
                    PackageFormat.price(
                      g
                          .where((p) => p.isSuccess)
                          .fold(0, (sum, p) => sum + p.amountMinor),
                    ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: PlanColors.of(context).muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < g.length; i++)
                        PaymentRow(
                          payment: g[i],
                          showDivider: i > 0,
                          onTap: () => showPaymentReceipt(context, g[i]),
                        ),
                    ],
                  ),
                ),
              const _Footer(text: 'Tap a payment for the receipt'),
            ],
          ),
        );
      },
    );
  }

  /// Payments grouped by calendar month, newest month first.
  static List<List<PaymentRecord>> _byMonth(List<PaymentRecord> items) {
    final groups = <List<PaymentRecord>>[];
    int? key;
    for (final p in items) {
      final d = p.date.toLocal();
      final k = d.year * 100 + d.month;
      if (k != key) {
        groups.add([]);
        key = k;
      }
      groups.last.add(p);
    }
    return groups;
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.successful, required this.failed});

  final int successful;
  final int failed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = PlanColors.of(context);

    Widget stat(String value, String label, {Color? color}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color ?? c.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: c.muted)),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: stat('$successful', 'Successful')),
            VerticalDivider(width: 1, color: c.border),
            const SizedBox(width: 16),
            Expanded(
              child: stat(
                '$failed',
                'Failed',
                color: failed > 0 ? theme.colorScheme.error : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plan history
// ---------------------------------------------------------------------------

class _PlanHistoryTab extends StatelessWidget {
  const _PlanHistoryTab();

  Future<void> _refresh(BuildContext context) {
    final bloc = context.read<PlanHistoryBloc>()
      ..add(const PlanHistoryRequested());
    return bloc.stream.firstWhere((s) => s.status != PlanHistoryStatus.loading);
  }

  /// Loads the next page when the user gets near the bottom.
  bool _onScroll(BuildContext context, ScrollNotification n) {
    if (n.metrics.axis == Axis.vertical && n.metrics.extentAfter < 400) {
      final s = context.read<PlanHistoryBloc>().state;
      if (s.hasMore && !s.isLoadingMore && s.loadMoreFailure == null) {
        context.read<PlanHistoryBloc>().add(
          const PlanHistoryNextPageRequested(),
        );
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanHistoryBloc, PlanHistoryState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return switch (state.status) {
            PlanHistoryStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            PlanHistoryStatus.failure => _Message(
              icon: Icons.cloud_off_rounded,
              text:
                  state.failure?.message ?? "Couldn't load your plan history.",
              onRetry: () => context.read<PlanHistoryBloc>().add(
                const PlanHistoryRequested(),
              ),
            ),
            PlanHistoryStatus.success => const _Message(
              icon: Icons.history_rounded,
              text: 'Your plans will show up here.',
            ),
          };
        }

        final current = state.current;
        final past = state.past;
        final c = PlanColors.of(context);

        return NotificationListener<ScrollNotification>(
          onNotification: (n) => _onScroll(context, n),
          child: RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: ListView(
              padding: EdgeInsets.zero,
              // Always scrollable, so a short first page can still pull
              // to refresh and trigger loading more.
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (current != null)
                  PlanSection(
                    title: 'Current plan',
                    showBand: false,
                    child: CurrentPlanHistoryCard(entry: current),
                  ),
                if (past.isNotEmpty)
                  PlanSection(
                    title: 'Past plans',
                    showBand: current != null,
                    trailing: Text(
                      '${state.pastTotal}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: c.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < past.length; i++)
                          PlanHistoryRow(entry: past[i], showDivider: i > 0),
                      ],
                    ),
                  ),
                _PagingFooter(state: state),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Spinner while the next page loads, a retry if it failed, or nothing.
class _PagingFooter extends StatelessWidget {
  const _PagingFooter({required this.state});

  final PlanHistoryState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (state.loadMoreFailure != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: TextButton.icon(
            onPressed: () => context.read<PlanHistoryBloc>().add(
              const PlanHistoryNextPageRequested(),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text("Couldn't load more. Try again"),
          ),
        ),
      );
    }
    return const SizedBox(height: 24);
  }
}

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

class _Footer extends StatelessWidget {
  const _Footer({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = PlanColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.band, width: 8)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: c.muted),
          ),
        ),
      ),
    );
  }
}

/// Empty or error state. Scrollable so pull to refresh still works.
class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = PlanColors.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: c.muted),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.text),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
