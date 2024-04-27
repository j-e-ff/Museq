import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:my_first_flutter_project/Components/my_drawer.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'Pages/albums_Page.dart';
import 'Pages/artist_Page.dart';
import 'Pages/playlist_Page.dart';
import 'Pages/favorites_Page.dart';
import 'Pages/songs_Page.dart';
import 'package:provider/provider.dart';
import 'Themes/theme_Provider.dart';
import 'Components/songProvider.dart';
import 'Components/MediaPlayer.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => SongProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const MyHomePage(title: 'MUSEQ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 2;

  late TextEditingController _searchController;
  late int _selectedSongIndex; // Track selected song index for the panel
  late List<Widget> _widgetOptions;
  bool _isSongSelected = false;
  List<SongModel> _selectedSongList = []; // Add this line
  final ValueNotifier<double> playerExpandProgress = ValueNotifier(70.0);
  static const double playerMinHeight = 70.0;


  @override
  void initState() {
    super.initState();
    _selectedSongIndex = 0;
    _searchController = TextEditingController();
    _widgetOptions = [
      FavoritesPage(
        onSongSelected: handleSongSelected,
      ),
      AlbumsPage(
        onSongSelected: handleSongSelected,
      ),
      SongsPage(
        onSongSelected: handleSongSelected,
      ),
      PlaylistPage(
        onSongSelected: handleSongSelected,
      ),
      ArtistPage(
        onSongSelected: handleSongSelected,
      ),
    ];
  }

  void handleSongSelected(List<SongModel> songList, int selectedSongIndex) {
    _selectedSongList = songList;
    _isSongSelected = true;
    _updateSelectedSongIndex(selectedSongIndex);
  }

  void _updateSelectedSongIndex(int index) {
    setState(() {
      _selectedSongIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _widgetOptions.elementAt(_selectedIndex),
          if (_isSongSelected)
            Miniplayer(
              minHeight: 70,
              maxHeight: 800,
              builder: (height, percentage) {
                return MediaPlayer(
                  songs: _selectedSongList,
                  initialSongIndex: _selectedSongIndex,
                  onSongChanged: (int newIndex) {
                    setState(() {
                      _selectedSongIndex = newIndex;
                    });
                  },
                  minHeight: 70, // Adjust as needed
                  maxHeight: 100, // Adjust as needed
                );
              },
              valueNotifier: playerExpandProgress, // Pass the value notifier
            ),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder<double>(
        valueListenable: playerExpandProgress,
        builder: (context, value, child) {
          return Visibility(
            visible: value == playerMinHeight,
            child: Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: GNav(
                  backgroundColor: Colors.black,
                  color: Colors.white,
                  activeColor: Colors.white,
                  tabBackgroundColor: Colors.grey.shade900,
                  padding: EdgeInsets.all(16),
                  gap: 7,
                  iconSize: 18,
                  tabs: const [
                    GButton(
                      icon: Icons.favorite,
                      text: 'Favorites',
                    ),
                    GButton(
                      icon: Icons.album,
                      text: 'Albums',
                    ),
                    GButton(
                      icon: Icons.music_note,
                      text: 'Songs',
                    ),
                    GButton(
                      icon: Icons.playlist_play,
                      text: 'Playlist',
                    ),
                    GButton(
                      icon: Icons.person,
                      text: 'Artist',
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SongSearchDelegate(
                  songs: Provider.of<SongProvider>(context, listen: false).songs,
                  onSongSelected: handleSongSelected,
                ),
              );
            },
          )
        ],
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      drawer: const MyDrawer(),
    );
  }
}


class SongSearchDelegate extends SearchDelegate<String> {
  final List<SongModel> songs;
  final Function(List<SongModel>, int) onSongSelected; // Callback function for song selection

  SongSearchDelegate({required this.songs, required this.onSongSelected});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<SongModel> filteredSongs = songs.where((song) =>
    song.title.toLowerCase().contains(query.toLowerCase()) ||
        (song.artist != null &&
            song.artist!.toLowerCase().contains(query.toLowerCase()))).toList();

    return ListView.builder(
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) {
        final SongModel song = filteredSongs[index];
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Adjust the border radius as needed
          ),
          title: Text(song.title),
          subtitle: Text(song.artist ?? 'Unknown Artist'),
          leading: Container(
            width: 56, // Adjust the width as needed
            height: 56, // Adjust the height as needed
            child: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              artworkFit: BoxFit.cover,
              artworkBorder: BorderRadius.circular(15),
            ),
          ),
          onTap: () {
            // Close the search results
          },
        );
      },
    );
  }


  @override
  Widget buildSuggestions(BuildContext context) {
    final List<SongModel> filteredSongs = songs.where((song) =>
    song.title.toLowerCase().contains(query.toLowerCase()) ||
        (song.artist != null &&
            song.artist!.toLowerCase().contains(query.toLowerCase()))).toList();

    return ListView.builder(
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) {
        final SongModel song = filteredSongs[index];
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Adjust the border radius as needed
          ),
          title: Text(song.title),
          subtitle: Text(song.artist ?? 'Unknown Artist'),
          leading: Container(
            width: 56, // Adjust the width as needed
            height: 56, // Adjust the height as needed
            child: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              artworkFit: BoxFit.cover,
              artworkBorder: BorderRadius.circular(15),
            ),
          ),
          onTap: () {
            // Call the callback function to handle song selection
            onSongSelected(filteredSongs, index);
            // Close the search results
            close(context, '');
          },
        );
      },
    );
  }
}
