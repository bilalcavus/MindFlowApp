import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/data/models/support_ticket_model.dart';

class UserTicketRepository {
  final FirestoreService _firestoreService;

  UserTicketRepository(this._firestoreService);

  Future<void> createSupportTicket(SupportTicketModel ticket) async{
    return await _firestoreService.createSupportTicket(ticket);
  }
}