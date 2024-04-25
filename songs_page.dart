import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../Components/playlistModel.dart';
import '../Components/songProvider.dart'; // Import your SongProvider class
import 'package:on_audio_query/on_audio_query.dart';

class SongsPage extends StatefulWidget {
  final void Function(List<SongModel>, int) onSongSelected; // Updated callback function

  SongsPage({required this.onSongSelected});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  late SongProvider _songProvider;

  @override
  void initState() {
    super.initState();
    _songProvider = Provider.of<SongProvider>(context, listen: false);
    _requestPermissionAndLoadSongs();
    _loadPlaylists();// Load playlists when the page is initialized
  }

  Future<void> _requestPermissionAndLoadSongs() async {
    PermissionStatus status = await Permission.audio.request();
    if (status.isGranted) {
      _songProvider.loadSongs();
    } else {
      // Handle denied or permanently denied status
      // You can show a message to the user explaining why the permission is necessary.
    }
  }

  Future<void> _loadPlaylists() async {
    await _songProvider.loadPlaylists(); // Wait for playlists to be loaded
    setState(() {}); // Update the UI after loading playlists
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SongProvider>(
        builder: (context, songProvider, _) {
          if (songProvider.songs.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Scrollbar(
              trackVisibility: true, // Ensures scrollbar is always visible
              child: ListView.builder(
                itemCount: songProvider.songs.length,
                itemBuilder: (context, index) {
                  final song = songProvider.songs[index];
                  return GestureDetector(
                    onTap: () {
                      // Fetch the list of songs from the SongProvider
                      List<SongModel> songs = Provider.of<SongProvider>(context, listen: false).songs;
                      // Call the callback function with the list of songs and the index of the selected song
                      widget.onSongSelected(songs, index);
                    },
                    child: ListTile(
                      title: Text(song.title),
                      subtitle: Row(
                        children: [
                          Text(
                            song.artist ?? 'Unknown Artist',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            _formatDuration(song.duration),
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'addToPlaylist',
                            child: Text('Add to Playlist'),
                          ),
                        ],
                        onSelected: (String value) {
                          if (value == 'addToPlaylist') {
                            _showAddToPlaylistDialog(context, song); // Show dialog to select playlist
                          }
                        },
                      ),
                      leading: QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        artworkBorder: BorderRadius.circular(15),
                        quality: 100,
                        size: 1000,
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

// Method to build popup menu items
  List<PopupMenuEntry<String>> _buildPopupMenuItems(SongModel song) {
    return _songProvider.playlists.map((playlist) {
      return PopupMenuItem<String>(
        value: playlist.name, // Use playlist name as the value
        child: Text(playlist.name), // Display playlist name as the menu item
      );
    }).toList();
  }

// Method to handle adding the selected song to the selected playlist
  void _addToPlaylist(String playlistName, SongModel song) {
    _songProvider.addSongToPlaylist(playlistName, song.id.toString());
    // You can add any additional logic here, such as showing a confirmation message
  }
  void _showAddToPlaylistDialog(BuildContext context, SongModel song) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add to Playlist'),
          content: Consumer<SongProvider>(
            builder: (context, songProvider, _) {
              // Access playlists directly from the songProvider
              List<Playlist> playlists = songProvider.playlists;
              print('Number of playlists: ${playlists.length}'); // Print the item count to the console
              return SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    Playlist playlist = playlists[index];
                    return ListTile(
                      title: Text(playlist.name),
                      onTap: () {
                        Navigator.pop(context, playlist); // Return selected playlist
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    ).then((selectedPlaylist) {
      if (selectedPlaylist != null) {
        print('Length of ${selectedPlaylist.name} before adding song: ${selectedPlaylist.songs.length}');
        _addToPlaylist(selectedPlaylist.name, song); // Call _addToPlaylist method
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Song added to ${selectedPlaylist.name}'),
          ),
        );
        print('Length of ${selectedPlaylist.name} after adding song: ${selectedPlaylist.songs.length}');
      }
    });
  }


  // Function to format the duration into a readable format (e.g., minutes and seconds)
  String _formatDuration(int? durationInMillis) {
    if (durationInMillis != null) {
      Duration duration = Duration(milliseconds: durationInMillis);
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "00:00"; // or any other default value you prefer
    }
  }
}
