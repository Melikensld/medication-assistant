import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyNotesPage extends StatefulWidget {
  @override
  _MyNotesPageState createState() => _MyNotesPageState();
}

class _MyNotesPageState extends State<MyNotesPage> {
  List<String> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes'),
      ),
      body: _buildNotesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddNoteDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildNotesList() {
  return Container(
    margin: EdgeInsets.all(20.0),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return _buildNoteCard(notes[index]);
        },
      ),
    ),
  );
}


Widget _buildNoteCard(String note) {
  List<String> noteLines = note.split('\n');
  String noteText = noteLines[0];
  String dateTime = noteLines.length > 1 ? noteLines[1] : '';

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            noteText,
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 8),
          if (dateTime.isNotEmpty)
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                dateTime,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editNoteDialog(note);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteNoteDialog(note);
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


void _editNoteDialog(String note) {
  TextEditingController noteController = TextEditingController(text: note.split('\n')[0]);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit Note'),
        content: TextField(
          controller: noteController,
          decoration: InputDecoration(labelText: 'Edit your note'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                setState(() {
                  int index = notes.indexOf(note);
                  String editedNote = '${noteController.text}\nEdited on: ${_getFormattedDateTime()}';
                  notes[index] = editedNote;
                  _saveNotes();
                });
              }
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}


String _getFormattedDateTime() {
  DateTime now = DateTime.now();
  return '${now.day}/${now.month}/${now.year} ${_formatTime(now)}';
}

String _formatTime(DateTime dateTime) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  return "${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}";
}


  void _showAddNoteDialog() {
  TextEditingController noteController = TextEditingController();
  DateTime currentDate = DateTime.now();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add Note'),
        content: TextField(
          controller: noteController,
          decoration: InputDecoration(labelText: 'Enter your note'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                setState(() {
                  String noteWithDate = '${noteController.text}\nAdded on: $currentDate';
                  notes.add(noteWithDate);
                  _saveNotes();
                });
              }
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}


  void _deleteNoteDialog(String note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('delete Note'),
          content: Text('Are you sure you want to delete this note ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  notes.remove(note);
                  _saveNotes();
                });
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notes = prefs.getStringList('notesKey') ?? [];
    });
  }

  void _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('notesKey', notes);
  }
}
