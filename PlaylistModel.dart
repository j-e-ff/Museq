import 'package:on_audio_query/on_audio_query.dart';

class Playlist {
  final String name;
  List<String> songs;

  Playlist({required this.name, required this.songs});

  // Method to add a song to the playlist
  void addSong(String songId) {
    songs.add(songId);
  }

  // Convert the playlist object to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'songs': songs,
    };
  }

  // Factory method to create a playlist object from a map
  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      name: map['name'],
      songs: List<String>.from(map['songs']),
    );
  }
}
