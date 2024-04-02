import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
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
                                fontSize: 12), // Adjust the font size as per your requirement
                          ),
                          SizedBox(width: 8),
                          // Add spacing between artist and length
                          Text(
                            _formatDuration(song.duration),
                            style: TextStyle(
                                fontSize: 12), // Adjust the font size as per your requirement
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.more_vert),
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
