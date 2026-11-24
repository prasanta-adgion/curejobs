import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../subscription_plan_buy_history/presentation/pages/billing_history_page.dart';
import '../../domain/entities/subscription_package.dart';
import '../bloc/current_plan_bloc.dart';
import '../bloc/plan_purchase_bloc.dart';
import '../bloc/subscription_packages_bloc.dart';
import '../services/razorpay_service.dart';
import '../widgets/package_widgets.dart';

/// Lets the candidate see their current plan, compare plans and pick one.
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<SubscriptionPackagesBloc>()
                ..add(SubscriptionPackagesRequested(type)),
        ),
        BlocProvider(
          create: (_) =>
              sl<CurrentPlanBloc>()..add(const CurrentPlanRequested()),
        ),
        BlocProvider(create: (_) => sl<PlanPurchaseBloc>()),
      ],
      child: _PurchaseCoordinator(
        type: type,
        child: _PackagesView(type: type, onContinue: onContinue),
      ),
    );
  }
}

/// Owns the Razorpay SDK for this screen: opens checkout when the purchase
/// bloc is ready, forwards the SDK callbacks to the bloc, shows outcomes,
/// refreshes plans after success and blocks back while a payment runs.
class _PurchaseCoordinator extends StatefulWidget {
  const _PurchaseCoordinator({required this.type, required this.child});

  final PackageType type;
  final Widget child;

  @override
  State<_PurchaseCoordinator> createState() => _PurchaseCoordinatorState();
}

class _PurchaseCoordinatorState extends State<_PurchaseCoordinator> {
  late final PlanPurchaseBloc _bloc = context.read<PlanPurchaseBloc>();
  late final RazorpayService _razorpay = RazorpayService(
    onSuccess: (r) => _add(
      PlanPaymentSucceeded(
        paymentId: r.paymentId,
        subscriptionId: r.data?['razorpay_subscription_id'] as String?,
        signature: r.signature ?? r.data?['razorpay_signature'] as String?,
      ),
    ),
    onError: (r) => _add(PlanPaymentFailed(code: r.code, message: r.message)),
    onExternalWallet: (r) => _add(PlanPaymentExternalWallet(r.walletName)),
  );

  /// SDK callbacks can arrive after the screen is gone (e.g. UPI app switch).
  void _add(PlanPurchaseEvent event) {
    if (!_bloc.isClosed) _bloc.add(event);
  }

  @override
  void dispose() {
    _razorpay.dispose();
    super.dispose();
  }

  void _onState(BuildContext context, PlanPurchaseState state) {
    switch (state.status) {
      case PlanPurchaseStatus.checkoutReady:
        final checkout = state.checkout;
        if (checkout == null) return;
        try {
          _razorpay.open(checkout);
          _bloc.add(const PlanCheckoutOpened());
        } catch (_) {
          _bloc.add(
            const PlanPaymentFailed(message: "Couldn't open the payment page."),
          );
        }
      case PlanPurchaseStatus.success:
        AppSnackbar.success(
          title: 'Payment successful',
          message: state.message,
        );
        _refreshPlans(context);
        _bloc.add(const PlanPurchaseReset());
      case PlanPurchaseStatus.pendingActivation:
        AppSnackbar.info(
          title: 'Activation in progress',
          message: state.message,
        );
        _refreshPlans(context);
      case PlanPurchaseStatus.cancelled:
        AppSnackbar.info(title: 'Payment cancelled', message: state.message);
        _bloc.add(const PlanPurchaseReset());
      case PlanPurchaseStatus.failure:
        AppSnackbar.error(
          title: 'Payment failed',
          message: state.message ?? 'Please try again.',
        );
      case PlanPurchaseStatus.idle ||
          PlanPurchaseStatus.creating ||
          PlanPurchaseStatus.inCheckout ||
          PlanPurchaseStatus.verifying:
        break;
    }
  }

