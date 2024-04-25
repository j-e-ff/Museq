import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class QueueView extends StatelessWidget {
  final List<SongModel> queue;
  final AudioPlayer audioPlayer;

  const QueueView({Key? key, required this.queue, required this.audioPlayer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Queue'),
      ),
      body: ListView.builder(
        itemCount: queue.length,
        itemBuilder: (context, index) {
          final song = queue[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: AspectRatio(
                aspectRatio: 1.0, // Set aspect ratio to make it square
                child: QueryArtworkWidget(
                  id: song.id, // Use song ID for artwork query
                  type: ArtworkType.AUDIO,
                  artworkQuality: FilterQuality.high,
                  artworkWidth: 50,
                  artworkHeight: 50,
                ),
              ),
            ),
            title: Text(song.title),
            subtitle: Text(song.artist ?? 'Unknown Artist'),
            onTap: () => _playSelectedSong(context, index),
          );
        },
      ),
    );
  }

  void _playSelectedSong(BuildContext context, int songIndex) {
    Navigator.pop(context, songIndex); // Return the selected song index
  }
}