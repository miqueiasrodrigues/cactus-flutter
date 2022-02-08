import 'package:cactus_v3/models/plant.dart';
import 'package:cactus_v3/models/plant_conf.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:sticky_headers/sticky_headers/widget.dart';

class PlantRegister extends StatelessWidget {
  final List<dynamic> _register;
  final Plant _plant;
  const PlantRegister(this._register, this._plant);

  bool _isWarning() {
    return ((_register.elementAt(2) > _plant.moistureMax) ||
        (_register.elementAt(2) < _plant.moistureMin) ||
        (_register.elementAt(3) > _plant.temperatureMax) ||
        (_register.elementAt(3) < _plant.temperatureMin) ||
        (_register.elementAt(4) > _plant.lightingMax) ||
        (_register.elementAt(4) < _plant.lightingMin));
  }

  @override
  Widget build(BuildContext context) {
    final PlantConf _plantConf = new PlantConf();
    return StickyHeader(
      header: Container(
        height: 55.0,
        color: _isWarning() == true
            ? Colors.red.shade300
            : Colors.lightGreen.shade300,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Text(
          '${_register.elementAt(1)}',
        ),
      ),
      content: Column(
        children: [
          ListTile(
            title: Text('Temperatura'),
            leading: Icon(Icons.thermostat_outlined),
            subtitle: Text('${_register.elementAt(3)}°'),
          ),
          ListTile(
            title: Text('Umidade'),
            leading: Icon(Icons.cloud_outlined),
            subtitle: Text('${_register.elementAt(2)}%'),
          ),
          ListTile(
            title: Text('Iluminação'),
            leading: Icon(Icons.wb_sunny_outlined),
            subtitle: Text('${_register.elementAt(4)}%'),
          ),
          ListTile(
            title: Text('Tempo'),
            leading: Icon(Icons.access_time_rounded),
            subtitle:
                Text('${_plantConf.readTimestamp(_register.elementAt(5))}'),
          ),
        ],
      ),
    );
  }
}
