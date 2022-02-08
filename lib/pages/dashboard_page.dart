import 'package:cactus_v3/components/plant_item_status.dart';
import 'package:cactus_v3/provider/plants_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Plants _plantList = Provider.of(context);
    return Scaffold(
      // ignore: unnecessary_null_comparison
      body: (_plantList.getActive().isEmpty == true)
          ? Stack(
              children: <Widget>[
                ListView(),
                Align(
                  child: Container(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/images/cctv.png'),
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: _plantList.activeCount,
              itemBuilder: (context, index) => PlantItemStatus(
                _plantList.activeByIndex(index),
              ),
            ),
    );
  }
}
