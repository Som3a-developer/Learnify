import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class FullScreenYoutubePlayer extends StatefulWidget {
  final String url;
  const FullScreenYoutubePlayer({Key? key, required this.url})
      : super(key: key);

  @override
  State<FullScreenYoutubePlayer> createState() =>
      _FullScreenYoutubePlayerState();
}

class _FullScreenYoutubePlayerState extends State<FullScreenYoutubePlayer> {
  late YoutubePlayerController _ytController;

  @override
  void initState() {
    super.initState();

    // استخراج videoId من الرابط
    final videoId = YoutubePlayer.convertUrlToId(widget.url) ?? '';

    _ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        controlsVisibleAtStart: true,
        forceHD: true,
      ),
    );
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: YoutubePlayer(
            controller: _ytController,
            showVideoProgressIndicator: true,
          ),
        ),
      ),
    );
  }
}
