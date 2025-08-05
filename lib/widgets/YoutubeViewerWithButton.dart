import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeViewerWithButton extends StatefulWidget {
  final String youtubeUrl;

  const YoutubeViewerWithButton({required this.youtubeUrl});

  @override
  State<YoutubeViewerWithButton> createState() =>
      _YoutubeViewerWithButtonState();
}

class _YoutubeViewerWithButtonState extends State<YoutubeViewerWithButton> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
          ),
          builder: (context, player) {
            return WillPopScope(
              onWillPop: () async {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ]);
                return true;
              },
              child: player,
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
