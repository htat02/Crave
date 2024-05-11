import 'package:flutter/material.dart';
import 'personal_info.dart'; // Ensure this import is correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Get Started',
      theme: ThemeData(
        primaryColor: Colors.pink,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.pink,
          secondary: Colors.pinkAccent,
          background: Colors.grey[200],
        ),
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          button: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Get Started'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.green[300]!, Colors.pink[200]!], // Green to pink gradient
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 300, // Larger image
                height: 300, // Larger image
                child: Image.asset(
                  'assets/croc_nobg.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 40), // Larger spacing
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pink[400], // Darker pink for better contrast
                  onPrimary: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: Theme.of(context).textTheme.button,
                  elevation: 10,
                ),
                onPressed: () => navigateToNextPage(context),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void navigateToNextPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SecondPage(title: 'Welcome')), // Updated title for context
  );
}
