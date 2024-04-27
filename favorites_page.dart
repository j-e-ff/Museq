import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../Components/playlistModel.dart';
import '../Components/songProvider.dart'; // Import your SongProvider class

class FavoritesPage extends StatelessWidget {
  final void Function(List<SongModel>, int) onSongSelected;

  const FavoritesPage({
    Key? key,
    required this.onSongSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: Consumer<SongProvider>(
        builder: (context, songProvider, _) {
          Playlist? favoritesPlaylist = songProvider.getFavoritesPlaylist();
          if (favoritesPlaylist != null) {
            List<String> favoriteSongIds = favoritesPlaylist.songs;
            List<SongModel> favoriteSongs = songProvider.songs.where((song) => favoriteSongIds.contains(song.id.toString())).toList();
            return ListView.builder(
              itemCount: favoriteSongs.length + 1, // Add 1 for the padding
              itemBuilder: (context, index) {
                if (index == favoriteSongs.length) {
                  // Return a container with padding as the last item
                  return SizedBox(height: 70.0); // Adjust the height as needed
                } else {
                  final song = favoriteSongs[index];
                  return ListTile(
                    leading: QueryArtworkWidget(
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      artworkBorder: BorderRadius.circular(10.0),
                      artworkQuality: FilterQuality.high,
                      artworkWidth: 50,
                      artworkHeight: 50,
                    ),
                    title: Text(song.title),
                    subtitle: Text(song.artist ?? 'Unknown Artist'),
                    onTap: () {
                      // Call the callback function with the selected song
                      onSongSelected(favoriteSongs, index);
                    },
                  );
                }
              },
            );
          } else {
            return Center(
              child: Text('Favorites playlist not found'),
            );
          }
        },
      ),
    );
  }
}
