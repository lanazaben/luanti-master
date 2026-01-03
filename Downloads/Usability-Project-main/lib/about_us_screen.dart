import 'package:flutter/material.dart';
import 'side_menu.dart';
import 'app_bar.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E2D2),
      drawer: const SideMenu(),
      appBar: const CustomAppBar(title: "About Us"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E2D2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About Us",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Safe Luanti is a smart, safety platform created to give parents peace of mind while their children enjoy the creativity and fun of the Luanti game world. We understand that online play can expose kids to unexpected risks, which is why Safe Luanti alerts parents the moment something concerning appears. From bullying and inappropriate language to grooming attempts or unsafe conversations.\n\nOur mission is simple: to build a safer digital playground. With real-time alerts, clear insights into your child’s interactions, We believe every child deserves a safe online experience, and every parent deserves the tools to make that possible.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            const Row(
              children: [
                Icon(Icons.email_outlined, size: 30),
                SizedBox(width: 10),
                Text(
                  "Email To Contact Us:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 40.0, top: 5),
              child: Text(
                "SafeLuanti@gmail.com",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
