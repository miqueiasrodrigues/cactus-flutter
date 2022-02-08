import 'dart:convert';

import 'package:cactus_v3/models/plant.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Plants with ChangeNotifier {
  static const _baseUrl = '';
  final Map<String, Plant> _items = {};
  Map<String, Plant> _activeItems = {};
  String _idPlant = '';

  List<Plant> get all {
    return [..._items.values];
  }

  int get count {
    return _items.length;
  }

  Plant byIndex(int index) {
    return _items.values.elementAt(index);
  }

  Map<String, Plant> getItems() {
    return _items;
  }

  Map<String, dynamic> getActive() {
    return _activeItems;
  }

  int get activeCount {
    return _activeItems.length;
  }

  Plant activeByIndex(int index) {
    return _activeItems.values.elementAt(index);
  }

  String returnId() {
    return _idPlant;
  }

  Future<void> load(String _userId) async {
    final response = await get(Uri.parse("$_baseUrl/$_userId/plants.json"));
    _items.clear();
    _activeItems.clear();
    Map<String, dynamic> data = {};

    try {
      data = json.decode(response.body);
    } catch (e) {
      data = {};
    }
    // ignore: unnecessary_null_comparison
    if (data != null) {
      data.forEach((plantId, plantData) {
        _items.putIfAbsent(
          plantId,
          () => Plant(
            plantId: plantId,
            imageUrl: plantData['imageUrl'],
            title: plantData['title'],
            moistureMin: double.parse(plantData['moistureMin'].toString()),
            moistureMax: double.parse(plantData['moistureMax'].toString()),
            moisture: double.parse(plantData['moisture'].toString()),
            temperatureMin:
                double.parse(plantData['temperatureMin'].toString()),
            temperatureMax:
                double.parse(plantData['temperatureMax'].toString()),
            temperature: double.parse(plantData['temperature'].toString()),
            lighting: double.parse(plantData['lighting'].toString()),
            lightingMin: double.parse(plantData['lightingMin'].toString()),
            lightingMax: double.parse(plantData['lightingMax'].toString()),
            situation: plantData['situation'],
            arduino: plantData['arduino'],
            date: plantData['date'],
            register: plantData['register'],
            timer: int.parse(plantData['timer'].toString()),
            ssid: plantData['ssid'],
            pass: plantData['pass'],
          ),
        );
      });
      _items.forEach((key, value) {
        if (value.situation == true) {
          _activeItems[key] = value;
        }
      });
      notifyListeners();
    }
    return Future.value();
  }

  Future<void> put(Plant _plant, String _userId) async {
    // ignore: unnecessary_null_comparison
    if (_plant == null) {
      return;
    }
    // ignore: unnecessary_null_comparison
    if (_plant.plantId != null &&
        _plant.plantId.trim().isNotEmpty &&
        _items.containsKey(_plant.plantId)) {
      await patch(
        Uri.parse("$_baseUrl/$_userId/plants/${_plant.plantId}.json"),
        body: json.encode({
          'title': _plant.title,
          'imageUrl': _plant.imageUrl,
          'moistureMin': _plant.moistureMin,
          'moistureMax': _plant.moistureMax,
          'moisture': _plant.moisture,
          'temperatureMin': _plant.temperatureMin,
          'temperatureMax': _plant.temperatureMax,
          'temperature': _plant.temperature,
          'lightingMin': _plant.lightingMin,
          'lightingMax': _plant.lightingMax,
          'lighting': _plant.lighting,
          'situation': _plant.situation,
          'arduino': _plant.arduino,
          'date': _plant.date,
          'register': _plant.register,
          'timer': _plant.timer,
          'ssid': _plant.ssid,
          'pass': _plant.pass,
        }),
      );
      _items.update(
        _plant.plantId,
        (_) => _plant,
      );
    } else {
      final response = await post(
        Uri.parse("$_baseUrl/$_userId/plants/${_plant.plantId}.json"),
        body: json.encode({
          'title': _plant.title,
          'imageUrl': _plant.imageUrl,
          'moistureMin': _plant.moistureMin,
          'moistureMax': _plant.moistureMax,
          'moisture': _plant.moisture,
          'temperatureMin': _plant.temperatureMin,
          'temperatureMax': _plant.temperatureMax,
          'temperature': _plant.temperature,
          'lightingMin': _plant.lightingMin,
          'lightingMax': _plant.lightingMax,
          'lighting': _plant.lighting,
          'situation': _plant.situation,
          'arduino': _plant.arduino,
          'date': _plant.date,
          'register': _plant.register,
          'timer': _plant.timer,
          'ssid': _plant.ssid,
          'pass': _plant.pass,
        }),
      );

      final id = json.decode(response.body)['name'];
      _idPlant = id.toString();

      _items.putIfAbsent(
        id,
        () => Plant(
          plantId: id,
          title: _plant.title,
          imageUrl: _plant.imageUrl,
          moistureMin: _plant.moistureMin,
          moistureMax: _plant.moistureMax,
          moisture: _plant.moisture,
          temperatureMin: _plant.temperatureMin,
          temperatureMax: _plant.temperatureMax,
          temperature: _plant.temperature,
          lightingMin: _plant.lightingMin,
          lightingMax: _plant.lightingMax,
          lighting: _plant.lighting,
          situation: _plant.situation,
          arduino: _plant.arduino,
          date: _plant.date,
          register: _plant.register,
          timer: _plant.timer,
          ssid: _plant.ssid,
          pass: _plant.pass,
        ),
      );
    }
    notifyListeners();
  }

  Future<void> remove(Plant _plant, String _userId) async {
    // ignore: unnecessary_null_comparison
    if (_plant != null && _plant.plantId != null) {
      _items.remove(_plant.plantId);
      notifyListeners();

      await delete(
          Uri.parse("$_baseUrl/$_userId/plants/${_plant.plantId}.json"));
    }
  }

  Future<void> deleteImg(Plant _plant) async {
    try {
      await FirebaseStorage.instance.refFromURL(_plant.imageUrl).delete();
    } catch (e) {
      print("Error deleting db from cloud: $e");
    }
  }

  Future<void> deleteFileArduino(Plant _plant) async {
    try {
      await FirebaseStorage.instance.refFromURL(_plant.arduino).delete();
    } catch (e) {
      print("Error deleting db from cloud!: $e");
    }
  }
}
