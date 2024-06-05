// ignore_for_file: unused_label, use_build_context_synchronously, file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

import 'MapScreen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _sourcecontroller = TextEditingController();
  final _detinationcontroller = TextEditingController();
  DetailsResult? startPosition;
  DetailsResult? endPosition;
  late FocusNode sourceFocusNode;
  late FocusNode destinationFocusNode;
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    String apikey = 'AIzaSyDgrE3UACV0tCaKvcYV34cKfMrSY_ncNaU';
    googlePlace = GooglePlace(apikey);
    sourceFocusNode = FocusNode();
    destinationFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    sourceFocusNode.dispose();
    destinationFocusNode.dispose();
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
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
                _sourcecontroller.clear();
                controller:
                _detinationcontroller.clear();
                startPosition = null;
                endPosition = null;
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
        title: const Text("Search"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _sourcecontroller,
              focusNode: sourceFocusNode,
              style: const TextStyle(fontSize: 22, color: Colors.white),
              decoration: InputDecoration(
                  hintText: 'Start Point',
                  hintStyle: const TextStyle(
                      color: Color.fromRGBO(191, 191, 191, 1),
                      fontWeight: FontWeight.w500,
                      fontSize: 22),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: const Color.fromRGBO(26, 26, 26, 1),
                  suffixIcon: _sourcecontroller.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              predictions = [];
                              _sourcecontroller.clear();
                              startPosition = null;
                            });
                          },
                          icon: const Icon(
                            Icons.clear_outlined,
                            color: Colors.white,
                          ),
                        )
                      : null),
              autofocus: false,
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 1000), () {
                  if (value.isNotEmpty) {
                    autoCompleteSearch(value);
                  } else {
                    setState(() {
                      predictions = [];
                      startPosition = null;
                    });
                  }
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _detinationcontroller,
              focusNode: destinationFocusNode,
              enabled:
                  _sourcecontroller.text.isNotEmpty && startPosition != null,
              style: const TextStyle(fontSize: 22, color: Colors.white),
              decoration: InputDecoration(
                  hintText: 'Destination',
                  hintStyle: const TextStyle(
                      color: Color.fromRGBO(191, 191, 191, 1),
                      fontWeight: FontWeight.w500,
                      fontSize: 22),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: const Color.fromRGBO(26, 26, 26, 1),
                  suffixIcon: _detinationcontroller.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              predictions = [];
                              _detinationcontroller.clear();
                              endPosition = null;
                            });
                          },
                          icon: const Icon(
                            Icons.clear_outlined,
                            color: Colors.white,
                          ),
                        )
                      : null),
              autofocus: false,
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 1000), () {
                  if (value.isNotEmpty) {
                    autoCompleteSearch(value);
                  } else {
                    setState(() {
                      predictions = [];
                      endPosition = null;
                    });
                  }
                });
              },
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: predictions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
                      foregroundColor: Color.fromRGBO(230, 230, 230, 1),
                      child: Icon(Icons.pin_drop, color: Colors.white),
                    ),
                    title: Text(predictions[index].description.toString()),
                    onTap: () async {
                      final placeId = predictions[index].placeId!;
                      final details = await googlePlace.details.get(placeId);
                      if (details != null &&
                          details.result != null &&
                          mounted) {
                        if (sourceFocusNode.hasFocus) {
                          setState(() {
                            startPosition = details.result;
                            _sourcecontroller.text = details.result!.name!;
                            predictions = [];
                          });
                        } else {
                          setState(() {
                            endPosition = details.result;
                            _detinationcontroller.text = details.result!.name!;
                            predictions = [];
                          });
                        }
                        if (startPosition != null && endPosition != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapScreen(
                                      startPosition: startPosition,
                                      endPosition: endPosition)));
                        }
                      }
                    },
                  );
                })
          ],
        ),
      ),
    );
  }
}
