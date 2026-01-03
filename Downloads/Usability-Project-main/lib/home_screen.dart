import 'package:flutter/material.dart';
import 'side_menu.dart';
import 'children_information_screen.dart';
import 'link_child_screen.dart';
import 'notifications_screen.dart';
import 'about_us_screen.dart';
import 'profile_screen.dart';
import 'app_bar.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E2D2),
      drawer: const SideMenu(),
      appBar: const CustomAppBar(title: "Home"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [

            _buildHomeButton(
              context,
              Icons.person,
              "Parent Profile",
              const ProfilePage(),
            ),
            _buildHomeButton(
              context,
              Icons.accessibility_new,
              "Children Information",
              const ChildrenInformationScreen(),
            ),
            _buildHomeButton(
              context,
              Icons.group_add,
              "Link Child",
              const LinkChildScreen(),
            ),
            _buildHomeButton(
              context,
              Icons.notifications_active,
              "Notifications",
              const NotificationsScreen(),
            ),
            _buildHomeButton(context, Icons.exit_to_app, "Log Out", null),
            _buildHomeButton(
              context,
              Icons.info,
              "About Us",
              const AboutUsScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeButton(
    BuildContext context,
    IconData icon,
    String label,
    Widget? destination,
  ) {

    return InkWell(
      onTap: () {
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        } else if (label == "Log Out") {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD6E6D1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF2E7D32), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}