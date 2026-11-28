import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../subscription_plan_buy_history/presentation/pages/billing_history_page.dart';

/// Navy app bar for the plans screen, matching the app's other screens
/// (e.g. Job alerts): back button, title + subtitle, billing history.
class PlansAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PlansAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: AppColors.logoNavy,
      foregroundColor: AppColors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: const AppBackButton(),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Plans', style: TextStyle(color: AppColors.white)),
          Text(
            'Apply more, get alerts, stand out',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Billing history',
          icon: const Icon(Icons.receipt_long_outlined),
          color: AppColors.white,
          onPressed: () =>
              Navigator.of(context).push(BillingHistoryPage.route()),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: theme.colorScheme.outlineVariant),
      ),
    );
  }
}
