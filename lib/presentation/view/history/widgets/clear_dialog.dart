import 'package:flutter/material.dart';

void showClearDialog(BuildContext context, Future<void> Function() onClear) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color.fromARGB(255, 25, 14, 45),
      title: const Text('Geçmişi Temizle'),
      content: const Text(
        'Bu kategorideki tüm analiz geçmişini silmek istediğinizden emin misiniz?\n\n'
        'Bu işlem geri alınamaz.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            try {
              await onClear();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Analiz geçmişi temizlendi')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Hata: $e'), backgroundColor: Colors.red),
                );
              }
            }
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Temizle'),
        ),
      ],
    ),
  );
}
