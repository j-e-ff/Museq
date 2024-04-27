import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Components/playlistModel.dart'; // Import your Playlist model

class SongProvider extends ChangeNotifier {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  late List<SongModel> _songs = []; // List of all songs
  late List<String> _songUrls = []; // Store song URLs
  late Map<String, List<SongModel>> _albumsMap = {}; // Map to store songs grouped by album
  late Map<String, int> _albumSongCounts = {}; // Store the number of songs for each album
  late int _selectedSongIndex = 0; // Track the index of the selected song
  late List<Playlist> _playlists = []; // List to store playlists

  List<String> get songUrls => _songUrls; // Getter for song URLs

  Map<String, List<SongModel>> get albumsMap => _albumsMap; // Getter for albums map

  Map<String, int> get albumSongCounts => _albumSongCounts; // Getter for album song counts

  List<SongModel> get songs => _songs;

  int get selectedSongIndex => _selectedSongIndex; // Getter for selected song index

  List<String> get allArtists => _extractArtists(); // Getter for all artists

  List<SongModel> getSongsByArtist(String artist) {
    return _songs.where((song) => song.artist == artist).toList();
  }

  List<String> _extractArtists() {
    // Use a Set to ensure unique artist names
    Set<String> artists = Set<String>();
    for (var song in _songs) {
      if (song.artist != null && song.artist!.isNotEmpty) {
        artists.add(song.artist!);
      }
    }
    // Convert the Set to a List and sort alphabetically
    List<String> sortedArtists = artists.toList()..sort();
    return sortedArtists;
  }

  void setSongs(List<SongModel> songs) {
    _songs = songs;
    // Group songs by album name
    _albumsMap = {};
    for (var song in _songs) {
      // Check if the song is a notification
      if (!_isNotification(song)) {
        if (!_albumsMap.containsKey(song.album ?? '')) {
          _albumsMap[song.album ?? ''] = [];
        }
        _albumsMap[song.album ?? '']!.add(song);
      }
    }
    // Count the number of songs in each album
    _albumSongCounts = {};
    _albumsMap.forEach((album, songs) {
      // Exclude albums with a total time of 0
      int totalDuration = songs.fold(0, (previous, song) => previous + (song.duration ?? 0));
      if (totalDuration > 0) {
        _albumSongCounts[album] = songs.length;
      }
    });
    // Extract song URLs
    _songUrls = _songs.map((song) => song.uri!).toList();
    notifyListeners();
  }

  // Helper method to check if a song is a notification
  bool _isNotification(SongModel song) {
    // You can adjust the condition based on how notifications are identified in your data
    return song.title?.toLowerCase().contains('notification') ?? false;
  }

  Future<void> loadSongs() async {
    try {
      List<SongModel> songs = await _audioQuery.querySongs();
      // Filter out songs that are less than 5 seconds in duration
      songs = songs.where((song) => _isSongValid(song)).toList();
      setSongs(songs);
    } catch (error) {
      // Handle error loading songs
      print('Error loading songs: $error');
    }
  }

  // Helper method to check if a song is valid (more than 5 seconds duration)
  bool _isSongValid(SongModel song) {
    return (song.duration ?? 0) >= 5000; // 5000 milliseconds = 5 seconds
  }

  String getSongUrl(int index) {
    if (index >= 0 && index < _songUrls.length) {
      return _songUrls[index];
    } else {
      // Handle invalid index
      return ''; // Or throw an error
    }
  }

  void onSongSelected(int index) {
    if (index >= 0 && index < _songs.length) {
      _selectedSongIndex = index;
      notifyListeners();
    }
  }

  // Method to get the current album index based on the selected song index
  int getCurrentAlbumIndex() {
    if (_selectedSongIndex >= 0 && _selectedSongIndex < _songs.length) {
      String selectedSongAlbum = _songs[_selectedSongIndex].album ?? '';
      // Find the index of the album in the list of albums
      for (int i = 0; i < _albumsMap.keys.length; i++) {
        if (_albumsMap.keys.elementAt(i) == selectedSongAlbum) {
          return i;
        }
      }
    }
    // If the selected song or its album is not found, return -1 or handle it as needed
    return -1;
  }

  // Function to get the URI of the first song of the given artist
  int? getFirstSongIdByArtist(String artist) {
    final List<SongModel> songsByArtist = _songs.where((song) => song.artist == artist).toList();
    if (songsByArtist.isNotEmpty) {
      return songsByArtist[0].id; // Return ID of the first song by the artist
    }
    return null; // Return null if no songs found for the artist
  }

  // Method to add a new playlist
  void addPlaylist(Playlist playlist) {
    _playlists.add(playlist);
    _savePlaylists(); // Save playlists after adding a new one
    print('Playlist added: ${playlist.name}'); // Add a print statement to log the added playlist
  }

  // Method to add a song to a playlist
  void addSongToPlaylist(String playlistName, String songId) {
    Playlist? playlist = _playlists.firstWhere((playlist) => playlist.name == playlistName);
    if (playlist != null) {
      playlist.addSong(songId);
      _savePlaylists(); // Save playlists after adding a song
    }
  }

  // Method to save playlists to shared preferences
  Future<void> _savePlaylists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> playlistStrings = _playlists.map((playlist) => jsonEncode(playlist.toMap())).toList();
    await prefs.setStringList('playlists', playlistStrings);
  }

  // Method to load playlists from shared preferences
  Future<void> loadPlaylists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? playlistStrings = prefs.getStringList('playlists');
    if (playlistStrings != null) {
      _playlists = playlistStrings.map((playlistString) => Playlist.fromMap(jsonDecode(playlistString))).toList();
    }
  }

  // Getter for playlists
  List<Playlist> get playlists => _playlists;
  Playlist? getFavoritesPlaylist() {
    return _playlists.firstWhere((playlist) => playlist.name == 'Favorites');
  }

  // Method to set the list of playlists
  void setPlaylists(List<Playlist> playlists) {
    _playlists = playlists;
    notifyListeners();
  }

  void setSelectedSongIndex(int index) {
    _selectedSongIndex = index;
    notifyListeners();
  }

  bool isSongInPlaylist(String playlistName, String songId) {
    // Find the playlist with the given name
    Playlist? playlist = _playlists.firstWhere((playlist) => playlist.name == playlistName);
    // If the playlist exists, check if the song ID is present in the playlist
    if (playlist != null) {
      return playlist.songs.contains(songId);
    }
    // If playlist doesn't exist or song ID is not found, return false
    return false;
  }

}
