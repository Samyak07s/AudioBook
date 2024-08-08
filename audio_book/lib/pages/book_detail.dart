import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart' as AppColors;
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class BookDetailPage extends StatefulWidget {
  final dynamic book;

  const BookDetailPage({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  bool Liked=false;
  Duration _audioDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _loadAudio();
    _loadLikedState();
    // Listener to update the current position of the audio
    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _currentPosition = p;
      });
    });

    // Listener to update the duration of the audio
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _audioDuration = d;
      });
    });

    // Listener for when the audio is completed
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _currentPosition = Duration.zero;
        isPlaying = false;
      });
    });
  }

   Future<void> _loadAudio() async {
    await _audioPlayer.setSource(AssetSource(widget.book['audio']));
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _audioDuration = d;
      });
    });
  }

  Future<void> _loadLikedState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      Liked = prefs.getBool('${widget.book["title"]}_liked') ?? false;
    });
  }

  Future<void> _saveLikedState(bool likedState) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('${widget.book["title"]}_liked', likedState);

    // Load the current list of liked books
    final List<String>? likedBooksData = prefs.getStringList('liked_books');
    List<dynamic> likedBooks = likedBooksData != null
        ? likedBooksData.map((bookJson) => json.decode(bookJson)).toList()
        : [];

    if (likedState) {
      // Add book to liked list if likedState is true
      if (!likedBooks.any((book) => book['title'] == widget.book['title'])) {
        likedBooks.add(widget.book);
      }
    } else {
      // Remove book from liked list if likedState is false
      likedBooks.removeWhere((book) => book['title'] == widget.book['title']);
    }

    // Save the updated list of liked books
    prefs.setStringList(
        'liked_books', likedBooks.map((book) => json.encode(book)).toList());
  }


  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPauseAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      print('Playing audio: ${widget.book["audio"]}'); // Log file path
      await _audioPlayer.play(AssetSource(widget.book["audio"]));
    }
    setState(() {
      isPlaying = !isPlaying;
      print('Audio playing state: $isPlaying'); // Log play/pause state
    });
  }
  

  void _rewindAudio() async {
    Duration? position = await _audioPlayer.getCurrentPosition();
    if (position != null) {
      _audioPlayer.seek(Duration(milliseconds: position.inMilliseconds - 5000));
    }
  }

  void _forwardAudio() async {
    Duration? position = await _audioPlayer.getCurrentPosition();
    Duration? duration = await _audioPlayer.getDuration();
    if (position != null && duration != null) {
      _audioPlayer.seek(Duration(milliseconds: position.inMilliseconds + 5000));
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                Liked = !Liked;
                _saveLikedState(Liked);

              });
            },
            icon: Icon(Liked ? Icons.favorite : Icons.favorite_border),
            color: Liked ? Colors.red : const Color.fromARGB(255, 3, 3, 3),
          ),
        ],
      ),
      body: Center(
        child: Container(
          height: 700,
          width: 350,
          child: Column(
            children: [
              Text(
                widget.book["title"],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  fontFamily: "Avenir",
                ),
              ),
              Text(
                widget.book["text"],
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Avenir",
                ),
              ),
              SizedBox(height: 50),
              // image
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(widget.book["img"]),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 58, 58, 58),
                      offset: Offset(0.0, 10.0),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(flex:2,child: Text(_formatDuration(_currentPosition))),
                  
                  Flexible(
                    flex: 6,
                    child: Slider(
                      value: _currentPosition.inMilliseconds.toDouble().clamp(0, _audioDuration.inMilliseconds.toDouble()),
                      min: 0.0,
                      max: _audioDuration.inMilliseconds.toDouble(),
                      onChanged: (double value) {
                        setState(() {
                          _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                        });
                      },
                    ),
                  ),
                  Flexible(flex:2, child: Text(_formatDuration(_audioDuration))),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 50),
                  // Handle rewind 5 seconds
                  IconButton(
                    onPressed: _rewindAudio,
                    icon: Icon(Icons.replay_5),
                    iconSize: 30,
                  ),
                  // Handle play/pause
                  IconButton(
                    onPressed: _playPauseAudio,
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    iconSize: 75,
                  ),
                  // Handle skip 5 seconds ahead
                  IconButton(
                    onPressed: _forwardAudio,
                    icon: Icon(Icons.forward_5),
                    iconSize: 30,
                  ),
                  SizedBox(width: 50),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
