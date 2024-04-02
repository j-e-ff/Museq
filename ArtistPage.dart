import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../Components/songProvider.dart';
import 'FullSongListPage.dart'; // Import your SongProvider

class ArtistPage extends StatelessWidget {
  final void Function(List<SongModel>, int) onSongSelected;

  ArtistPage({Key? key, required this.onSongSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artists'),
      ),
      body: FutureBuilder<List<String>>(
        future: _fetchArtists(context), // Fetch artists asynchronously
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<String> artists = snapshot.data ?? [];
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent: 225,
                crossAxisCount: 2,
                crossAxisSpacing: 0.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: artists.length,
              itemBuilder: (context, index) {
                final artist = artists[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArtistDetailPage(artist: artist,songProvider: Provider.of<SongProvider>(context), onSongSelected: onSongSelected,),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Consumer<SongProvider>(
                            builder: (context, songProvider, _) {
                              final int? songUri = songProvider.getFirstSongIdByArtist(artist);
                              return AspectRatio(
                                aspectRatio: 1.0,
                                child: songUri != null
                                    ? QueryArtworkWidget(
                                  artworkBorder: BorderRadius.circular(8.0),
                                  id: songUri,
                                  type: ArtworkType.AUDIO,
                                  artworkQuality: FilterQuality.high,
                                  artworkHeight: 193,
                                  artworkWidth: 193,
                                  size: 5000,
                                  nullArtworkWidget: Icon(Icons.music_note),
                                  artworkFit: BoxFit.fill,
                                )
                                    : Icon(Icons.music_note),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          artist,
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Define a function to fetch artists asynchronously
  Future<List<String>> _fetchArtists(BuildContext context) async {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    await songProvider.loadSongs(); // Load songs
    return songProvider.allArtists; // Return list of artists
  }
}

class ArtistDetailPage extends StatelessWidget {
  final String artist;
  final SongProvider songProvider;
  final void Function(List<SongModel>, int) onSongSelected; // Updated callback function

  ArtistDetailPage({required this.artist, required this.songProvider, required this.onSongSelected});

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    final List<SongModel> songsByArtist = songProvider.getSongsByArtist(artist);
    final int? songUri = songProvider.getFirstSongIdByArtist(artist);


    return Scaffold(
      appBar: AppBar(
        title: Text(artist),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (songUri != null)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: QueryArtworkWidget(
                id: songUri,
                type: ArtworkType.AUDIO,
                artworkQuality: FilterQuality.high,
                artworkHeight: 250,
                artworkWidth: 250,
                size: 5000,
                nullArtworkWidget: Icon(Icons.music_note),
                artworkFit: BoxFit.fill,
              ),
            ),
          SizedBox(height:30.0),
          Expanded(
            child: ListView.builder(
              itemCount: songsByArtist.length > 5 ? 6 : songsByArtist.length,
              itemBuilder: (context, index) {
                if (index == 5 && songsByArtist.length > 5) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullSongListPage(artist: artist, songProvider: songProvider, onSongSelected: onSongSelected,),
                          ),
                        );
                      },
                      child: Text(
                        'All Songs',
                        style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ),
                  );
                } else {
                  final song = songsByArtist[index];
                  return ListTile(
                    leading: QueryArtworkWidget(
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      artworkQuality: FilterQuality.high,
                      artworkHeight: 50,
                      artworkWidth: 50,
                      size: 9000,
                      nullArtworkWidget: Icon(Icons.music_note),
                      artworkFit: BoxFit.cover,
                    ),
                    title: Text(song.title ?? ''),
                    subtitle:Text(
                      '${song.artist ?? ''}\t\t\t\t${_formatDuration(song.duration)}',
                    ),
                    onTap: () {
                      // Play the selected song
                      onSongSelected(songsByArtist, index);
                    },
                  );
                }
              },
            ),
          ),
        ],
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
