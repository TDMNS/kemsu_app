import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kemsu_app/UI/views/news/news_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import '../../../Configurations/config.dart';
import 'news_videoPlayer.dart';

class NewsViewModel extends BaseViewModel {
  NewsViewModel(BuildContext context);

  final storage = const FlutterSecureStorage();
  String newsURL = 'https://api3.kemsu.ru';
  String? videoURL;
  int selectedIndex = 0;
  int newsLimit = 50;
  bool showNews = false;
  bool fileLoader = false;
  int newsIndex = 0;
  bool stopOrPause = false;
  bool videoPlay = false;
  String? videoPath;
  File? decodeVideo;
  MemoryImage? newsImage;
  ImageProvider? imageTG;
  String? mimeType;
  List<dynamic>? tempData;
  List<dynamic>? imageFromTG;
  File? file;
  Uint8List? tgImage;
  List<String> textList = [];
  List<int> idList = [];
  List<IconData> newsIcons = [];
  final player = AudioPlayer();
  Uint8List? tempSound;
  Uint8List? tempPic;
  late VideoPlayerController videoController;
  List<Autogenerated> newsModel = [];
  List<AllNews> newsModel2 = [];
  AllNews? newsTemp;
  List<List<Autogenerated>> allNewsModel = [];
  bool videoLoader = false;

