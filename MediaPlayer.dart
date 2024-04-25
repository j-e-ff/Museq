import 'dart:typed_data';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_first_flutter_project/Components/playlistModel.dart';
import 'package:my_first_flutter_project/Components/songProvider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import 'QueueView.dart';

class AlbumArtWidget extends StatefulWidget {
  final int id;

  const AlbumArtWidget({Key? key, required this.id}) : super(key: key);

  @override
  _AlbumArtWidgetState createState() => _AlbumArtWidgetState();
}

class _AlbumArtWidgetState extends State<AlbumArtWidget> with AutomaticKeepAliveClientMixin {
  Uint8List? _artwork;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAlbumArt();
  }

  Future<void> _loadAlbumArt() async {
    try {
      final artwork = await OnAudioQuery().queryArtwork(
        widget.id as int,
        ArtworkType.AUDIO as ArtworkType,
        size: 1000,
      );
      if (mounted) {
        setState(() {
          _artwork = artwork;
        });
      }
    } catch (e) {
      print('Error loading album art: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure super.build is called first
    return _artwork != null
        ? Image.memory(
      _artwork!,
      width: 300,
      height: 300,
      fit: BoxFit.cover,
    )
        : Icon(Icons.music_note);
  }
}

class MediaPlayer extends StatefulWidget {
  final List<SongModel> songs;
  final int initialSongIndex;
  final void Function(int) onSongChanged; // Callback function for song change
  final double minHeight;
  final double maxHeight;

  const MediaPlayer({
    required this.songs,
    required this.initialSongIndex,
    required this.onSongChanged,
    required this.minHeight,
    required this.maxHeight,
    Key? key,
  }) : super(key: key);

  @override
  _MediaPlayerState createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  late AudioPlayer audioPlayer;
  late Duration duration;
  late Duration position;
  late bool isPlaying = true;
  late int currentSongIndex;
  bool isExpanded = false; // Add this variable to manage expansion state

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    duration = Duration.zero;
    position = Duration.zero;
    currentSongIndex = widget.initialSongIndex;

    _setupAudioPlayer();
    _loadNewSong(currentSongIndex); // Load the initial song and start playing

    audioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _playNextSong();
      }
    });
  }

  @override
  void didUpdateWidget(covariant MediaPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSongIndex != oldWidget.initialSongIndex || widget.songs != oldWidget.songs) {
      currentSongIndex = widget.initialSongIndex;
      _loadNewSong(currentSongIndex); // Load the new song when songIndex or songList changes
    }
  }

  Future<void> _setupAudioPlayer() async {
    try {
      await audioPlayer.setUrl(widget.songs[currentSongIndex].uri!);
    } catch (e) {
      print('Error setting up audio player: $e');
    }
  }

  Future<void> _loadNewSong(int songIndex) async {
    try {
      await audioPlayer.setUrl(widget.songs[songIndex].uri!);
      await audioPlayer.play(); // Start playing the loaded song
      setState(() {
        isPlaying = true;
        currentSongIndex = songIndex; // Update the current song index
      });
    } catch (e) {
      print('Error loading audio source: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: widget.minHeight, maxHeight: widget.maxHeight),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxHeight < widget.maxHeight) {
            return _buildMiniPlayer();
          } else {
            return _buildFullPlayer();
          }
        },
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Row(
      children: [
        Hero(
          tag: 'albumArt_${widget.songs[currentSongIndex].id}', // Unique tag for the artwork
          child: Container(
            key: ValueKey(widget.songs[currentSongIndex].id), // Add a key with a unique value
            width: isExpanded ? 200 : 60, // Adjust the width based on expansion
            height: 60, // Set the height to create a square
            child: AlbumArtWidget(id: widget.songs[currentSongIndex].id),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10), // Add padding to the top of the text
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.songs[currentSongIndex].title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2), // Add additional padding between the text
                  child: Text(
                    "Album: ${widget.songs[currentSongIndex].album ?? 'Unknown Album'}",
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause_outlined : Icons.play_arrow_rounded),
          onPressed: _togglePlayPause,
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: _playNextSong,
        ),
      ],
    );
  }

  Widget _buildFullPlayer() {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 90000),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.only(top: 50),
              alignment: Alignment.topCenter,
              child: Hero(
                tag: 'albumArt_${widget.songs[currentSongIndex].id}', // Use the same unique tag
                child: AlbumArtWidget(
                  key: ValueKey(widget.songs[currentSongIndex].id), // Add a key with a unique value
                  id: widget.songs[currentSongIndex].id,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 420),
                  Text(
                    widget.songs[currentSongIndex].title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Album: ${widget.songs[currentSongIndex].album ?? 'Unknown Album'}",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  _progressBar(), // Include the progress bar widget here
                  const SizedBox(height: 20), // Add some spacing below the progress bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Align buttons to the right
                    children: [
                      IconButton(
                        icon: Icon(Icons.favorite),
                        onPressed: () {
                          _addToFavorites(context); // Add this line to call the method to add to favorites
                        },
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        onPressed: _playPreviousSong,
                      ),
                      const SizedBox(width: 20),
                      CircleAvatar(
                        radius: 45,
                        child: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                            color: Colors.black,
                          ),
                          iconSize: 45,
                          onPressed: _togglePlayPause,
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: _playNextSong,
                      ),
                      const SizedBox(width: 20), // Increase spacing between next and queue button
                      // Add the queue button here
                      IconButton(
                        icon: Icon(Icons.queue_music),
                        onPressed: () {
                          _showQueueView(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToFavorites(BuildContext context) {
    final SongModel song = widget.songs[currentSongIndex];
    // Access the SongProvider instance using Provider.of
    final SongProvider songProvider = Provider.of<SongProvider>(context, listen: false);
    // Get the Favorites playlist
    final Playlist? favoritesPlaylist = songProvider.playlists.firstWhere(
          (playlist) => playlist.name.toLowerCase() == 'favorites',
    );
    // If Favorites playlist exists
    if (favoritesPlaylist != null) {
      // Check if the song already exists in the playlist
      if (favoritesPlaylist.songs.contains(song.id.toString())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Song already exists in Favorites playlist.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Add the song to the playlist
        songProvider.addSongToPlaylist(favoritesPlaylist.name, song.id.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Song added to Favorites playlist.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      print('Favorites playlist does not exist.'); // Handle the case when Favorites playlist is not found
    }
  }




  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  void _togglePlayPause() {
    if (isPlaying) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _playNextSong() {
    final nextIndex = (currentSongIndex + 1) % widget.songs.length;
    widget.onSongChanged(nextIndex); // Callback to parent widget
    _loadNewSong(nextIndex);
    setState(() {
      currentSongIndex = nextIndex;
    });
  }

  void _playPreviousSong() {
    final previousIndex = (currentSongIndex - 1 + widget.songs.length) % widget.songs.length;
    widget.onSongChanged(previousIndex); // Callback to parent widget
    _loadNewSong(previousIndex);
    setState(() {
      currentSongIndex = previousIndex;
    });
  }

  Widget _progressBar() {
    return StreamBuilder<Duration?>(
      stream: audioPlayer.positionStream,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, top: 20), // Add horizontal padding
          child: ProgressBar(
            progress: snapshot.data ?? Duration.zero,
            buffered: audioPlayer.bufferedPosition,
            total: audioPlayer.duration ?? Duration.zero,
            onSeek: (duration) {
              audioPlayer.seek(duration);
            },
            thumbColor: Colors.blue,
            progressBarColor: Colors.blue,
            baseBarColor: Colors.grey.shade800,
            bufferedBarColor: Colors.grey,
          ),
        );
      },
    );
  }

  void _showQueueView(BuildContext context) async {
    final selectedSongIndex = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QueueView(queue: widget.songs, audioPlayer: audioPlayer),
      ),
    );
    if (selectedSongIndex != null) {
      _loadNewSong(selectedSongIndex); // Load and play the selected song
    }
  }
}
