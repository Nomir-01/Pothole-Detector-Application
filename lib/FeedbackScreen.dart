// ignore_for_file: unused_label

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController =
      TextEditingController(text: 'potholedetector01@gmail.com');
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _includePotholeDocument = false;
  String? _selectedPotholeDocument;

  @override
  void dispose() {
    _recipientController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                controller:
                _subjectController.clear();
                controller:
                _bodyController.clear();
                _selectedPotholeDocument = null;
              });
            },
            icon: const CircleAvatar(
              backgroundColor: Color.fromRGBO(26, 26, 26, 1),
              child: Icon(
                Icons.refresh,
                color: Color.fromRGBO(230, 230, 230, 1),
              ),
            ),
          )
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const CircleAvatar(
            backgroundColor: Color.fromRGBO(26, 26, 26, 1),
            child: Icon(
              Icons.arrow_back,
              color: Color.fromRGBO(230, 230, 230, 1),
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
        foregroundColor: const Color.fromRGBO(230, 230, 230, 1),
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
        title: const Text("Feedback"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Email field (non-editable)
              // TextFormField(
              //   controller: _recipientController,
              //   style: TextStyle(fontSize: 22, color: Colors.white),
              //   decoration: InputDecoration(
              //     border: InputBorder.none,
              //     filled: true,
              //     fillColor: Color.fromRGBO(26, 26, 26, 1),
              //   ),
              //   enabled: false,
              //   validator: (value) {
              //     if (value!.isEmpty) {
              //       return 'Please enter a recipient email';
              //     }
              //     return null;
              //   },
              // ),
              CheckboxListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                title: const Text(
                  'Include Pothole',
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
                value: _includePotholeDocument,
                onChanged: (newValue) {
                  setState(() {
                    _includePotholeDocument = newValue!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                tileColor: const Color.fromRGBO(26, 26, 26, 1),
                activeColor: Colors.white,
                checkColor: Colors.black,
              ),
              if (_includePotholeDocument)
                FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection('Pothole Location')
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final documents = snapshot.data!.docs;
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedPotholeDocument,
                          items: documents.map((doc) {
                            final documentName = doc.id;
                            return DropdownMenuItem<String>(
                              value: documentName,
                              child: Text(documentName),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedPotholeDocument = newValue;
                            });
                          },
                          style: const TextStyle(
                              fontSize: 22, color: Colors.white),
                          dropdownColor: const Color.fromRGBO(26, 26, 26, 1),
                          decoration: InputDecoration(
                            hintText: 'Select Pothole',
                            hintStyle: const TextStyle(
                              color: Color.fromRGBO(191, 191, 191, 1),
                              fontWeight: FontWeight.w500,
                              fontSize: 22,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: const Color.fromRGBO(26, 26, 26, 1),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Text('Error loading pothole documents');
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              TextFormField(
                controller: _subjectController,
                style: const TextStyle(fontSize: 22, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Subject',
                  hintStyle: const TextStyle(
                    color: Color.fromRGBO(191, 191, 191, 1),
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: const Color.fromRGBO(26, 26, 26, 1),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              // Body field
              TextFormField(
                controller: _bodyController,
                style: const TextStyle(fontSize: 22, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Body',
                  hintStyle: const TextStyle(
                    color: Color.fromRGBO(191, 191, 191, 1),
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: const Color.fromRGBO(26, 26, 26, 1),
                ),
                maxLines: 10,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a body';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(
                      const Color.fromRGBO(230, 230, 230, 1)),
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromRGBO(26, 26, 26, 1)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var emailBody = _bodyController.text;
                    if (_includePotholeDocument &&
                        _selectedPotholeDocument != null) {
                      emailBody =
                          'Selected Pothole: $_selectedPotholeDocument\n\n$emailBody';
                    }
                    final Email email = Email(
                      body: emailBody,
                      subject: _subjectController.text,
                      recipients: [_recipientController.text],
                    );
                    await FlutterEmailSender.send(email);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mail Opened'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
