import 'dart:async';

import 'package:flutter/material.dart';
import 'music.dart';
import 'package:audioplayer/audioplayer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotifa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Spotifa'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Music> myMusicList = [
    new Music('Musique une', 'Artiste un', 'assets/alpine.jpg',
        'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    new Music('Musique deux', 'Artiste deux', 'assets/fantasy.jpg',
        'https://codabee.com/wp-content/uploads/2018/06/deux.mp3'),
  ];

  AudioPlayer audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription stateSubscription;
  Music myActualMusic;
  Duration position = new Duration(seconds: 0);
  Duration time = new Duration(seconds: 10);
  PlayerState status = PlayerState.stopped;
  int index = 0;

  @override
  void initState() {
    super.initState();
    myActualMusic = myMusicList[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(widget.title),
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 9.0,
              child: new Container(
                width: MediaQuery.of(context).size.height / 2.5,
                child: new Image.asset(
                  myActualMusic.getImagePath(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            textWithStyle(myActualMusic.getTitle(), 1.5),
            textWithStyle(myActualMusic.getArtist(), 1.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //todo switch de bouton play / pause en fonction de la musique
                button(Icons.fast_rewind, 30.0, ActionMusic.previous),
                button(
                    (status == PlayerState.playing)
                        ? Icons.pause
                        : Icons.play_arrow,
                    45.0,
                    (status == PlayerState.playing)
                        ? ActionMusic.pause
                        : ActionMusic.play),
                button(Icons.fast_forward, 30.0, ActionMusic.next),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                textWithStyle(fromDuration(position), 0.8),
                textWithStyle(fromDuration(time), 0.8),
              ],
            ),
            new Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 30.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d) {
                  setState(() {
                    //Duration newDuration = new Duration(seconds: d.toInt());
                    //position = newDuration;
                    audioPlayer.seek(d);
                  });
                }),
          ],
        ),
      ),
    );
  }

  Text textWithStyle(String data, double scale) {
    return new Text(data,
        textScaleFactor: scale,
        textAlign: TextAlign.center,
        style: new TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontStyle: FontStyle.italic,
        ));
  }

  IconButton button(IconData icon, double scale, ActionMusic action) {
    return new IconButton(
        iconSize: scale,
        color: Colors.white,
        icon: new Icon(icon),
        onPressed: () {
          switch (action) {
            case ActionMusic.play:
              //print("start de la musique");
              play();
              break;
            case ActionMusic.pause:
              //print("pause de la musique");
              pause();
              break;
            case ActionMusic.next:
              //print("next musique");
              next();
              break;
            case ActionMusic.previous:
              //print("previous musique");
              previous();
              break;
          }
        });
  }

  void configurationAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged
        .listen((pos) => setState(() => position = pos));
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          time = audioPlayer.duration;
        });
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          status = PlayerState.stopped;
        });
      }
    }, onError: (message) {
      print("Erreur : $message");
      setState(() {
        status = PlayerState.stopped;
        time = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(myActualMusic.getUrlSong());
    setState(() {
      status = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      status = PlayerState.paused;
    });
  }

  void next() {
    if (index == myMusicList.length - 1) {
      index = 0;
    } else {
      index++;
    }
    myActualMusic = myMusicList[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }

  void previous() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(0.0);
    } else {
      if (index == 0) {
        index = myMusicList.length - 1;
      } else {
        index--;
      }
      myActualMusic = myMusicList[index];
      audioPlayer.stop();
      configurationAudioPlayer();
      play();
    }
  }

  // Recupere le temps de la chanson
  String fromDuration(Duration time) {
    return time.toString().split('.').first;
  }

}

// enum des boutons en dehors de la classe TOUJOURS
enum ActionMusic {
  play,
  pause,
  next,
  previous,
}

// enum des etats de l'audio player
enum PlayerState {
  playing,
  stopped,
  paused,
}
