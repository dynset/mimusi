import 'dart:developer';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimusi/controllers/audio_controller.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AudioController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var pos = 0.8;
  static const ICON_SIZE = 30.0;
  var sliderValue = 0.0;
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://127.0.0.1:8000/ya'),
  );

  @override
  void initState() {
    channel.sink.add('holiss');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: channel.stream,
          builder: (context, snapshot) {
            log('data=${snapshot.data}');
            return Text(snapshot.hasData ? '${snapshot.data}' : 'todavia...');
          },
        ),
      ),
      body: SafeArea(
        child: GetBuilder<AudioController>(
          builder: (audioController) => Column(
            children: [
              Container(
                color: const Color(0xff54d056),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${audioController.player.current.media?.resource.split('/').last}',
                      style: const TextStyle(fontSize: 24),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            audioController.player.previous();
                          },
                          icon: const Icon(
                            Icons.skip_previous,
                            size: ICON_SIZE,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        IconButton(
                          onPressed: () {
                            audioController.player.playOrPause();
                          },
                          icon: const Icon(
                            Icons.play_circle_outline,
                            size: ICON_SIZE,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        IconButton(
                          onPressed: () {
                            audioController.player.next();
                          },
                          icon: const Icon(
                            Icons.skip_next,
                            size: ICON_SIZE,
                          ),
                        )
                      ],
                    ),
                    Slider(
                      value: sliderValue,
                      onChanged: (v) {
                        setState(() {
                          sliderValue = v;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    ListasWidget(audioController),
                    Expanded(
                      child: PlayListWidget(audioController),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class PlayListWidget extends StatelessWidget {
  AudioController audioController;

  PlayListWidget(
    this.audioController, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detalles) {
        audioController.addMedia(
          detalles.files.map((e) => e.path).toList(),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: audioController
            .currentPlaylist()
            .medias
            .map((e) => ListTile(
                  title: Text(e.resource.split('/').last),
                  subtitle: Text('${e.mediaType}'),
                  trailing: Text('02:46'),
                ))
            .toList(),
      ),
    );
  }
}

class ListasWidget extends StatelessWidget {
  AudioController audioController;
  String current = '';

  var tecNombre = TextEditingController();

  ListasWidget(
    this.audioController, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.black26,
          ),
        ),
      ),
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...audioController.playLists.keys
              .map(
                (e) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    audioController.setCurrentPlayList(e);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      e,
                      style: e == audioController.currentPlaylistName
                          ? const TextStyle(color: Colors.red)
                          : null,
                    ),
                  ),
                ),
              )
              .toList(),
          Center(
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                var nombre = await Get.defaultDialog<String>(
                  title: 'Nombre',
                  content: Column(
                    children: [
                      TextField(
                        controller: tecNombre,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Get.back(result: tecNombre.text);
                          },
                          child: Text('OK'))
                    ],
                  ),
                );
                if (nombre != null && nombre.isNotEmpty) {
                  audioController.addPlaylist(nombre);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
