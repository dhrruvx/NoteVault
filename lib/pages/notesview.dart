import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:notevault1/pages/home.dart';

class Notesview extends StatefulWidget {
  const Notesview({super.key});

  @override
  State<Notesview> createState() => _NotesviewState();
}

class _NotesviewState extends State<Notesview> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Map<String, dynamic>> _notes = [];
  final TextEditingController _titleController = TextEditingController();
  int _selectedIndex = 0; // default to Notes tab

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    try {
      ListResult result = await FirebaseStorage.instance.ref('notes').listAll();
      setState(() {
        _notes.clear();
        for (var prefix in result.prefixes) {
          _notes.add({'title': prefix.name});
        }
      });
    } catch (e) {
      print('Error occurred while fetching notes: $e');
    }
  }

  Future<void> _addNote() async {
    if (_titleController.text.isEmpty) return;

    try {
      // Create a folder in Firebase Storage
      String folderName = _titleController.text;
      Reference storageRef =
          FirebaseStorage.instance.ref().child('notes/$folderName/');
      await storageRef
          .child('placeholder.txt')
          .putString('This is a placeholder file.');

      _fetchNotes(); // Refresh the list of notes
      _titleController.clear();
      Navigator.pop(context);
    } catch (e) {
      print('Error occurred while creating folder: $e');
    }
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Add Note Title"),
          content: TextField(
            controller: _titleController,
            decoration: InputDecoration(hintText: "Enter title"),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("Add"),
              onPressed: _addNote,
            ),
          ],
        );
      },
    );
  }

  void _onTabChange(int index) {
    if (!mounted) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Do nothing, already on Notesview screen
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 2:
        // Navigate to Profile screen
        // Implement your profile screen navigation here
        break;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.grey.shade900,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: GNav(
            backgroundColor: Colors.grey.shade900,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 8,
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              if (mounted) {
                _onTabChange(index);
              }
            },
            padding: EdgeInsets.all(16),
            tabs: [
              GButton(
                icon: Icons.notes,
                text: "My Notes",
              ),
              GButton(
                icon: Icons.home,
                text: "Home",
              ),
              GButton(
                icon: Icons.person,
                text: "Profile",
              ),
            ],
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        title: Text(
          "My Notes",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddNoteDialog,
          ),
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            Container(
              height: 300,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.deepPurple,
              ),
            ),
            Align(
              alignment: AlignmentDirectional(1, -0.5),
              child: Container(
                height: 300,
                width: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                decoration: const BoxDecoration(color: Colors.transparent),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Card(
                    color: Colors.transparent,
                    child: ListTile(
                      title: Text(
                        note['title'],
                        style: GoogleFonts.ubuntu(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
