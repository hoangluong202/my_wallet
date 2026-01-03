import 'package:flutter/material.dart';
import '../../../../core/widgets/header/detail_header.dart';
import '../../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../../core/widgets/notification_widget.dart';
import 'transaction_action_buttons.dart';
import '../form/edit_transaction_page.dart';
import '../../../../core/di/injector.dart';
import '../viewmodel/transaction_viewmodel.dart';
import '../model/transaction_view_data.dart';
import 'transaction_details_card.dart';

class TransactionDetailsPage extends StatefulWidget {
  final String transactionId;
  const TransactionDetailsPage({super.key, required this.transactionId});

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  late TransactionViewModel _viewModel;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<TransactionViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasChanges);
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: StreamBuilder<TransactionViewData?>(
            stream: _viewModel.watchTransactionById(widget.transactionId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || snapshot.data == null) {
                return _buildErrorState(snapshot.error);
              }

              final transaction = snapshot.data!;
              return Column(
                children: [
                  DetailHeader(
                    title: 'Transaction Details',
                    onBack: () => Navigator.pop(context, _hasChanges),
                  ),
                  Expanded(child: TransactionDetailsCard(transaction)),
                  TransactionActionButtons(
                    onEdit: () => _onEdit(context, transaction),
                    onDelete: () => _onDelete(context, transaction),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text('Error loading transaction'),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Go Back'),
          ),
        ],
      ),
    );
  }

  void _onEdit(BuildContext context, TransactionViewData transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionPage(transaction: transaction),
      ),
    );

    if (result == true) {
      setState(() {
        _hasChanges = true;
      });
      if (context.mounted) {
        SuccessNotification.show(
          context: context,
          message: 'Transaction updated successfully',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> _onDelete(
    BuildContext context,
    TransactionViewData transaction,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Transaction?',
      content: 'Are you sure you want to delete this transaction?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await _viewModel.deleteTransaction(transaction.id);
        if (context.mounted) {
          SuccessNotification.show(
            context: context,
            message: 'Transaction deleted successfully',
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          ErrorNotification.show(
            context: context,
            message: 'Failed to delete: $e',
          );
        }
      }
    }
  }
}
