import 'dart:io';

import 'package:cactus_v3/components/snackbar.dart';
import 'package:cactus_v3/models/plant.dart';
import 'package:cactus_v3/models/plant_conf.dart';

import 'package:cactus_v3/provider/plants_provider.dart';
import 'package:cactus_v3/provider/users_provider.dart';
import 'package:cactus_v3/routes/app_routes.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class PlantFormEditPage extends StatefulWidget {
  @override
  _PlantFormEditPageState createState() => _PlantFormEditPageState();
}

class _PlantFormEditPageState extends State<PlantFormEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _ssid = TextEditingController();
  final _pass = TextEditingController();
  final _tempMin = TextEditingController();
  final _tempMax = TextEditingController();

  final Snackbar _snackbar = new Snackbar();
  final PlantConf _plantConf = new PlantConf();
  final Map<String, Object> _formData = {};

  bool _isLoading = false;
  String _imgUrl = '';
  var _myActivity = '';
  String _arduinoUrl = '';

  ImagePicker image = ImagePicker();
  File? file;

  _getImage() async {
    var _image = await image.pickImage(source: ImageSource.gallery);

    setState(() {
      if (_image != null) {
        file = File(_image.path);
      }
    });
  }

  _getImageCamera() async {
    var _image = await image.pickImage(source: ImageSource.camera);

    setState(() {
      if (_image != null) {
        file = File(_image.path);
      }
    });
  }

  Future<String> getFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/arduino_conf.txt';

    return filePath;
  }

  Future<void> saveFile(String code) async {
    File file = File(await getFilePath());
    await file.writeAsString(code);
  }

  void deleteFile() async {
    File file = File(await getFilePath());
    file.delete();
  }

  Future<String> _getCode(
      String userId, String plantId, String ssid, String pass) async {
    String code = '$userId\n' + '$plantId\n' + '$ssid\n' + '$pass\n';

    return code;
  }

  Future<String> updateUploadArduinoFile(String _id, Plant _plant) async {
    try {
      await Provider.of<Plants>(context, listen: false)
          .deleteFileArduino(_plant);
    } catch (e) {
      print('Erro');
    }

    File _file = File(await getFilePath());
    final Users _users = Provider.of(context, listen: false);
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child(_users.byIndex(0).email.toString())
        .child('/plants')
        .child('/$_id')
        .child('/arduino')
        .child('/$_id.txt');

    UploadTask uploadTask = ref.putFile(_file);
    var dowurl = await (await uploadTask).ref.getDownloadURL();
    _arduinoUrl = dowurl.toString();
    return _arduinoUrl;
  }

  void _loadFormData(Plant _plant) {
    // ignore: unnecessary_null_comparison
    if (_plant != null && _formData.isEmpty) {
      _formData['plantId'] = _plant.plantId;
      _formData['title'] = _plant.title;
      _formData['imageUrl'] = _plant.imageUrl;
      _formData['moisMin'] = _plant.moistureMin;
      _formData['moisMax'] = _plant.moistureMax;
      _formData['tempMin'] = _plant.temperatureMin;
      _formData['tempMax'] = _plant.temperatureMax;
      _formData['lightingMin'] = _plant.lightingMin;
      _formData['lightingMax'] = _plant.lightingMax;
      _formData['date'] = _plant.date;
      _formData['arduino'] = _plant.arduino;
      _formData['situation'] = _plant.situation;
      _formData['timer'] = _plant.timer;
      _formData['register'] = _plant.register;
      _formData['ssid'] = _plant.ssid;
      _formData['pass'] = _plant.pass;
    }
  }

  Future<String> _updateUploadFileImg(String _id, Plant _plant) async {
    try {
      await Provider.of<Plants>(context, listen: false).deleteImg(_plant);
    } catch (e) {
      print('Erro');
    }

    final Users _users = Provider.of(context, listen: false);
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child(_users.byIndex(0).email.toString())
        .child('/plants')
        .child('/$_id')
        .child('/img')
        .child('/$_id.jpg');
    UploadTask uploadTask = ref.putFile(file!);
    var dowurl = await (await uploadTask).ref.getDownloadURL();
    _imgUrl = dowurl.toString();
    return _imgUrl;
  }

  @override
  Widget build(BuildContext context) {
    final _plant = ModalRoute.of(context)!.settings.arguments as Plant;
    _loadFormData(_plant);

    final Users _users = Provider.of(context);
    return _isLoading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Editar cultura'),
            ),
            body: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: ListView(
                children: [
                  Form(
                    key: _formKey,
                    child: Builder(
                      builder: (context) => Container(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 40,
                            right: 40,
                            top: 30,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 70,
                                    backgroundImage: (file == null)
                                        ? NetworkImage(_plant.imageUrl)
                                        : FileImage(File(file!.path))
                                            as ImageProvider,
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 90, left: 90),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen,
                                          shape: BoxShape.circle),
                                      child: IconButton(
                                        splashRadius: 30,
                                        icon: Icon(
                                          Icons.camera_alt,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          showModalBottomSheet(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15.0),
                                                    topRight:
                                                        Radius.circular(15.0)),
                                              ),
                                              context: context,
                                              builder: (context) {
                                                return Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    ListTile(
                                                      leading: new Icon(
                                                          Icons.camera_alt),
                                                      title: new Text('Câmera'),
                                                      onTap: () {
                                                        _getImageCamera();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading:
                                                          new Icon(Icons.photo),
                                                      title:
                                                          new Text('Galeria'),
                                                      onTap: () {
                                                        _getImage();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    (file != null)
                                                        ? ListTile(
                                                            leading: new Icon(
                                                              Icons.delete,
                                                              color: Colors
                                                                  .red[300],
                                                            ),
                                                            title: new Text(
                                                                'Remover'),
                                                            onTap: () {
                                                              setState(() {
                                                                file = null;
                                                              });
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          )
                                                        : Container()
                                                  ],
                                                );
                                              });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                maxLength: 40,
                                controller: _title..text = _plant.title,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  labelText: 'Nome da cultura',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Por favor insira um texto';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _formData['title'] = _title.text.trim();
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      maxLength: 6,
                                      controller: _tempMin
                                        ..text =
                                            _plant.temperatureMin.toString(),
                                      decoration: InputDecoration(
                                        labelText: 'Temperatura mín',
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Por favor insira um valor';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _formData['tempMin'] = double.tryParse(
                                            (_tempMin.text.trim())
                                                .replaceAll(',', '.'))!;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      maxLength: 6,
                                      controller: _tempMax
                                        ..text =
                                            _plant.temperatureMax.toString(),
                                      decoration: InputDecoration(
                                        labelText: 'Temperatura máx',
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Por favor insira um valor';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _formData['tempMax'] = double.tryParse(
                                            (_tempMax.text.trim())
                                                .replaceAll(',', '.'))!;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  FormBuilderChoiceChip(
                                    name: 'choice_chip',
                                    focusNode: FocusNode(),
                                    initialValue: _plantConf.defMoistureValue(
                                        _formData['moisMin'] as double,
                                        _formData['moisMax'] as double),
                                    alignment: WrapAlignment.spaceAround,
                                    decoration: InputDecoration(
                                      labelText: 'Umidade do solo',
                                    ),
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Por favor selecione um tipo de umidade';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      _myActivity = value.toString();
                                    },
                                    onSaved: (value) {
                                      if (_myActivity == "1") {
                                        _formData['moisMin'] = 10.0;
                                        _formData['moisMax'] = 20.0;
                                      } else if (_myActivity == "2") {
                                        _formData['moisMin'] = 45.0;
                                        _formData['moisMax'] = 55.0;
                                      } else if (_myActivity == "3") {
                                        _formData['moisMin'] = 60.0;
                                        _formData['moisMax'] = 70.0;
                                      } else if (_myActivity == "4") {
                                        _formData['moisMin'] = 80.0;
                                        _formData['moisMax'] = 100.0;
                                      }
                                    },
                                    options: [
                                      FormBuilderFieldOption(
                                        value: '1',
                                        child: Text('Baixa'),
                                      ),
                                      FormBuilderFieldOption(
                                        value: '2',
                                        child: Text('Média'),
                                      ),
                                      FormBuilderFieldOption(
                                        value: '3',
                                        child: Text('Média-Alta'),
                                      ),
                                      FormBuilderFieldOption(
                                        value: '4',
                                        child: Text('Alta'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  FormBuilderChoiceChip(
                                    name: 'choice_chip',
                                    focusNode: FocusNode(),
                                    initialValue: _plantConf.defLightingValue(
                                        _formData['lightingMin'] as double,
                                        _formData['lightingMax'] as double),
                                    alignment: WrapAlignment.spaceAround,
                                    decoration: InputDecoration(
                                      labelText: 'Iluminação',
                                    ),
                                    validator: (value) {
                                      return null;
                                    },
                                    onChanged: (value) {
                                      _myActivity = value.toString();
                                    },
                                    onSaved: (value) {
                                      if (_myActivity == "1") {
                                        _formData['lightingMin'] = 70.0;
                                        _formData['lightingMax'] = 100.0;
                                      } else if (_myActivity == "2") {
                                        _formData['lightingMin'] = 80.0;
                                        _formData['lightingMax'] = 100.0;
                                      } else if (_myActivity == "3") {
                                        _formData['lightingMin'] = 80.0;
                                        _formData['lightingMax'] = 100.0;
                                      }
                                    },
                                    options: [
                                      FormBuilderFieldOption(
                                        value: '1',
                                        child: Text('Sombra'),
                                      ),
                                      FormBuilderFieldOption(
                                        value: '2',
                                        child: Text('Meia-Sombra'),
                                      ),
                                      FormBuilderFieldOption(
                                        value: '3',
                                        child: Text('Sol pleno'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      maxLength: 40,
                                      controller: _ssid
                                        ..text = _plant.ssid.toString(),
                                      decoration: InputDecoration(
                                        labelText: 'Nome do Wi-fi',
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Por favor insira um valor';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _formData['ssid'] = _ssid.text.trim();
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      maxLength: 40,
                                      controller: _pass
                                        ..text = _plant.pass.toString(),
                                      decoration: InputDecoration(
                                        labelText: 'Senha do Wi-fi',
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Por favor insira um valor';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _formData['pass'] = _pass.text.trim();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 150,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.check_outlined),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if ((_formData['tempMin'] as double) < -50.0 ||
                      (_formData['tempMin'] as double) > 100.0) {
                    _snackbar.snackbarFloat(
                        'O valor da temperatura deve ser maior que -50°C e menor 100°C',
                        context,
                        true);
                  } else if ((_formData['tempMin'] as double) >
                      (_formData['tempMax'] as double)) {
                    _snackbar.snackbarFloat(
                        'O valor mínimo não pode ser maior que o valor máximo!',
                        context,
                        true);
                  } else {
                    setState(() {
                      _isLoading = true;
                    });
                    String _idFolder = _plant.plantId +
                        '-' +
                        _formData['title'].toString().trim();
                    if (file != null) {
                      await _updateUploadFileImg(_idFolder, _plant);
                    }
                    await getFilePath();
                    await saveFile(await _getCode(
                        _users.byIndex(0).email.replaceAll('.', ':'),
                        _formData['plantId'].toString(),
                        _formData['ssid'].toString(),
                        _formData['pass'].toString()));
                    await updateUploadArduinoFile(_idFolder, _plant);

                    await Provider.of<Plants>(context, listen: false).put(
                        Plant(
                          plantId: _formData['plantId'].toString(),
                          title: _formData['title'].toString(),
                          imageUrl: (file != null)
                              ? _imgUrl
                              : _formData['imageUrl'].toString(),
                          moistureMin: _formData['moisMin'] as double,
                          moistureMax: _formData['moisMax'] as double,
                          moisture: 0,
                          temperatureMin: _formData['tempMin'] as double,
                          temperatureMax: _formData['tempMax'] as double,
                          temperature: 0,
                          lightingMin: _formData['lightingMin'] as double,
                          lightingMax: _formData['lightingMax'] as double,
                          lighting: 0,
                          situation: false,
                          arduino: _arduinoUrl,
                          date: _formData['date'].toString(),
                          timer: _formData['timer'] as int,
                          register:
                              _formData['register'] as Map<String, dynamic>,
                          ssid: _formData['ssid'].toString(),
                          pass: _formData['pass'].toString(),
                        ),
                        _users.byIndex(0).email.replaceAll('.', ':'));

                    deleteFile();
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.of(context).pushReplacementNamed(AppRoutes.HOME);
                  }
                }
              },
            ),
          );
  }
}
