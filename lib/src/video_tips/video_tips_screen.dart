import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';
import 'package:vtb_hack_mobile/src/common_widgets/full_width_button.dart';
import 'package:vtb_hack_mobile/src/settings/size_config.dart';
import 'package:vtb_hack_mobile/src/video_tips/widgets/video_controllers.dart';

class VideoTipsScreen extends StatefulWidget {
  const VideoTipsScreen(
      {Key? key,
      required this.infoTitle,
      required this.infoText,
      required this.text,
      required this.videoUrl,
      required this.buttonText,
      required this.onButtonClick,
      required this.onSkipClick})
      : super(key: key);

  final String infoTitle;
  final String infoText;
  final String text;
  final String videoUrl;
  final String buttonText;
  final Function onButtonClick;
  final Function onSkipClick;

  @override
  _VideoTipsScreenState createState() => _VideoTipsScreenState();
}

class _VideoTipsScreenState extends State<VideoTipsScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.network(widget.videoUrl);

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(false);
    _controller.play();
    _controller.addListener(() {
      setState(() {
        if (!_controller.value.isPlaying &&
            _controller.value.isInitialized &&
            (_controller.value.duration == _controller.value.position)) {
          //Video Completed//
          setState(() {});
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the VideoPlayerController has finished initialization, use
                // the data it provides to limit the aspect ratio of the video.
                return SizedBox(
                  child: VideoPlayer(_controller),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 300,
                );
              } else {
                // If the VideoPlayerController is still initializing, show a
                // loading spinner.
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(MySize.size12!),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/vtb.svg',
                  ),
                  SizedBox(width: MySize.size12),
                  TextButton(
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft),
                    onPressed: () {
                      widget.onSkipClick();
                    },
                    child: const Text(
                      "Пропустить",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 418,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x267e7e7e),
                    blurRadius: 250,
                    offset: Offset(0, 4),
                  ),
                ],
                color: Color(0xff225ad6),
              ),
              child: Padding(
                padding: EdgeInsets.all(MySize.size30!),
                child: Column(
                  children: [
                    SizedBox(
                      height: MySize.size20,
                    ),
                    Text(
                      widget.infoTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontFamily: "Rubik",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: MySize.size10,
                    ),
                    Text(
                      widget.infoText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: MySize.size20),
                    VideoControllers(
                      onPlayClick: () {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      },
                      isPlaying: _controller.value.isPlaying,
                    ),
                    SizedBox(height: MySize.size20),
                    const Spacer(),
                    FullWidthButton(
                        text: widget.buttonText,
                        onPressed: () {
                          widget.onButtonClick();
                        }),
                    SizedBox(height: MySize.size30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
