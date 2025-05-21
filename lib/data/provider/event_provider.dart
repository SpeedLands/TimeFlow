import 'package:timeflow/data/model/agenda_model.dart';
import 'package:timeflow/data/services/firestore_service.dart';

class EventProvider {
  final FirestoreService _firestoreService;

  EventProvider(this._firestoreService);

  final String collection = "events";

  /// Obtiene todos los eventos como un Stream
  Stream<List<Event>> getEvents() {
    return _firestoreService.listenToCollection(collection).map((snapshot) {
      return snapshot.docs.map((doc) {
        return Event.fromFirestore(
          (doc.data() ?? {}) as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Obtiene un solo evento por su ID
  Future<Event?> getEventById(String eventId) async {
    final doc = await _firestoreService.getDocument(collection, eventId);

    if (doc != null && doc.exists) {
      return Event.fromFirestore(
        (doc.data() ?? {}) as Map<String, dynamic>,
        eventId,
      );
    }

    return null;
  }

  /// Agrega un nuevo evento
  Future<void> addEvent(Event event) async {
    await _firestoreService.addDocument(collection, event.toMap());
  }

  /// Actualiza un evento por su ID
  Future<void> updateEvent(Event updatedEvent, String id) async {
    await _firestoreService.updateDocument(
      collection,
      id,
      updatedEvent.toMap(),
    );
  }

  /// Elimina un evento por su ID
  Future<void> deleteEvent(String eventId) async {
    await _firestoreService.deleteDocument(collection, eventId);
  }
}
