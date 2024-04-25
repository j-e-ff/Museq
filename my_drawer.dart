import 'package:flutter/material.dart';
import '../Pages/settings_Page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          // Custom DrawerHeader with logo and title
          const DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_note, size: 40), // Your logo
                      SizedBox(width: 10), // Spacer between logo and title
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Settings",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Home tile
          Padding(
            padding: EdgeInsets.only(left: 25.0, top: 25),
            child: ListTile(
              title: Text(" Home"),
              leading: Icon(Icons.home),
              onTap: () => Navigator.pop(context),
            ),
          ),
          // Other drawer items...
          Padding(
            padding: EdgeInsets.only(left: 25.0, top: 25),
            child: ListTile(
              title: Text(" Equalizer"),
              leading: Icon(Icons.equalizer),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 25),
            child: ListTile(
              title: Text(" Theme"),
              leading: Icon(Icons.mode),
              onTap: () {
                //pop drawer
                Navigator.pop(context);

                //got to theme page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
