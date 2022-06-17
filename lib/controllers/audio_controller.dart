import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:get/get.dart';

class AudioController extends GetxController {
  late Player player;
  final Map<String, Playlist> playLists = {
    'ini': Playlist(medias: []),
  };
  String currentPlaylistName = 'ini';

  @override
  void onInit() {
    DartVLC.initialize();
    player = Player(id: 69420, commandlineArguments: ['--no-video']);
  }

  void addMedia(List<String> canciones) {
    var p =
        Playlist(medias: canciones.map((e) => Media.file(File(e))).toList());
    playLists[currentPlaylistName] = p;
    // TODO guardar en disco
    for (var cancion in canciones) {
      player.add(Media.file(File(cancion)));
    }
    update();
  }

  Playlist currentPlaylist() {
    return playLists[currentPlaylistName]!;
  }

  void addPlaylist(String s) {
    playLists[s] = const Playlist(medias: []);
    update();
  }

  void setCurrentPlayList(String e) {
    currentPlaylistName = e;
    // var cdad = playLists[currentPlaylistName]!.medias.length;
    player.stop();
    player.dispose();
    player = Player(
      id: DateTime.now().millisecondsSinceEpoch,
      commandlineArguments: ['--no-video'],
    );
    for (var m in playLists[currentPlaylistName]!.medias) {
      player.add(m);
    }

    update();
  }
}
