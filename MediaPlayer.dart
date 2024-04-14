import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AlbumArtWidget extends StatelessWidget {
  final int id;

  const AlbumArtWidget({required this.id});

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: id,
      type: ArtworkType.AUDIO,
      artworkQuality: FilterQuality.high,
      size: 6000,
      artworkHeight: 350,
      artworkWidth: 350,
      artworkFit: BoxFit.fill,
      nullArtworkWidget: Icon(Icons.music_note),
    );
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
        AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: isExpanded ? 200 : 60, // Adjust the width based on expansion
          height: 60, // Set the height to create a square
          child: AlbumArtWidget(id: widget.songs[currentSongIndex].id),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 10), // Add padding to the top of the text
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.songs[currentSongIndex].title ?? 'Unknown Title',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2), // Add additional padding between the text
                  child: Text(
                    "Album: ${widget.songs[currentSongIndex].album ?? 'Unknown Album'}",
                    style: TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: _togglePlayPause,
        ),
        IconButton(
          icon: Icon(Icons.skip_next),
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
              duration: Duration(milliseconds: 90000),
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(top: 50),
              alignment: Alignment.topCenter,
              child: AlbumArtWidget(id: widget.songs[currentSongIndex].id),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 400),
                  Text(
                    widget.songs[currentSongIndex].title ?? 'Unknown Title',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Album: ${widget.songs[currentSongIndex].album ?? 'Unknown Album'}",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatTime(position)),
                        Text(formatTime(duration)),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.skip_previous),
                        onPressed: _playPreviousSong,
                      ),
                      SizedBox(width: 20),
                      CircleAvatar(
                        radius: 45,
                        child: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_circle,
                          ),
                          iconSize: 50,
                          color: Colors.black,
                          onPressed: _togglePlayPause,
                        ),
                      ),
                      SizedBox(width: 20),
                      IconButton(
                        icon: Icon(Icons.skip_next),
                        onPressed: _playNextSong,
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
}
