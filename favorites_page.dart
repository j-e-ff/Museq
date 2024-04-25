import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
          'Favorites',
          style: TextStyle(fontSize: 50),
        )
    );
  }
}
