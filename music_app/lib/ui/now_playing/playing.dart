import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/model/song.dart';
import 'audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.songs, required this.playingSong});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(songs: songs, playingSong: playingSong);
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(
      {super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimationController;
  late AudioPlayerManager _audioPlayerManager;

  @override
  void initState() {
    super.initState();
    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _audioPlayerManager =
        AudioPlayerManager(songUrl: widget.playingSong.source);
    _audioPlayerManager.init();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Now Playing"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {},
          child: const Icon(CupertinoIcons.ellipsis),
        ),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.playingSong.album),
              const SizedBox(height: 10),
              const Text("_ ___ _"),
              const SizedBox(height: 20),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0)
                    .animate(_imageAnimationController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: "assets/itunes_icon.png",
                    image: widget.playingSong.image,
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/itunes_icon.png",
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 64, bottom: 16),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Column(
                        children: [
                          Text(
                            widget.playingSong.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.playingSong.artist,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_outline),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 32,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                child: _progressBar(),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 0,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                child: _mediaButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const MediaButtonControl(
              function: null,
              icon: Icons.shuffle,
              color: Colors.deepPurple,
              size: 24),
          const MediaButtonControl(
              function: null,
              icon: Icons.skip_previous,
              color: Colors.deepPurple,
              size: 36),
          _playButton(),
          const MediaButtonControl(
              function: null,
              icon: Icons.skip_next,
              color: Colors.deepPurple,
              size: 36),
          const MediaButtonControl(
              function: null,
              icon: Icons.repeat,
              color: Colors.deepPurple,
              size: 24),
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;

          return ProgressBar(
            progress: progress,
            total: total,
          );
        });
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
        stream: _audioPlayerManager.player.playerStateStream,
        builder: (context, snapshot) {
          final playState = snapshot.data;
          final processingState = playState?.processingState;
          final playing = playState?.playing;
          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            return Container(
              margin: const EdgeInsets.all(8),
              width: 48,
              height: 48,
              child: const CircularProgressIndicator(),
            );
          } else if (playing != true) {
            return MediaButtonControl(
                function: () {
                  _audioPlayerManager.player.play();
                },
                icon: Icons.play_arrow,
                color: null,
                size: 48);
          } else if (processingState != ProcessingState.completed) {
            return MediaButtonControl(
                function: () {
                  _audioPlayerManager.player.pause();
                },
                icon: Icons.pause,
                color: null,
                size: 48);
          } else {
            return MediaButtonControl(
                function: () {
                  _audioPlayerManager.player.seek(Duration.zero);
                },
                icon: Icons.replay,
                color: null,
                size: 48);
          }
        });
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