  void onTapBottomBar(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void fileLoaderChange(value) {
    fileLoader = value;
    notifyListeners();
  }

  messageService() async {
    String? partialFileUrl;
    String? token = await storage.read(key: 'tokenKey');
    final newsResponse = await http.get(Uri.parse('${Config.newsMessages}?limit=$newsLimit'), headers: {'x-access-token': token!});
    tempData = json.decode(newsResponse.body);
    for (int i = 0; i < tempData!.length; i++) {
      if (tempData![i][0]['message'] == null) {
        tempData!.removeAt(i);
      }
    }
    List<dynamic> tempo = [];
    for (int i = 0; i < tempData!.length; i++) {
      tempo.add(tempData![i]);
    }
    for (int i = 0; i < tempData!.length; i++) {
      var tempo = [];
      tempo.add(tempData![i]);
    }

    for (int i = 0; i < tempData!.length; i++) {
      dynamic lengthNews = tempData![i];
      int numero = lengthNews.length;
      var file = tempData![i][0]['file'];
      if (tempData![i][numero - 1]['message'] != null) {
        if (file != null) {
          if (file['mimeType'] == 'image/jpeg' && tempData![i][numero - 1]['message'] == '') {
            textList.add('Просмотр изображения');
            idList.add(tempData![i][numero - 1]['id']);
            newsIcons.add(Icons.image);
          } else if (file['mimeType'] == 'audio/mpeg' && tempData![i][numero - 1]['message'] == '') {
            textList.add('Открыть аудио');
            idList.add(tempData![i][numero - 1]['id']);
            newsIcons.add(Icons.audiotrack);
          } else if (file['mimeType'] == 'video/mp4' && tempData![i][numero - 1]['message'] == '') {
            textList.add('Открыть видео');
            idList.add(tempData![i][numero - 1]['id']);
            newsIcons.add(Icons.video_collection_rounded);
          } else {
            textList.add(tempData![i][numero - 1]['message']);
            idList.add(tempData![i][numero - 1]['id']);
            newsIcons.add(Icons.newspaper);
          }
        } else if (tempData![i][numero - 1]['message'] != '' && tempData![i][numero - 1]['message'] != null) {
          textList.add(tempData![i][numero - 1]['message']);
          idList.add(tempData![i][numero - 1]['id']);
          newsIcons.add(Icons.newspaper);
        }
      }
    }

    for (int i = 0; i < tempData!.length; i++) {
      if (tempData![i][0]['file'] != null) {
        partialFileUrl = tempData![i][0]['partialFileUrl'];
      }
    }
    String fileURL = 'https://api-dev.kemsu.ru$partialFileUrl';
    final getFile = await http.get(Uri.parse('$fileURL&thumbSize=y'), headers: {'x-access-token': token});

    imageTG = Image.memory(getFile.bodyBytes).image;
    tgImage = getFile.bodyBytes;
    notifyListeners();
  }

  Future onReady() async {
    messageService();
  }

  void appMetricaTest() {
    AppMetrica.activate(const AppMetricaConfig("21985624-7a51-4a70-8a98-83b918e490d8"));
    AppMetrica.reportEvent('This is new test event!');
  }

  void pauseOrStop(value) {
    stopOrPause = value;
    notifyListeners();
  }

  void tempAudioNull() {
    tempSound = null;
    notifyListeners();
  }

  void testMessage(index) async {
    mimeType = null;

    String? partialFileUrl;
    String? token = await storage.read(key: 'tokenKey');
    final newsResponse = await http.get(Uri.parse('${Config.newsMessages}?limit=$newsLimit'), headers: {'x-access-token': token!});
    tempData = json.decode(newsResponse.body);
    for (int i = 0; i < tempData!.length; i++) {
      if (tempData![i][0]['message'] == null) {
        tempData!.removeAt(i);
      }
    }
    partialFileUrl = tempData![index][0]['partialFileUrl'];

    tempData![index][0]['id'] = idList[index];

    if (tempData![index][0]['file'] != null) {
      mimeType = tempData![index][0]['file']['mimeType'];
      if (mimeType == 'image/jpeg') {
        getPicture(partialFileUrl);
      } else if (mimeType == 'audio/mpeg') {
        getAudio(partialFileUrl);
      } else if (mimeType == 'video/mp4') {
        getVideoPreview(partialFileUrl);
      }
    } else {
      mimeType = null;
    }
    notifyListeners();
  }

  changeIndex(index) {
    newsIndex = index;
    notifyListeners();
  }

  getAudio(partialFileUrl) async {
    String? token = await storage.read(key: 'tokenKey');
    String fileURL = '${Config.newsFile}$partialFileUrl';
    final getFile = await http.get(Uri.parse('$fileURL&thumbSize=y'), headers: {'x-access-token': token!});
    tempSound = getFile.bodyBytes;
    fileLoader = false;
    notifyListeners();
  }

  getPicture(partialFileUrl) async {
    String? token = await storage.read(key: 'tokenKey');
    String fileURL = '${Config.newsFile}$partialFileUrl';
    videoURL = fileURL;
    final getFile = await http.get(Uri.parse('$fileURL&thumbSize=y'), headers: {'x-access-token': token!});
    tempPic = getFile.bodyBytes;
    newsImage = MemoryImage(tempPic!);
    fileLoader = false;
    notifyListeners();
  }

  getVideoPreview(partialFileUrl) async {
    String? token = await storage.read(key: 'tokenKey');
    String fileURL = '${Config.newsFile}$partialFileUrl';
    videoURL = fileURL;
    final getFile = await http.get(Uri.parse('$fileURL&thumbSize=m'), headers: {'x-access-token': token!});
    tempPic = getFile.bodyBytes;
    fileLoader = false;
    notifyListeners();
  }

  getVideo(context, index) async {
    videoLoader = true;
    notifyListeners();
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    String? token = await storage.read(key: 'tokenKey');
    final newsResponse = await http.get(Uri.parse('${Config.newsMessages}?limit=$newsLimit'), headers: {'x-access-token': token!});
    tempData = json.decode(newsResponse.body);

    for (int i = 0; i < tempData!.length; i++) {
      if (tempData![i][0]['message'] == null) {
        tempData!.removeAt(i);
      }
    }
    String partialFileUrl = tempData![index][0]['partialFileUrl'];

    String fileURL = '${Config.newsFile}$partialFileUrl';
    final getFile = await http.get(Uri.parse(fileURL), headers: {'x-access-token': token});
    fileLoader = false;
    decodeVideo = await File("$path/video1.mp4").writeAsBytes(getFile.bodyBytes);
    videoPath = decodeVideo!.path;
    videoPlayFunc(true);
    videoController = VideoPlayerController.networkUrl(UriData.fromString('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4').uri);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VideoApp(
                file: decodeVideo,
              )),
    );
    videoLoader = false;
    notifyListeners();
  }

  void playVideo() {
    videoController.play();
    notifyListeners();
  }

  void pauseVideo() {
    videoController.pause();
    notifyListeners();
  }

  void videoPlayFunc(value) {
    videoPlay = value;
    notifyListeners();
  }

  void openNewsCard() async {}

  void newsOnOff(value) async {
    showNews = value;
    notifyListeners();
  }

  String getTimeStringFromDouble(int value) {
    if (value < 0) return 'Invalid Value';
    int flooredValue = value.floor();
    int decimalValue = value - flooredValue;
    String hourValue = getHourString(flooredValue);
    String minuteString = getMinuteString(decimalValue);

    return '$hourValue:$minuteString';
  }

  String getMinuteString(int decimalValue) {
    return '${(decimalValue * 60).toInt()}'.padLeft(2, '0');
  }

  String getHourString(int flooredValue) {
    return '${flooredValue % 24}'.padLeft(2, '0');
  }

  List<Autogenerated> parseTest(List response) {
    return response.map<Autogenerated>((json) => Autogenerated.fromJson(json)).toList();
  }

  List<AllNews> parseNews(List response) {
    return response.map<AllNews>((json) => AllNews.fromJson(json)).toList();
  }
}
