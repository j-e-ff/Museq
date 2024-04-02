import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../Components/songProvider.dart'; // Import your SongProvider

class FullSongListPage extends StatelessWidget {
  final String artist;
  final SongProvider songProvider;
  final void Function(List<SongModel>, int) onSongSelected; // Updated callback function

  FullSongListPage({required this.artist, required this.songProvider, required this.onSongSelected});

  @override
  Widget build(BuildContext context) {
    // Retrieve all songs by the selected artist
    final List<SongModel> songsByArtist = songProvider.getSongsByArtist(artist);

    return Scaffold(
      appBar: AppBar(
        title: Text('All Songs by $artist'),
      ),
      body: ListView.builder(
        itemCount: songsByArtist.length,
        itemBuilder: (context, index) {
          final song = songsByArtist[index];
          return ListTile(
            leading: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              artworkQuality: FilterQuality.high,
              artworkHeight: 50,
              artworkWidth: 50,
              nullArtworkWidget: Icon(Icons.music_note),
              artworkFit: BoxFit.cover,
            ),
            title: Text(song.title ?? ''),
            subtitle: Text(
              '${song.artist ?? ''}\t\t\t\t${_formatDuration(song.duration)}',
            ),
            onTap: () {
              onSongSelected(songsByArtist, index);// Play the selected song or navigate to song details page
            },
          );
        },
      ),
    );
  }
}

String _formatDuration(int? durationMilliseconds) {
  if (durationMilliseconds == null) {
    return '';
  }

  final int minutes = (durationMilliseconds / 60000).floor();
  final int seconds = ((durationMilliseconds % 60000) / 1000).floor();

  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
