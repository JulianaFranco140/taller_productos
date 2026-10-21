import '../models/product_note.dart';

// El repository decide cuándo enviar. Esta clase solo envía una nota.
abstract class RemoteNoteStore {
  Future<void> upload(ProductNote note);
}