import 'package:flutter/material.dart';
import 'side_menu.dart';
import 'app_bar.dart';

class ChildrenInformationScreen extends StatelessWidget {
  const ChildrenInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E2D2),
      drawer: const SideMenu(),
      appBar: const CustomAppBar(title: "Children Information"),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            _buildChildCard("Leen Sabri", "leensabri@123", "12"),
            _buildChildCard("Rawan Yahya", "rawanyahya123", "10"),
            _buildChildCard("Lana Zaben", "lanazaben321", "9"),
            _buildChildCard("Diaa Nawawreh", "diaanawawreh444", "13"),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard(String name, String username, String age) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E6D1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Child Name: $name",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Child username: $username",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Child Age: $age",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
