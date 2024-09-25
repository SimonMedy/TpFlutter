import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medy_tp_flutter/services/firebase.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  void openDialogCode({String? existingCode, String? documentId}) async {
    _controller.text = existingCode ?? '';
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
              existingCode == null ? 'Ajouter le code' : 'Modifier le code',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Ton code ici poto..',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop('Cancel'),
              child: const Text('Annuler', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  if (existingCode == null) {
                    _firebaseService.createCode(_controller.text);
                  } else {
                    _firebaseService.updateCode(documentId!, _controller.text);
                  }
                  Navigator.of(context).pop('OK');
                  _controller.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(existingCode == null ? 'Ajouter' : 'Modifier',
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Official Firebase Codes app WOW!',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openDialogCode(),
        tooltip: 'Ajouter du code',
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseService.getCodes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Erreur: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child:
                    Text('Aucun code trouvé', style: TextStyle(fontSize: 18)));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    data['code'] ?? 'Code inconnu',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => openDialogCode(
                            existingCode: data['code'],
                            documentId: document.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirmer la suppression"),
                                content: const Text(
                                    "Êtes-vous sûr de vouloir supprimer ce code ?"),
                                actions: [
                                  TextButton(
                                    child: const Text(
                                      "Annuler",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _firebaseService.deleteCode(document.id);
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    child: const Text(
                                      "Supprimer",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
