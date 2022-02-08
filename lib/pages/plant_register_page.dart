import 'package:cactus_v3/components/plant_register.dart';
import 'package:cactus_v3/models/plant.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:intl/intl.dart';

class PlantRegisterPage extends StatefulWidget {
  const PlantRegisterPage({Key? key}) : super(key: key);
  @override
  _PlantRegisterPageState createState() => _PlantRegisterPageState();
}

class _PlantRegisterPageState extends State<PlantRegisterPage> {
  @override
  Widget build(BuildContext context) {
    final _plant = ModalRoute.of(context)!.settings.arguments as Plant;
    return Scaffold(
      appBar: AppBar(
        title: Text(_plant.title),
      ),
      // ignore: unnecessary_null_comparison
      body: (_plant.register == null)
          ? Stack(
              children: <Widget>[
                ListView(),
                Align(
                  child: Container(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/images/settings.png'),
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: _plant.register.length,
              itemBuilder: (context, index) => PlantRegister(
                _plant.register.values.elementAt(index),
                _plant,
              ),
            ),
    );
  }
}
