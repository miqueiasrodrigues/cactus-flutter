import 'package:cactus_v3/components/snackbar.dart';
import 'package:cactus_v3/models/default.dart';
import 'package:cactus_v3/models/plant.dart';
import 'package:cactus_v3/provider/plants_provider.dart';
import 'package:cactus_v3/provider/users_provider.dart';
import 'package:cactus_v3/routes/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlantItem extends StatefulWidget {
  final Plant _plant;
  const PlantItem(this._plant);

  @override
  _PlantItemState createState() => _PlantItemState();
}

class _PlantItemState extends State<PlantItem> {
  Snackbar _snackBar = new Snackbar();
  final Default _default = new Default();

  @override
  Widget build(BuildContext context) {
    final Users _users = Provider.of(context);
    return Column(
      children: [
        InkWell(
            child: Padding(
              padding: EdgeInsets.only(top: 9, bottom: 9, left: 2),
              child: ListTile(
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
                title: Text(widget._plant.title),
                subtitle: Wrap(
                  spacing: double.infinity,
                  children: [
                    Text(
                      (widget._plant.situation != true)
                          ? 'Desativada '
                          : 'Ativada ',
                      style: TextStyle(
                          color: (widget._plant.situation != true)
                              ? Colors.red
                              : Colors.green),
                    ),
                    Text(widget._plant.date)
                  ],
                ),
                trailing: Container(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.PLANT_FORM_EDIT,
                            arguments: widget._plant,
                          );
                        },
                        icon: Icon(
                          Icons.edit_outlined,
                          color: Colors.lightGreen,
                        ),
                        splashRadius: 30,
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Excluir cultura?'),
                              content: Text('Tem certeza?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Não'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
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
                              try {
                                await Provider.of<Plants>(context,
                                        listen: false)
                                    .remove(
                                  widget._plant,
                                  _users.byIndex(0).email.replaceAll('.', ':'),
                                );
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
            ),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(AppRoutes.PLANT_INFO, arguments: widget._plant);
            }),
        Divider(),
      ],
    );
  }
}
