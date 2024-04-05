import 'package:flutter/material.dart';
import '../Components/playlistModel.dart';
import '../Components/songProvider.dart';
import 'PlayListDetailPage.dart';

class PlaylistPage extends StatefulWidget {
  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  late SongProvider _songProvider;

  @override
  void initState() {
    super.initState();
    _songProvider = SongProvider(); // Initialize SongProvider
    _loadPlaylists(); // Load playlists when the page is initialized
  }

  Future<void> _loadPlaylists() async {
    await _songProvider.loadPlaylists(); // Load playlists from SharedPreferences
    setState(() {}); // Update the UI after loading playlists
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlists'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showCreatePlaylistDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: _buildPlaylistList(), // Render the playlist list
      ),
    );
  }

  Widget _buildPlaylistList() {
    final playlists = _songProvider.playlists;
    if (playlists.isEmpty) {
      return Text(
        'No playlists available',
        style: TextStyle(fontSize: 20),
      );
    } else {
      return ListView.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return ListTile(
            title: Text(playlist.name),
            onTap: () {
              _navigateToPlaylistDetail(context, playlist); // Navigate to playlist detail page
            },
          );
        },
      );
    }
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    String playlistName = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Playlist'),
          content: TextField(
            onChanged: (value) {
              playlistName = value;
            },
            decoration: InputDecoration(hintText: 'Enter playlist name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Create', style: TextStyle(color: Colors.black)),
              onPressed: () {
                if (playlistName.isNotEmpty) {
                  _songProvider.addPlaylist(Playlist(name: playlistName, songs: []));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToPlaylistDetail(BuildContext context, Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailPage(playlist: playlist),
      ),
    );
  }
}
