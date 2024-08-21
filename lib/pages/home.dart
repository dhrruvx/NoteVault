import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:notevault1/pages/chat_ui.dart';
import 'package:notevault1/pages/notesview.dart';
import 'package:notevault1/pages/profile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 1; // default to Home tab

  @override
  void initState() {
    super.initState();
  }

  void _onTabChange(int index) {
    if (!mounted) return; // Ensure the widget is still mounted

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Notesview()),
        );
        break;
      case 1:
        // Do nothing, already on Home screen
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'ppt', 'pptx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String? selectedFolder = await _selectFolderDialog();

      if (selectedFolder != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('$selectedFolder/${result.files.single.name}');
          await storageRef.putFile(file);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File uploaded successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload file: $e')),
          );
        }
      }
    } else {
      // User canceled the picker
    }
  }

  Future<String?> _selectFolderDialog() async {
    List<String> folders = await _getFolders();
    String? selectedFolder;

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Folder'),
          content: SingleChildScrollView(
            child: Column(
              children: folders
                  .map((folder) => ListTile(
                        title: Text(folder),
                        onTap: () {
                          selectedFolder = folder;
                          Navigator.of(context).pop(folder);
                        },
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Future<List<String>> _getFolders() async {
    // Replace this with your logic to retrieve folders from Firebase Storage
    return [
      'folder1',
      'folder2',
      'folder3',
    ];
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
            padding: const EdgeInsets.all(16),
            tabs: const [
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
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        title: const Text(
          "Welcome",
          style: TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            // The DecoratedBox placed behind the Column
            Container(
              height: 300,
              width: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.deepPurple, // Background color
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(1, -0.5),
              child: Container(
                height: 300,
                width: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.deepOrange, // Background color
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
              padding: const EdgeInsets.only(left: 5, top: 25, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _buildCard("Upload Your Notes in form of PDFs/PPTs",
                          onTap: () {
                        _uploadFile();
                      }),
                      const SizedBox(height: 20),
                      _buildCard(
                        "Chat With AI",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChatUi()),
                          );
                        },
                      ),
                    ],
                  ),
                  _buildCard(
                    "Upload Your notes in Images!",
                    onTap: () {},
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String text, {VoidCallback? onTap}) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        gradient: LinearGradient(colors: [Colors.grey, Colors.purple]),
      ),
      height: 180,
      width: 180,
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Center(
          child: ListTile(
            title: Text(
              text,
              style: GoogleFonts.ubuntu(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
