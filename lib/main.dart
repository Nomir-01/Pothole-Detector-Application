import 'package:flutter/material.dart';
import 'MapScreen2.dart';
import 'SearchScreen.dart';
import 'FeedbackScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(230, 230, 230, 1),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(230, 230, 230, 1),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
          foregroundColor: const Color.fromRGBO(230, 230, 230, 1),
          // titleTextStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
          title: const Text(""),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: const Color.fromRGBO(230, 230, 230, 1),
                  height: 200,
                  child: Center(
                    child: Image.asset('assets/splash.png'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(
                          const Color.fromRGBO(230, 230, 230, 1)),
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromRGBO(26, 26, 26, 1)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapScreen2(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Map',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(
                          const Color.fromRGBO(230, 230, 230, 1)),
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromRGBO(26, 26, 26, 1)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Where To',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              color: const Color.fromRGBO(230, 230, 230, 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Divider(
                          color: Color.fromRGBO(26, 26, 26, 1),
                          thickness: 1,
                        ),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all(
                                  const Color.fromRGBO(230, 230, 230, 1)),
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromRGBO(26, 26, 26, 1)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FeedbackScreen(),
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Feedback',
                                  style: TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
