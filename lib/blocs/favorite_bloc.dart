import 'dart:convert';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fluttertube/models/video.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class FavoriteBloc implements BlocBase {
  Map<String, Video> _favorites = {};

  String keyfav = "favorites";

  final _favController = BehaviorSubject<Map<String, Video>>(seedValue: {});

  Stream<Map<String, Video>> get outFav => _favController.stream;

  FavoriteBloc() {
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getKeys().contains(keyfav)) {
        _favorites = json.decode(prefs.getString(keyfav)).map((k, v) {
          return MapEntry(k, Video.fromJson(v));
        }).cast<String, Video>();
        _favController.add(_favorites);
      }
    });
  }

  void toggleFavorite(Video video) {
    if (_favorites.containsKey(video.id))
      _favorites.remove(video.id);
    else
      _favorites[video.id] = video;

    _favController.sink.add(_favorites);

    _saveFav();
  }

  void _saveFav() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(keyfav, json.encode(_favorites));
    });
  }

  @override
  void dispose() {
    _favController.close();
  }
}
