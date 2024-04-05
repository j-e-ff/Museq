import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../Components/playlistModel.dart';
import '../Components/songProvider.dart'; // Import your SongProvider class
import 'package:provider/provider.dart'; // Import Provider package

class PlaylistDetailPage extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailPage({required this.playlist});

  @override
  Widget build(BuildContext context) {
    // Access the SongProvider instance using Provider.of within the build method
    final songProvider = Provider.of<SongProvider>(context);

    // Access the list of all songs from the SongProvider
    List<SongModel> allSongs = songProvider.songs;

    // Filter songs in the playlist using their IDs
    List<SongModel> playlistSongs = [];

    for (var songUri in playlist.songs) {
      for (var song in allSongs) {
        final songUriSuffix = song.uri?.substring(song.uri!.length - 10); // Extract the last 10 characters from the URI
        if (songUriSuffix == songUri) { // Compare the extracted suffix with the playlist song URI
          playlistSongs.add(song);
          break; // Break out of the inner loop once the song is found
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
      ),
      body: ListView.builder(
        itemCount: playlistSongs.length,
        itemBuilder: (context, index) {
          final song = playlistSongs[index];
          return ListTile(
            leading: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              artworkBorder: BorderRadius.circular(15),
              quality: 100,
              size: 5000, // Adjust the size as needed
            ),
            title: Text(song.title),
            subtitle: Text(song.artist ?? 'Unknown Artist'),
          );
        },
      ),
    );
  }
}