  void _refreshPlans(BuildContext context) {
    context.read<CurrentPlanBloc>().add(const CurrentPlanRequested());
    context.read<SubscriptionPackagesBloc>().add(
      SubscriptionPackagesRequested(widget.type),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlanPurchaseBloc, PlanPurchaseState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: _onState,
      buildWhen: (a, b) =>
          a.isBusy != b.isBusy ||
          (a.status == PlanPurchaseStatus.verifying) !=
              (b.status == PlanPurchaseStatus.verifying),
      builder: (context, state) => PopScope(
        canPop: !state.isBusy,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            AppSnackbar.info(
              title: 'Payment in progress',
              message: 'Please wait until the payment finishes.',
            );
          }
        },
        child: Stack(
          children: [
            widget.child,
            if (state.status == PlanPurchaseStatus.verifying)
              const _VerifyingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _VerifyingOverlay extends StatelessWidget {
  const _VerifyingOverlay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Confirming your payment…',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Please don't close the app.",
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
    if (p.isFree) {
      AppSnackbar.info(title: 'You can keep using ${p.name}');
      return;
    }
    // Never start a payment for the plan the user already has.
    final currentId = context
        .read<CurrentPlanBloc>()
        .state
        .subscription
        ?.package
        .id;
    if (p.id == currentId) {
      AppSnackbar.info(title: "You're already on ${p.name}");
      return;
    }
    context.read<PlanPurchaseBloc>().add(PlanPurchaseStarted(p));
  }

  Future<void> _refresh(BuildContext context) {
    final packages = context.read<SubscriptionPackagesBloc>();
    context.read<CurrentPlanBloc>().add(const CurrentPlanRequested());
    packages.add(SubscriptionPackagesRequested(type));
    // Keep the spinner until the plans reload finishes.
    return packages.stream.firstWhere(
      (s) => s.status != PackagesLoadStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentId = context.select(
      (CurrentPlanBloc b) => b.state.subscription?.package.id,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Light status-bar icons over the navy header in both themes.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: BlocBuilder<SubscriptionPackagesBloc, SubscriptionPackagesState>(
          builder: (context, state) => switch (state.status) {
            PackagesLoadStatus.loading => const _Shell(
              child: Center(child: CircularProgressIndicator()),
            ),
            PackagesLoadStatus.failure => _Shell(
              child: _ErrorView(
                message: state.failure?.message ?? "Couldn't load plans.",
                onRetry: () => context.read<SubscriptionPackagesBloc>().add(
                  SubscriptionPackagesRequested(type),
                ),
              ),
            ),
            PackagesLoadStatus.success when state.packages.isEmpty =>
              const _Shell(
                child: _ErrorView(message: 'No plans are available right now.'),
              ),
            PackagesLoadStatus.success => RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: _content(context, state, currentId),
            ),
          },
        ),
        bottomNavigationBar:
            BlocBuilder<SubscriptionPackagesBloc, SubscriptionPackagesState>(
              buildWhen: (a, b) => a.selected != b.selected,
              builder: (context, state) {
                final p = state.selected;
                if (p == null) return const SizedBox.shrink();
                final busy = context.select(
                  (PlanPurchaseBloc b) => b.state.isBusy,
                );
                return _BottomBar(
                  package: p,
                  isCurrent: p.id == currentId,
                  busy: busy,
                  onPressed: () => _continue(context, p),
                );
              },
            ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    SubscriptionPackagesState state,
    String? currentId,
  ) {
    final bloc = context.read<SubscriptionPackagesBloc>();
    final c = PlanColors.of(context);
    final theme = Theme.of(context);
    final selected = state.selected;

    return ListView(
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        PackagesHeader(highlights: _highlights(state.packages)),
        const _CurrentPlanSection(),
        PlanSection(
          title: 'Choose a plan',
          child: Column(
            children: [
              for (final p in state.packages)
                PackageOptionCard(
                  package: p,
                  selected: p.id == state.selectedId,
                  recommended: p.id == state.recommendedId,
                  isCurrent: p.id == currentId,
                  onTap: () => bloc.add(SubscriptionPackageSelected(p.id)),
                ),
            ],
          ),
        ),
        PlanSection(
          title: 'What you get',
          trailing: selected == null
              ? null
              : Text(
                  '${PackageFormat.shortName(selected.name)} selected',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: c.accentText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (selected != null) ...[
                SelectedPlanBanner(
                  package: selected,
                  isCurrent: selected.id == currentId,
                ),
                const SizedBox(height: 12),
              ],
              PackageComparisonTable(
                packages: state.packages,
                selectedId: state.selectedId,
              ),
              if (selected?.requiresVerification ?? false) ...[
                const SizedBox(height: 14),
                VerificationNote(
                  planName: PackageFormat.shortName(selected!.name),
                ),
              ],
            ],
          ),
        ),
        const _BillingHistoryLink(),
      ],
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
      out.add('Job alerts');
    }
    return out;
  }
}

/// "Your current plan". Hidden if it fails to load, so the plans still show.
class _CurrentPlanSection extends StatelessWidget {
  const _CurrentPlanSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentPlanBloc, CurrentPlanState>(
      builder: (context, state) {
        final sub = state.subscription;
        if (sub == null) {
          if (state.status == CurrentPlanStatus.failure) {
            return const SizedBox.shrink();
          }
          return const PlanSection(
            title: 'Your current plan',
            showBand: false,
            child: SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        return PlanSection(
          title: 'Your current plan',
          showBand: false,
          child: CurrentPlanSummary(subscription: sub),
        );
      },
    );
  }
}

/// "Billing history ›" row at the bottom of the plans list.
class _BillingHistoryLink extends StatelessWidget {
  const _BillingHistoryLink();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = PlanColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.band, width: 8)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        leading: Icon(Icons.receipt_long_outlined, color: c.muted),
        title: Text(
          'Billing history',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: c.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Payments and plan changes',
          style: theme.textTheme.bodySmall?.copyWith(color: c.muted),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: c.muted),
        onTap: () => Navigator.of(context).push(BillingHistoryPage.route()),
      ),
    );
  }
}

/// Navy header plus [child], for loading and error states.
class _Shell extends StatelessWidget {
  const _Shell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PackagesHeader(highlights: []),
        Expanded(child: child),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.package,
    required this.isCurrent,
    required this.onPressed,
    this.busy = false,
  });

  final SubscriptionPackage package;
  final bool isCurrent;
  final VoidCallback onPressed;

  /// A payment is running: the button is disabled and shows a spinner.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = PlanColors.of(context);
    final p = package;
    final name = PackageFormat.shortName(p.name);
    final price = PackageFormat.price(p.priceMinor, currency: p.currency);
    final muted = theme.textTheme.labelSmall?.copyWith(color: c.muted);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    final Widget button;
    // Free plans, and any plan the user already has, can't be bought here.
    if (p.isFree || isCurrent) {
      button = OutlinedButton(
        onPressed: isCurrent ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: shape,
          foregroundColor: c.text,
          disabledForegroundColor: c.muted,
          side: BorderSide(color: c.border),
        ),
        child: Text(isCurrent ? "You're on $name" : 'Continue with $name'),
      );
    } else {
      button = FilledButton(
        onPressed: p.purchaseAvailable && !busy ? onPressed : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: c.accentFill,
          foregroundColor: AppColors.white,
          shape: shape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        child: busy
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.white,
                ),
              )
            : Text('Upgrade to $name · $price'),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            button,
            if (!p.isFree) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 13, color: c.muted),
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
    final c = PlanColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: c.muted),
            const SizedBox(height: 12),
            Text(
              message,
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
