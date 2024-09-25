import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final CollectionReference codes =
      FirebaseFirestore.instance.collection('codes');

  Future<DocumentReference> createCode(String code) async {
    final DocumentReference documentReference = await codes.add({
      'code': code,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return documentReference;
  }

  Stream<QuerySnapshot> getCodes() {
    return codes.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> updateCode(String documentId, String newCode) async {
    await codes.doc(documentId).update({
      'code': newCode,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCode(String documentId) async {
    await codes.doc(documentId).delete();
  }
}
