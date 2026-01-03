import 'package:flutter/material.dart';
import 'children_information_screen.dart';
import 'about_us_screen.dart';
import 'link_child_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart';
import 'main.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  static String selectedItem = 'Home Page';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFF5F1E6),
        child: Column(
          children: [
            Container(
              height: 100,
              width: double.infinity,
              color: const Color(0xFF2E7D32),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20, top: 30),
              child: const Row(
                children: [
                  Icon(Icons.menu, color: Colors.white, size: 30),
                  SizedBox(width: 15),
                  Text(
                    "Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    Icons.home,
                    "Home Page",
                    onTap: () {
                      _navigate(context, "Home Page", const HomeScreen());
                    },
                  ),
                  _buildDrawerItem(
                    Icons.account_circle,
                    "Parent Profile",
                    onTap: () {
                      _navigate(context, "Parent Profile", const ProfilePage());
                    },
                  ),
                  _buildDrawerItem(
                    Icons.accessibility_new,
                    "Children Information",
                    onTap: () {
                      _navigate(
                        context,
                        "Children Information",
                        const ChildrenInformationScreen(),

                      );
                    },
                  ),
                  _buildDrawerItem(
                    Icons.group_add,
                    "Link Child",
                    onTap: () {
                      _navigate(context, "Link Child", const LinkChildScreen());

                    },
                  ),
                  _buildDrawerItem(
                    Icons.notifications,
                    "Notifications",
                    onTap: () {
                      _navigate(
                        context,
                        "Notifications",
                        const NotificationsScreen(),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    Icons.info,
                    "About Us",
                    onTap: () {
                      _navigate(context, "About Us", const AboutUsScreen());
                    },
                  ),
                  _buildDrawerItem(
                    Icons.exit_to_app,
                    "Log Out",
                    onTap: () {
                      _navigate(context, "Log Out", const LoginScreen());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String title, Widget screen) {
    setState(() {
      selectedItem = title;
    });
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Widget _buildDrawerItem(IconData icon, String title, {VoidCallback? onTap}) {
    bool isSelected = selectedItem == title;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD6E6D1) : Colors.transparent,
        border: const Border(
          bottom: BorderSide(color: Colors.black12, width: 0.5),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E7D32)),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
