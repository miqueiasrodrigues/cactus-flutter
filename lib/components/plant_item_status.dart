import 'package:cactus_v3/models/default.dart';
import 'package:cactus_v3/models/plant.dart';
import 'package:cactus_v3/models/plant_conf.dart';
import 'package:cactus_v3/routes/app_routes.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';

class PlantItemStatus extends StatefulWidget {
  final Plant _plant;
  const PlantItemStatus(this._plant);

  @override
  _PlantItemStatusState createState() => _PlantItemStatusState();
}

class _PlantItemStatusState extends State<PlantItemStatus> {
  final PlantConf _plantConf = new PlantConf();

  bool _isWarning() {
    return ((widget._plant.moisture > widget._plant.moistureMax) ||
        (widget._plant.moisture < widget._plant.moistureMin) ||
        (widget._plant.temperature > widget._plant.temperatureMax) ||
        (widget._plant.temperature < widget._plant.temperatureMin) ||
        (widget._plant.lighting > widget._plant.lightingMax) ||
        (widget._plant.lighting < widget._plant.lightingMin));
  }

  final Default _default = new Default();
  final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 7),
          child: ExpansionTileCard(
            expandedTextColor: Colors.black,
            expandedColor: Colors.grey[50],
            elevation: 2,
            shadowColor: Colors.black26,
            leading: CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage(
                // ignore: unnecessary_null_comparison
                (widget._plant.imageUrl == null ||
                        widget._plant.imageUrl.isEmpty)
                    ? _default.getPlantUrl()
                    : widget._plant.imageUrl,
              ),
            ),
            key: cardA,
            title: Text(widget._plant.title),
            subtitle: Wrap(
              spacing: double.infinity,
              children: [
                Text(
                  ((_isWarning() ||
                              (_plantConf.sunTime(
                                      _plantConf.defLighting(
                                          widget._plant.lightingMin,
                                          widget._plant.lightingMax),
                                      widget._plant.timer) ==
                                  2)) ==
                          true)
                      ? 'Leitura fora dos padrões estabelecidos' //suporte para o tempo
                      : ((_plantConf.sunTime(
                                  _plantConf.defLighting(
                                      widget._plant.lightingMin,
                                      widget._plant.lightingMax),
                                  widget._plant.timer) ==
                              1))
                          ? 'Ainda não recebeu o tempo ideal de luz'
                          : 'Aqui está tudo bem',
                  style: TextStyle(
                      color: ((_isWarning() ||
                                  (_plantConf.sunTime(
                                          _plantConf.defLighting(
                                              widget._plant.lightingMin,
                                              widget._plant.lightingMax),
                                          widget._plant.timer) ==
                                      2)) ==
                              true)
                          ? Colors.red
                          : ((_plantConf.sunTime(
                                      _plantConf.defLighting(
                                          widget._plant.lightingMin,
                                          widget._plant.lightingMax),
                                      widget._plant.timer) ==
                                  1))
                              ? Colors.yellow.shade800
                              : Colors.green),
                ),
                Text(
                  widget._plant.date,
                  style: TextStyle(color: Colors.grey.shade600),
                )
              ],
            ),
            children: <Widget>[
              Divider(
                thickness: 1.0,
                height: 15.0,
              ),
              Container(
                padding: EdgeInsets.all(20),
                width: 380,
                height: 380,
                child: _isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                        ],
                      )
                    : GridView.count(
                        physics: new NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 5,
                        crossAxisCount: 2,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 2,
                            shadowColor: Colors.black26,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: Icon(
                                            Icons.cloud_outlined,
                                            color: Colors.blue.shade900,
                                            size: 25,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue[100],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 25,
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: (widget._plant.moisture >
                                                      widget
                                                          ._plant.moistureMax ||
                                                  widget._plant.moisture <
                                                      widget._plant.moistureMin)
                                              ? Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: Colors.red.shade600,
                                                  size: 25,
                                                )
                                              : null,
                                        ),
                                      ),
                                      Container(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${widget._plant.moisture.round()}%',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 2,
                            shadowColor: Colors.black26,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: Icon(
                                            Icons.thermostat_outlined,
                                            color: Colors.red.shade900,
                                            size: 25,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red[100],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 25,
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: (widget._plant.temperature >
                                                      widget._plant
                                                          .temperatureMax ||
                                                  widget._plant.temperature <
                                                      widget._plant
                                                          .temperatureMin)
                                              ? Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: Colors.red.shade600,
                                                  size: 25,
                                                )
                                              : null,
                                        ),
                                      ),
                                      Container(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${widget._plant.temperature.round()}°',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 2,
                            shadowColor: Colors.black26,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: Icon(
                                            Icons.wb_sunny_outlined,
                                            color: Colors.yellow.shade900,
                                            size: 25,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.yellow[100],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 25,
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: (widget._plant.lighting >
                                                      widget
                                                          ._plant.lightingMax ||
                                                  widget._plant.lighting <
                                                      widget._plant.lightingMin)
                                              ? Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: Colors.red.shade600,
                                                  size: 25,
                                                )
                                              : null,
                                        ),
                                      ),
                                      Container(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${widget._plant.lighting.round()}%',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 2,
                            shadowColor: Colors.black26,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: Icon(
                                            Icons.access_time_rounded,
                                            size: 25,
                                            color: Colors.green.shade900,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green[100],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 25,
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: (_plantConf.sunTime(
                                                      _plantConf.defLighting(
                                                          widget._plant
                                                              .lightingMin,
                                                          widget._plant
                                                              .lightingMax),
                                                      widget._plant.timer) ==
                                                  1)
                                              ? Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: Colors.amber.shade600,
                                                  size: 25,
                                                )
                                              : (_plantConf.sunTime(
                                                          _plantConf.defLighting(
                                                              widget._plant
                                                                  .lightingMin,
                                                              widget._plant
                                                                  .lightingMax),
                                                          widget
                                                              ._plant.timer) ==
                                                      2)
                                                  ? Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color:
                                                          Colors.red.shade600,
                                                      size: 25,
                                                    )
                                                  : null,
                                        ),
                                      ),
                                      Container(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${_plantConf.readTimestamp(widget._plant.timer)}',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                buttonHeight: 52.0,
                buttonMinWidth: 90.0,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.PLANT_REGISTER,
                        arguments: widget._plant,
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.arrow_downward),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text('Visualizar'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      cardA.currentState?.collapse();
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.arrow_upward),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text('Fechar'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
