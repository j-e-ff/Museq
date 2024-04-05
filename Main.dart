import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:my_first_flutter_project/Components/my_drawer.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'Pages/albums_Page.dart';
import 'Pages/artist_Page.dart';
import 'Pages/playlist_Page.dart';
import 'Pages/favorites_Page.dart';
import 'Pages/home_Page.dart';
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
        child: const MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const MyHomePage(title: 'MUSEQ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late TextEditingController _searchController;
  late int _selectedSongIndex; // Track selected song index for the panel
  late List<Widget> _widgetOptions;
  bool _isSongSelected = false;
  List<SongModel> _selectedSongList = []; // Add this line

  @override
  void initState() {
    super.initState();
    _selectedSongIndex = 0;
    _searchController = TextEditingController();
    _widgetOptions = [
      HomePage(),
      FavoritesPage(),
      AlbumsPage(
        onSongSelected: handleSongSelected,
      ),
      SongsPage(
        onSongSelected: handleSongSelected,
      ),
      PlaylistPage(),
      ArtistPage(
        onSongSelected: handleSongSelected,
      ),
    ];
  }
  void handleSongSelected(List<SongModel> songList, int selectedSongIndex) {
    // Implement the functionality to handle the selected song index here
    // For example, you can update the panel with the selected song index.
    _selectedSongList = songList;
    _isSongSelected = true;
    _updateSelectedSongIndex(selectedSongIndex);
  }

  void _handleSongDeselected() {
    setState(() {
      _isSongSelected = false;
    });
    // You can add more logic here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _widgetOptions.elementAt(_selectedIndex),
          if (_isSongSelected) _buildSlidingUpPanel(),
        ],
      ),
      bottomNavigationBar: Container(
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
                icon: Icons.home,
                text: 'Home',
              ),
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
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SongSearchDelegate(songs: Provider.of<SongProvider>(context, listen: false).songs), // Implement SongSearchDelegate
              );
            },
          )
        ],
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      drawer: const MyDrawer(),

    );
  }


  void _updateSelectedSongIndex(int index) {
    setState(() {
      _selectedSongIndex = index;
    });
  }

  // Method to build the sliding up panel
  Widget _buildSlidingUpPanel() {
    return SlidingUpPanel(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0), // Set your desired top left border radius
        topRight: Radius.circular(10.0), // Set your desired top right border radius
      ),

      panel: MediaPlayer(
          songs: _selectedSongList,
        initialSongIndex: _selectedSongIndex, // Pass selected song index to MediaPlayer
        onSongChanged: (int newIndex) {
          setState(() {
            // Update any state related to the current song index
            // For example:
            //_selectedSongIndex = newIndex;
          });
        },
      ),
      isDraggable: true,
      minHeight: 50,
      maxHeight: 750,
    );
  }
}

class SongSearchDelegate extends SearchDelegate<String> {
  final List<SongModel> songs;
  //final audioPlayer = AudioPlayer();

  SongSearchDelegate({required this.songs});

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
    // Filter songs based on the search query

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
            height: 56, // Adjust the height as neede
            child: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              artworkFit: BoxFit.cover,
              artworkBorder: BorderRadius.circular(15),
            ),
          ),
          onTap: () {

          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Filter songs based on the search query
    final List<SongModel> filteredSongs = songs.where((song) =>
    song.title.toLowerCase().contains(query.toLowerCase()) ||
        (song.artist != null &&
            song.artist!.toLowerCase().contains(query.toLowerCase()))).toList();

    return ListView.builder(
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) {
        final SongModel song = filteredSongs[index];
        return Container(
          height: 80,
          child: ListTile(
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
              // Handle tapping on search suggestions
            },
          ),
        );
      },
    );
  }
}