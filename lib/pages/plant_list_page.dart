import 'package:cactus_v3/components/plant_item.dart';
import 'package:cactus_v3/provider/plants_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlantListPage extends StatelessWidget {
  const PlantListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Plants _plantList = Provider.of(context);
    return Scaffold(
      // ignore: unnecessary_null_comparison
      body: (_plantList.getItems().isEmpty == true)
          ? Stack(
              children: <Widget>[
                ListView(),
                Align(
                  child: Container(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/images/temperature.png'),
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: _plantList.count,
              itemBuilder: (context, index) => PlantItem(
                _plantList.byIndex(index),
              ),
            ),
    );
  }
}
