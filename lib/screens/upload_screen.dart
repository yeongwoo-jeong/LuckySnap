import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  UploadScreenState createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _webImage;
  XFile? _selectedImage;
  int? _luckScore;
  late ConfettiController _confettiController;
  String _getLuckButtonText = "Get Luck Score";
  bool _showSaveButton = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadWebImage(XFile? image) async {
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (mounted) {
      setState(() {
        _webImage = bytes;
      });
    }
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          _selectedImage = pickedFile;
          _webImage = null;
        });
        _loadWebImage(pickedFile);
      }
    }
  }

  void _showChoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose option"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: const Text("Gallery"),
                  onTap: () {
                    _handleImageSelection(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: const Text("Camera"),
                  onTap: () {
                    _handleImageSelection(ImageSource.camera);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveLuckScore() {
    debugPrint(_luckScore.toString());
  }

  void _getLuckScore() {
    setState(() {
      _getLuckButtonText = "Lucky? Unlucky?";
      _showSaveButton = false;
    });
    Future.delayed(const Duration(seconds: 1), () {
      final score = (DateTime.now().millisecondsSinceEpoch % 101);
      String buttonText;
      if (score <= 30) {
        buttonText = "Omg! Unlucky!!!";
      } else if (score <= 50) {
        buttonText = "Not Bad";
      } else if (score <= 70) {
        buttonText = "Lucky!!!";
      } else if (score <= 94) {
        buttonText = "Very Lucky!!!";
      } else if (score <= 99) {
        buttonText = "Omg!!! Great Lucky!!";
      } else {
        buttonText = "...Perfect...";
      }
      if (mounted) {
        setState(() {
          _luckScore = score;
          _getLuckButtonText = buttonText;
          _showSaveButton = true;
          if (_luckScore! >= 95) {
            _confettiController.play();
          }
        });
      }
    });
  }

  Widget _buildLuckScoreContainer() {
    if (_luckScore == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.black),
            const SizedBox(width: 10),
            Text(
              "Luck Score: $_luckScore / 100",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: _selectedImage != null || _webImage != null ? Colors.white : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _selectedImage == null && _webImage == null
            ? const Center(child: Text("No photo uploaded"))
            : _webImage != null
                ? Image.memory(_webImage!, fit: BoxFit.cover)
                : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "LuckySnap",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 50,
                maxBlastForce: 40,
                minBlastForce: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*0.05),
                  _buildLuckScoreContainer(),
                  SizedBox(height: MediaQuery.of(context).size.height*0.05),
                  _buildImageContainer(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ElevatedButton(
                      onPressed: () => _showChoiceDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Select Image",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ElevatedButton(
                      onPressed: _getLuckScore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        _getLuckButtonText,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_showSaveButton)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        onPressed: _saveLuckScore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}