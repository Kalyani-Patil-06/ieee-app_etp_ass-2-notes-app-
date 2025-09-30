// import 'package:flutter/material.dart';

// void main() {
//   runApp(const NotesApp());
// }

// class NotesApp extends StatelessWidget {
//   const NotesApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Name & Hobby Notes',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: Colors.lightBlue,
//         colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
//             .copyWith(secondary: Colors.lightBlueAccent),
//       ),
//       home: const NotesPage(),
//     );
//   }
// }

// class NotesPage extends StatefulWidget {
//   const NotesPage({super.key});

//   @override
//   State<NotesPage> createState() => _NotesPageState();
// }

// class _NotesPageState extends State<NotesPage> {
//   // Store notes as Map with name & hobby
//   List<Map<String, String>> notes = [];

//   void _addNote() {
//     _showNoteDialog(isEdit: false);
//   }

//   void _editNote(int index) {
//     _showNoteDialog(isEdit: true, noteIndex: index);
//   }

//   void _deleteNote(int index) {
//     setState(() {
//       notes.removeAt(index);
//     });
//   }

//   void _showNoteDialog({required bool isEdit, int? noteIndex}) {
//     TextEditingController nameController = TextEditingController(
//       text: isEdit ? notes[noteIndex!]["name"] : "",
//     );
//     TextEditingController hobbyController = TextEditingController(
//       text: isEdit ? notes[noteIndex!]["hobby"] : "",
//     );

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(isEdit ? "Edit Entry" : "Add Entry"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   labelText: "Name",
//                   hintText: "Enter name",
//                 ),
//               ),
//               TextField(
//                 controller: hobbyController,
//                 decoration: const InputDecoration(
//                   labelText: "Hobby",
//                   hintText: "Enter hobby",
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   if (isEdit) {
//                     notes[noteIndex!] = {
//                       "name": nameController.text,
//                       "hobby": hobbyController.text,
//                     };
//                   } else {
//                     notes.add({
//                       "name": nameController.text,
//                       "hobby": hobbyController.text,
//                     });
//                   }
//                 });
//                 Navigator.pop(context);
//               },
//               child: Text(isEdit ? "Update" : "Add"),
//             )
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Name & Hobby Notes")),
//       body: notes.isEmpty
//           ? const Center(child: Text("No entries yet. Tap + to add one!"))
//           : ListView.builder(
//               itemCount: notes.length,
//               itemBuilder: (context, index) {
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                   child: ListTile(
//                     title: Text(
//                       notes[index]["name"]!,
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                     subtitle: Text("Hobby: ${notes[index]["hobby"]}"),
//                     onTap: () => _editNote(index),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => _deleteNote(index),
//                     ),
//                   ),
//                 );
//               },
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _addNote,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lmeerzallgwsdrfdpczu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxtZWVyemFsbGd3c2RyZmRwY3p1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyMDI0NzgsImV4cCI6MjA3NDc3ODQ3OH0.OQduKTvn_9XDI7jz1QaRypGigpLYpGhNrOFSgzE3GOg',
  );

  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Name & Hobby Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.grey,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blueGrey,
          secondary: Colors.grey,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 136, 211, 246),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 136, 211, 246),
        ),
      ),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, String>> notes = [];
  final supabase = Supabase.instance.client;

  void _addNote() {
    _showNoteDialog(isEdit: false);
  }

  void _editNote(int index) {
    _showNoteDialog(isEdit: true, noteIndex: index);
  }

  void _deleteNote(int index) async {
    final note = notes[index];
    setState(() {
      notes.removeAt(index);
    });

    // Delete from Supabase
    try {
      await supabase
          .from('Notes app') // table name with quotes
          .delete()
          .eq('Name', note['name'] ?? "")
          .eq('Hobby', note['hobby'] ?? "")
          .select();
    } catch (e) {
      print('Supabase delete error: $e');
    }
  }

  void _showNoteDialog({required bool isEdit, int? noteIndex}) {
    TextEditingController nameController = TextEditingController(
      text: isEdit ? notes[noteIndex!]["name"] : "",
    );
    TextEditingController hobbyController = TextEditingController(
      text: isEdit ? notes[noteIndex!]["hobby"] : "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? "Edit Entry" : "Add Entry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "Enter name",
                ),
              ),
              TextField(
                controller: hobbyController,
                decoration: const InputDecoration(
                  labelText: "Hobby",
                  hintText: "Enter hobby",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 136, 211, 246),
              ),
              onPressed: () async {
                final name = nameController.text;
                final hobby = hobbyController.text;

                setState(() {
                  if (isEdit) {
                    notes[noteIndex!] = {"name": name, "hobby": hobby};
                  } else {
                    notes.add({"name": name, "hobby": hobby});
                  }
                });

                Navigator.pop(context);

                // Insert or update in Supabase
                try {
                  if (isEdit) {
                    final oldNote = notes[noteIndex!];
                    await supabase
                        .from('Notes app')
                        .update({'Name': name, 'Hobby': hobby})
                        .eq('Name', oldNote['name'] ?? "")
                        .eq('Hobby', oldNote['hobby'] ?? "")
                        .select();
                  } else {
                    await supabase
                        .from('Notes app')
                        .insert({'Name': name, 'Hobby': hobby})
                        .select();
                  }
                } catch (e) {
                  print('Supabase error: $e');
                }
              },
              child: Text(isEdit ? "Update" : "Add"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Name & Hobby Notes")),
      body: notes.isEmpty
          ? const Center(child: Text("No entries yet. Tap + to add one!"))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.purple[50],
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text(
                      notes[index]["name"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text("Hobby: ${notes[index]["hobby"]}"),
                    onTap: () => _editNote(index),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteNote(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
