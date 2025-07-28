import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/data/models/support_ticket_model.dart';
import 'package:mind_flow/data/repositories/user_ticket_repository.dart';

class SupportTicketProvider extends ChangeNotifier {
  final UserTicketRepository _repository;

  SupportTicketProvider(this._repository);

  TextEditingController controller = TextEditingController();
  bool _isLoading = false;
  bool? get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<SupportTicketModel> _tickets = [];
  List<SupportTicketModel> get tickets => _tickets;

    void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> createTicket(BuildContext context) async {
    if (!validatePasswordChange()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ticket_is_empty'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    try {
      _setLoading(true);
      await Future.delayed(const Duration(seconds: 2));
      final currentUser = FirebaseAuth.instance.currentUser!;
      final ticket = SupportTicketModel(
        id: '',
        userId: currentUser.uid,
        email: currentUser.email ?? '',
        subject: 'Support Request',
        message: controller.text.trim(),
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.createSupportTicket(ticket);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ticked_sent'.tr()),
          backgroundColor: Colors.green,
          ),
        );
        clearText();
      }
    } catch (e) {
      _error = 'Destek talebi oluşturulamadı: $e';
    }
    finally{
      _setLoading(false);
    }
  }

  bool validatePasswordChange() {
    if (controller.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  void clearText(){
    controller.clear();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}