import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/home/viewmodel.dart';

import '../discovery/discovery.dart';
import '../settings/settings.dart';
import '../user/user.dart';
import '../../data/model/song.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Music App",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MusicHomePage(),
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Music App"),
        ),
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.album), label: "Discovery"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: "Account"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: "Settings"),
            ],
          ),
          tabBuilder: (BuildContext context, int index) {
            return _tabs[index];
          },
        ));
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget{
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}




class _HomeTabPageState extends State<HomeTabPage> {

  List<Song> songs = [];
  late MusicAppViewModel _viewModel;

  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    observeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    super.dispose();
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position);
      },
      itemCount: songs.length,
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      shrinkWrap: true,
    );
  }

  Widget getRow(int index) {
    return _SongItemSection(parent: this, song: songs[index]);
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }
}
  class _SongItemSection extends StatelessWidget {
    const _SongItemSection({
      required this.parent,
      required this.song,
    });

    final _HomeTabPageState parent;
    final Song song;

    @override
    Widget build(BuildContext context) {
      return ListTile(
        contentPadding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 8,
          bottom: 8,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: FadeInImage.assetNetwork(
            placeholder: "assets/itunes_icon.png",
            image: song.image,
            width: 48,
            height: 48,
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset(
                "assets/itunes_icon.png",
                width: 48,
                height: 48,
              );
            },
          ),
        ),
        title: Text(song.title),
        subtitle: Text(song.artist),
        trailing: IconButton(
          icon: Icon(Icons.more_horiz),
          onPressed: () {},
        ),
      );
    }
  }