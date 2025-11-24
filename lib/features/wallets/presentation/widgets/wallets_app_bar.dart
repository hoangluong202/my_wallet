import 'package:flutter/material.dart';
import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/wallets_viewmodel.dart';

class WalletsAppBar extends StatelessWidget {
  final VoidCallback onAddPressed;
  final VoidCallback onSyncPressed;
  final WalletsViewModel? viewModel;

  const WalletsAppBar({
    super.key,
    required this.onAddPressed,
    required this.onSyncPressed,
    this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Wallets',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (viewModel != null)
          ListenableBuilder(
            listenable: viewModel!,
            builder: (context, _) {
              final isSyncing = viewModel!.isSyncing;
              return Tooltip(
                message: isSyncing
                    ? 'Syncing...'
                    : 'Sync wallets (local → cloud → local)',
                child: IconButton(
                  onPressed: isSyncing ? null : onSyncPressed,
                  icon: isSyncing
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      : const Icon(Icons.cloud_sync),
                  style: IconButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          )
        else
          IconButton(
            onPressed: onSyncPressed,
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Sync to Cloud',
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        const SizedBox(width: 8),
        // Sign Out Menu
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'signout') {
              final authViewModel = getIt.get<AuthViewModel>();
              await authViewModel.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRouter.login);
              }
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'signout',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Sign Out'),
                ],
              ),
            ),
          ],
          icon: const Icon(Icons.more_vert),
          tooltip: 'Menu',
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: onAddPressed,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ],
    );
  }
}
