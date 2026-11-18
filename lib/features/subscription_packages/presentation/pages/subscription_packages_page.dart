import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/subscription_package.dart';
import '../bloc/subscription_packages_cubit.dart';
import '../widgets/package_widgets.dart';

/// Lets the candidate compare plans and pick one.
///
/// [onContinue] runs when the user taps the bottom button. Until checkout
/// is wired up, it defaults to an info snackbar.
class SubscriptionPackagesPage extends StatelessWidget {
  const SubscriptionPackagesPage({
    super.key,
    this.type = PackageType.candidate,
    this.onContinue,
  });

  final PackageType type;
  final void Function(BuildContext context, SubscriptionPackage package)?
  onContinue;

  static Route<void> route({
    PackageType type = PackageType.candidate,
    void Function(BuildContext, SubscriptionPackage)? onContinue,
  }) => MaterialPageRoute(
    builder: (_) =>
        SubscriptionPackagesPage(type: type, onContinue: onContinue),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SubscriptionPackagesCubit>()..load(type),
      child: _PackagesView(type: type, onContinue: onContinue),
    );
  }
}

class _PackagesView extends StatelessWidget {
  const _PackagesView({required this.type, this.onContinue});

  final PackageType type;
  final void Function(BuildContext, SubscriptionPackage)? onContinue;

  void _continue(BuildContext context, SubscriptionPackage p) {
    if (onContinue != null) {
      onContinue!(context, p);
      return;
    }
    AppSnackbar.info(
      title: p.isFree ? 'You can keep using ${p.name}' : 'Checkout coming soon',
      message: p.isFree
          ? null
          : 'Payments for ${p.name} will be available shortly.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Choose your plan'),
        backgroundColor: packageAccent(
          context,
        ).withValues(alpha: theme.brightness == Brightness.dark ? 0.22 : 0.08),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<SubscriptionPackagesCubit, SubscriptionPackagesState>(
        builder: (context, state) => switch (state.status) {
          PackagesLoadStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          PackagesLoadStatus.failure => _ErrorView(
            message: state.failure?.message ?? 'Couldn\'t load plans.',
            onRetry: () => context.read<SubscriptionPackagesCubit>().load(type),
          ),
          PackagesLoadStatus.success when state.packages.isEmpty =>
            const _ErrorView(message: 'No plans are available right now.'),
          PackagesLoadStatus.success => _content(context, state),
        },
      ),
      bottomNavigationBar:
          BlocBuilder<SubscriptionPackagesCubit, SubscriptionPackagesState>(
            buildWhen: (a, b) => a.selected != b.selected,
            builder: (context, state) {
              final p = state.selected;
              if (p == null) return const SizedBox.shrink();
              return _BottomBar(
                package: p,
                onPressed: () => _continue(context, p),
              );
            },
          ),
    );
  }

  Widget _content(BuildContext context, SubscriptionPackagesState state) {
    final theme = Theme.of(context);
    final cubit = context.read<SubscriptionPackagesCubit>();
    final selected = state.selected;
    return RefreshIndicator(
      onRefresh: () => cubit.load(type),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          PackagesHeader(highlights: _highlights(state.packages)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a plan',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                for (final p in state.packages)
                  PackageOptionCard(
                    package: p,
                    selected: p.id == state.selectedId,
                    recommended: p.id == state.recommendedId,
                    onTap: () => cubit.select(p.id),
                  ),
                const SizedBox(height: 14),
                Text(
                  'What you get',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                PackageComparisonTable(
                  packages: state.packages,
                  selectedId: state.selectedId,
                ),
                if (selected?.requiresVerification ?? false) ...[
                  const SizedBox(height: 14),
                  const VerificationNote(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// e.g. "33x more applications" comparing the free and top paid plan.
  static List<String> _highlights(List<SubscriptionPackage> packages) {
    final free = packages.where((p) => p.isFree).firstOrNull;
    final paid = packages.where((p) => !p.isFree).toList()
      ..sort(
        (a, b) =>
            (b.monthlyApplications ?? 0).compareTo(a.monthlyApplications ?? 0),
      );
    final top = paid.firstOrNull;
    final out = <String>[];
    final base = free?.monthlyApplications ?? 0;
    final more = top?.monthlyApplications ?? 0;
    if (base > 0 && more > base) {
      out.add('${(more / base).floor()}x more applications');
    }
    if (packages.any((p) => p.has(PackageFeature.verifiedBadge))) {
      out.add('Verified badge');
    }
    if (packages.any((p) => p.has(PackageFeature.jobAlerts))) {
      out.add('Instant job alerts');
    }
    return out;
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.package, required this.onPressed});

  final SubscriptionPackage package;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = package;
    final label = p.isFree
        ? 'Continue with ${p.name}'
        : 'Continue · ${PackageFormat.price(p.priceMinor, currency: p.currency)}';
    final muted = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            p.isFree
                ? OutlinedButton(
                    onPressed: onPressed,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(label),
                  )
                : FilledButton(
                    onPressed: p.purchaseAvailable ? onPressed : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: packageAccent(context),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(label),
                  ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text('Secure payment', style: muted),
                Text('  ·  ', style: muted),
                Text(
                  'Valid for ${PackageFormat.duration(p.durationDays)}',
                  style: muted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
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
