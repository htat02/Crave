import 'package:flutter/material.dart';
import 'crave.dart';  // Ensure this import is correct if used for navigation

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  List<String> selectedDietaryRestrictions = [];
  TextEditingController firstNameController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();

  void _nextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThirdPage(title: '', firstName: firstNameController.text, zipCode: zipCodeController.text,),
      ),
    );
  }

  void _toggleDietaryRestriction(String restriction) {
    setState(() {
      if (selectedDietaryRestrictions.contains(restriction)) {
        selectedDietaryRestrictions.remove(restriction);
      } else {
        selectedDietaryRestrictions.add(restriction);
      }
    });
  }

  Widget _buildDietaryRestrictionOption(String restriction) {
    return GestureDetector(
      onTap: () => _toggleDietaryRestriction(restriction),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.only(right: 10.0),
        decoration: BoxDecoration(
          color: selectedDietaryRestrictions.contains(restriction) ? Colors.green[500] : Colors.white,
          border: Border.all(
            color: selectedDietaryRestrictions.contains(restriction) ? Colors.green[700]! : Colors.black,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Text(
          restriction,
          style: TextStyle(
            fontSize: 18.0,
            color: selectedDietaryRestrictions.contains(restriction) ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[400],
        title: const Text('Personal Info', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            const Text(
              'Personalized Info',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: TextStyle(color: Colors.green),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  hintText: 'Enter your First Name',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: zipCodeController,
                decoration: InputDecoration(
                  labelText: 'ZIP Code',
                  labelStyle: TextStyle(color: Colors.green),
                  border: OutlineInputBorder(),
                  hintText: 'Enter your ZIP Code',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const Divider(
              height: 30,
              thickness: 2,
              color: Colors.pink,
              indent: 10,
              endIndent: 10,
            ),
            const Text(
              'Dietary Restriction',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            Wrap(
              spacing: 10, // gap between adjacent chips
              runSpacing: 10, // gap between lines
              children: [
                _buildDietaryRestrictionOption('Vegan'),
                _buildDietaryRestrictionOption('Vegetarian'),
                _buildDietaryRestrictionOption('Halal'),
                _buildDietaryRestrictionOption('Keto'),
                _buildDietaryRestrictionOption('Gluten-free'),
                _buildDietaryRestrictionOption('Pescatarian'),
              ],
            ),
            const Divider(
              height: 40,
              thickness: 2,
              color: Colors.pink,
              indent: 10,
              endIndent: 10,
            ),
            const Text(
              'Allergies',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            Wrap(
              spacing: 10, // gap between adjacent chips
              runSpacing: 10, // gap between lines
              children: [
                _buildDietaryRestrictionOption('Nuts'),
                _buildDietaryRestrictionOption('Milk'),
                _buildDietaryRestrictionOption('Eggs'),
                _buildDietaryRestrictionOption('Soy'),
                _buildDietaryRestrictionOption('Shellfish'),
                _buildDietaryRestrictionOption('Wheat'),
                _buildDietaryRestrictionOption('Sesame'),
              ],
            ),
            Container(
              width: double.infinity,
              height: 50.0,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  primary: Colors.pink[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
