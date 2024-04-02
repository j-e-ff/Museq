import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../Components/songProvider.dart';
import 'package:marquee/marquee.dart';

class AlbumsPage extends StatelessWidget {
  final void Function(List<SongModel>, int) onSongSelected;

  AlbumsPage({Key? key, required this.onSongSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Provider.of<SongProvider>(context, listen: false).loadSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading albums'));
          } else {
            final albumsMap = Provider.of<SongProvider>(context).albumsMap;

            // Filter out albums with a total time of 0
            final filteredAlbumsMap = albumsMap.entries.where((entry) {
              final songList = entry.value;
              int totalDuration =
              songList.fold(0, (previous, song) => previous + (song.duration ?? 0));
              return totalDuration > 0;
            }).toList();

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: GridView.custom(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: 225,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 20.0,
                ),
                childrenDelegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final albumEntry = filteredAlbumsMap[index];
                    final albumName = albumEntry.key; // Add null check here
                    final songList = albumEntry.value ?? []; // Use null-aware operator and provide a default value if null

                    if (albumName == null) {
                      // Handle the case where albumName is null
                      return SizedBox(); // or any other appropriate widget
                    }

                    // Extracting artist names from song list
                    final artistNames =
                    songList.map((song) => song.artist ?? 'Unknown Artist').toSet().join(', ');

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlbumDetailPage(
                              albumName: albumName,
                              songList: songList,
                              onSongSelected: onSongSelected,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 1.0,
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: QueryArtworkWidget(
                                  id: songList.isNotEmpty ? songList[0].id : 0,
                                  type: ArtworkType.AUDIO,
                                  artworkBorder: BorderRadius.circular(8.0),
                                  artworkQuality: FilterQuality.high,
                                  quality: 100,
                                  size: 5000,
                                  nullArtworkWidget: Container(
                                    color: Theme.of(context).colorScheme.background,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8.0), // Adjust the value as needed
                                child: Container(
                                  width: 150, // Set your desired width
                                  child: Text(
                                    albumName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8.0), // Adjust the value as needed
                                child: Container(
                                  height: 20,
                                  width: 150, // Set your desired width
                                  child: Text(
                                    artistNames,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: filteredAlbumsMap.length,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class AlbumDetailPage extends StatelessWidget {
  final String albumName;
  final List<SongModel> songList;
  final void Function(List<SongModel>, int) onSongSelected; // Updated callback function

  const AlbumDetailPage({
    required this.albumName,
    required this.songList,
    required this.onSongSelected, // Receive the callback function
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(albumName),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Display the artwork
          Container(
            padding: EdgeInsets.only(
              top: 20,
              left: 50,
              right: 50,
              bottom: 0,
            ),
            child: QueryArtworkWidget(
              artworkBorder: BorderRadius.circular(8.0),
              artworkQuality: FilterQuality.high,
              id: songList.isNotEmpty ? (songList[0].id) : 0,
              type: ArtworkType.AUDIO,
              artworkHeight: 300,
              artworkWidth: 300,
              size: 5000,
              nullArtworkWidget: Container(
                color: Theme.of(context).colorScheme.background,
              ),
            ),
          ),
          // Display the album name
          Padding(
            padding: const EdgeInsets.only(top: 10.0), // Add space between the artwork and the album name
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Use Marquee widget for automatic looping scrolling of the album name
                Container(
                  width: 200,
                  height: 28, // Set a fixed width for the container
                  child: Marquee(
                    text: '$albumName   ', // Add extra spaces after the album name
                    style: TextStyle(
                      fontSize: 20, // Adjust the font size as needed
                      fontWeight: FontWeight.bold, // Make the album name bold
                    ),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    velocity: 50.0,
                    pauseAfterRound: Duration(seconds: 2),
                    accelerationDuration: Duration(seconds: 1),
                    accelerationCurve: Curves.linear,
                    decelerationDuration: Duration(milliseconds: 500),
                    decelerationCurve: Curves.easeOut,
                  ),
                ),
                SizedBox(height: 4), // Add spacing between the album name and song count

                // Display the number of songs
                Text(
                  'Number of Songs: ${songList.length}',
                  style: TextStyle(
                    fontSize: 14, // Adjust the font size as needed
                  ),
                ),

                // Calculate and display the total duration of the album
                Text(
                  'Total Length: ${_calculateTotalDuration(songList)}',
                  style: TextStyle(
                    fontSize: 14, // Adjust the font size as needed
                  ),
                ),
              ],
            ),
          ),
          // Display the list of songs with padding on the left side
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 100.0), // Add padding at the bottom of the list
              child: ListView.builder(
                itemCount: songList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0), // Increased vertical spacing
                    child: GestureDetector(
                      onTap: () {
                        onSongSelected(songList, index); // Pass index and song list to the callback function
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Center the song number vertically
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                '${index + 1}.',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 0), // Add more spacing between the number and the title
                          // Display the song title and artist name with horizontal scrolling
                          Expanded(
                            flex: 3,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    songList[index].title ?? 'Unknown Title',
                                    style: TextStyle(
                                      fontSize: 16,
                                      // Make the song name regular
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  SizedBox(height: 4), // Add spacing between the title and artist name
                                  // Display the artist name
                                  Text(
                                    '${songList[index].artist ?? 'Unknown Artist'} \t\t\t\t ${_formatDuration(songList[index].duration)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Three-dot icons column
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              icon: Icon(Icons.more_vert),
                              alignment: Alignment.center,
                              onPressed: () {
                                // Add your action here when the three-dot icon is tapped
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Sliding up panel
        ],
      ),
    );
  }

  // Helper method to calculate the total duration of the album in minutes
  String _calculateTotalDuration(List<SongModel> songs) {
    // Calculate the total duration of the album in milliseconds
    int totalDuration = songs.fold(0, (previous, song) => previous + (song.duration ?? 0));

    // Calculate the total duration in minutes and seconds
    int totalMinutes = (totalDuration / 60000).floor();
    int totalSeconds = ((totalDuration % 60000) / 1000).floor();

    // Format the total duration as "mm:ss"
    String formattedDuration =
        '${totalMinutes.toString().padLeft(2, '0')}:${totalSeconds.toString().padLeft(2, '0')}';

    return formattedDuration;
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
