import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_note.dart';
import 'remote_note_store.dart';

class FirestoreNoteStore implements RemoteNoteStore {
  @override
  Future<void> upload(ProductNote note) {
    return FirebaseFirestore.instance
        .collection('product_notes')
        .doc(note.productId.toString())
        .set(note.toJson());
  }
}