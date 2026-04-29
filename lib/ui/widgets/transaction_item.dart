import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:tiem_rua_xe/models/transaction_model.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final bool isLatest;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.isLatest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        // Thay Colors.emerald bằng Colors.green
        color: isLatest ? Colors.green.withOpacity(0.1) : Colors.transparent,
        border: isLatest ? Border.all(color: Colors.green.withOpacity(0.5)) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GFListTile(
        avatar: GFAvatar(
          // Thay Colors.emerald bằng Colors.green
          backgroundColor: isLatest ? Colors.green : Colors.blueGrey,
          child: const Icon(Icons.attach_money, color: Colors.white),
        ),
        titleText: NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
            .format(transaction.amount),
        subTitleText: "${transaction.time} - ${transaction.content}",
        description: Text(
          "Mã: ${transaction.ref}",
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        icon: isLatest 
            ? const Icon(Icons.new_releases, color: Colors.green, size: 16)
            : const Icon(Icons.chevron_right, size: 16),
      ),
    );
  }
}