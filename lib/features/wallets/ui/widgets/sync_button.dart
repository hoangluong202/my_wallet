import 'package:flutter/material.dart';
import '../viewmodels/wallets_viewmodel.dart';

class SyncButton extends StatelessWidget {
  final WalletsViewModel viewModel;
  final String userId;

  const SyncButton({super.key, required this.viewModel, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final isSyncing = viewModel.isSyncing;
        final syncMessage = viewModel.syncMessage;

        // Show sync message dialog if present
        if (syncMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSyncDialog(context, syncMessage, isSyncing);
          });
        }

        return Tooltip(
          message: 'Sync wallets (local → cloud → local)',
          child: IconButton(
            icon: isSyncing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : const Icon(Icons.cloud_sync),
            onPressed: isSyncing ? null : () => _onSyncPressed(context),
          ),
        );
      },
    );
  }

  void _onSyncPressed(BuildContext context) async {
    try {
      // Start sync
      await viewModel.bidirectionalSync(userId);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSyncDialog(BuildContext context, String message, bool isSyncing) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Syncing...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSyncing)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(),
                ),
              ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );

    // Auto-close dialog when sync completes
    if (!isSyncing) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          Navigator.pop(context);
        }
      });
    }
  }
}
