import 'dart:io';

import 'package:cactus_v3/components/snackbar.dart';
import 'package:cactus_v3/models/default.dart';
import 'package:cactus_v3/models/plant.dart';
import 'package:cactus_v3/models/plant_conf.dart';
import 'package:cactus_v3/provider/plants_provider.dart';
import 'package:cactus_v3/provider/users_provider.dart';
import 'package:cactus_v3/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PlantInfoPage extends StatefulWidget {
  @override
  _PlantInfoPageState createState() => _PlantInfoPageState();
}

class _PlantInfoPageState extends State<PlantInfoPage> {
  bool _isLoading = false;
  final Snackbar _snackBar = new Snackbar();
  final Default _default = new Default();
  final PlantConf _plantConf = new PlantConf();

  @override
  Widget build(BuildContext context) {
    final Users _users = Provider.of(context);
    final _plant = ModalRoute.of(context)!.settings.arguments as Plant;

    return Scaffold(
      appBar: AppBar(
        title: Text(_plant.title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.PLANT_FORM_EDIT,
                arguments: _plant,
              );
            },
            icon: Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                Container(
                  height: 190,
                  width: double.infinity,
                  child: Image.network(
                    _plant.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Nome'),
                  leading: Icon(Icons.book_outlined),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(_plant.title),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Temperatura'),
                  leading: Icon(Icons.thermostat_outlined),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text('Mín: ${_plant.temperatureMin}°C'),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Máx: ${_plant.temperatureMax}°C'),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Umidade do solo'),
                  leading: Icon(Icons.cloud_outlined),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          _plantConf.defMoisture(
                              _plant.moistureMin, _plant.moistureMax),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Mín: ${_plant.moistureMin}%'),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Máx: ${_plant.moistureMax}%'),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Iluminação'),
                  leading: Icon(Icons.wb_sunny_outlined),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          _plantConf.defLighting(
                              _plant.lightingMin, _plant.lightingMax),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Mín: ${_plant.lightingMin}%'),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Máx: ${_plant.lightingMax}%'),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Tempo de luz'),
                  leading: Icon(Icons.access_time_rounded),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                            'Mín: ${_plantConf.readTimestamp(_plantConf.sunTimeValue(
                                  _plantConf.defLighting(
                                      _plant.lightingMin, _plant.lightingMax),
                                ).first)}'),
                      ),
                      (_plantConf.defLighting(
                                  _plant.lightingMin, _plant.lightingMax) ==
                              'Sol pleno')
                          ? Container()
                          : Expanded(
                              flex: 2,
                              child: Text(
                                  'Máx: ${_plantConf.readTimestamp(_plantConf.sunTimeValue(
                                        _plantConf.defLighting(
                                            _plant.lightingMin,
                                            _plant.lightingMax),
                                      ).last)}'),
                            ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Rede'),
                  leading: Icon(Icons.wifi_outlined),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text('${_plant.ssid}'),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Situação'),
                  leading: Icon((_plant.situation != true)
                      ? Icons.public_off_outlined
                      : Icons.public_outlined),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          (_plant.situation != true) ? 'Desativada' : 'Ativada',
                          style: TextStyle(
                              color: (_plant.situation != true)
                                  ? Colors.red
                                  : Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
                (_plant.situation == true)
                    ? Column(
                        children: [
                          Divider(),
                          ListTile(
                            title: Text('Arduino'),
                            leading: Container(
                              width: 25,
                              height: 25,
                              child: Image.asset(
                                'assets/images/motherboard.png',
                              ),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Conectado',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              width: 60,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Desativar arduino?'),
                                          content: Text(
                                              'Você também vai desativa a cultura,\nTem certeza?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('Não'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Sim'),
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                            )
                                          ],
                                        ),
                                      ).then((value) async {
                                        if (value) {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          try {
                                            await Provider.of<Plants>(context,
                                                    listen: false)
                                                .put(
                                              Plant(
                                                plantId: _plant.plantId,
                                                title: _plant.title,
                                                imageUrl: _plant.imageUrl,
                                                moistureMin: _plant.moistureMin,
                                                moistureMax: _plant.moistureMax,
                                                moisture: _plant.moisture,
                                                temperatureMin:
                                                    _plant.temperatureMin,
                                                temperatureMax:
                                                    _plant.temperatureMax,
                                                temperature: _plant.temperature,
                                                lightingMin: _plant.lightingMin,
                                                lightingMax: _plant.lightingMax,
                                                lighting: _plant.lighting,
                                                situation: false,
                                                arduino: _plant.arduino,
                                                date: _plant.date,
                                                register: _plant.register,
                                                timer: _plant.timer,
                                                ssid: _plant.ssid,
                                                pass: _plant.pass,
                                              ),
                                              _users
                                                  .byIndex(0)
                                                  .email
                                                  .replaceAll('.', ':'),
                                            );
                                            await Navigator.of(context)
                                                .pushReplacementNamed(
                                                    AppRoutes.HOME);
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          } catch (e) {
                                            _snackBar.snackbarFloat(
                                                e.toString(), context, true);
                                          }
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      Icons.delete_outlined,
                                      color: Colors.red,
                                    ),
                                    splashRadius: 30,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Divider(),
                        ],
                      )
                    : Column(
                        children: [
                          Divider(),
                          ListTile(
                            title: Text('Código do arquivo'),
                            leading: Icon(Icons.code_outlined),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'xxxx_${_plant.title}_conf.txt'
                                        .toLowerCase(),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              width: 60,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final status =
                                          await Permission.storage.request();

                                      if (status.isGranted) {
                                        final String externalDir =
                                            '/storage/emulated/0/Download/Cactus';
                                        try {
                                          await new Directory(externalDir)
                                              .create();
                                        } catch (e) {
                                          print(e);
                                        }

                                        await FlutterDownloader.enqueue(
                                          url: _plant.arduino.toString(),
                                          fileName: (_default.getId() +
                                                  '_${_plant.title}_' +
                                                  'conf.txt')
                                              .toLowerCase(),
                                          savedDir: externalDir,
                                          showNotification: true,
                                          openFileFromNotification: true,
                                        );
                                        _snackBar.snackbar(
                                            'O download do arquivo foi realizado com sucesso!',
                                            context,
                                            false);
                                      } else {
                                        _snackBar.snackbar(
                                            'O download do arquivo não foi realizado!',
                                            context,
                                            true);
                                      }
                                    },
                                    icon: Icon(
                                      Icons.download_outlined,
                                      color: Colors.lightGreen,
                                      size: 26,
                                    ),
                                    splashRadius: 30,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Divider(),
                        ],
                      )
              ],
            ),
    );
  }
}
