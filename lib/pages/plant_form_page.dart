import 'dart:io';
import 'package:cactus_v3/components/snackbar.dart';
import 'package:cactus_v3/models/default.dart';
import 'package:cactus_v3/models/plant.dart';

import 'package:cactus_v3/provider/plants_provider.dart';
import 'package:cactus_v3/provider/users_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class PlantFormPage extends StatefulWidget {
  @override
  _PlantFormPageState createState() => _PlantFormPageState();
}

class _PlantFormPageState extends State<PlantFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _ssid = TextEditingController();
  final _pass = TextEditingController();
  final _tempMin = TextEditingController();
  final _tempMax = TextEditingController();
  final Snackbar _snackbar = new Snackbar();
  final Default _default = new Default();
  final Map<String, Object> _formData = {};

  bool _isLoading = false;
  String _imgUrl = '';
  String _arduinoUrl = '';
  String _idFolder = '';

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

  Future<String> uploadArduinoFile(String _id) async {
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

  Future<String> _getCode(
      String userId, String plantId, String ssid, String pass) async {
    String code = '$userId\n' + '$plantId\n' + '$ssid\n' + '$pass\n';

    return code;
  }

  Future<String> _uploadFileImg(String _id) async {
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

  var _myActivity = '';

  @override
  Widget build(BuildContext context) {
    final Users _users = Provider.of(context);
    return _isLoading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Cadastrar cultura'),
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
                                        ? NetworkImage(_default.getPlantUrl())
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
                                                mainAxisSize: MainAxisSize.min,
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
                                                    title: new Text('Galeria'),
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
                                                            color:
                                                                Colors.red[300],
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
                                            },
                                          );
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
                                controller: _title,
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
                                      controller: _tempMin,
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
                                      controller: _tempMax,
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
                              SizedBox(
                                height: 10,
                              ),
                              Column(
                                children: [
                                  FormBuilderChoiceChip(
                                    name: 'choice_chip',
                                    focusNode: FocusNode(),
                                    alignment: WrapAlignment.spaceAround,
                                    decoration: InputDecoration(
                                      labelText: 'Iluminação',
                                    ),
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Por favor selecione um tipo de iluminação';
                                      }
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
                                        _formData['lightingMin'] = 85.0;
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
                                      controller: _ssid,
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
                                      controller: _pass,
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
                  _idFolder = _default.getId() +
                      '-' +
                      _formData['title'].toString().trim();
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
                    if (file != null) {
                      await _uploadFileImg(_idFolder);
                    }

                    await Provider.of<Plants>(context, listen: false).put(
                      Plant(
                        plantId: Provider.of<Plants>(context, listen: false)
                            .returnId(),
                        title: _formData['title'].toString(),
                        imageUrl:
                            (file != null) ? _imgUrl : _default.getPlantUrl(),
                        moistureMin: _formData['moisMin'] as double,
                        moistureMax: _formData['moisMax'] as double,
                        temperatureMin: _formData['tempMin'] as double,
                        temperatureMax: _formData['tempMax'] as double,
                        temperature: 0,
                        lightingMin: _formData['lightingMin'] as double,
                        lightingMax: _formData['lightingMax'] as double,
                        lighting: 0,
                        arduino: '',
                        date: DateFormat('dd-MM-yyyy hh:mm:ss a')
                            .format(DateTime.now())
                            .toString(),
                        situation: false,
                        timer: 0,
                        register: {},
                        ssid: _formData['ssid'].toString(),
                        pass: _formData['pass'].toString(),
                      ),
                      _users.byIndex(0).email.replaceAll('.', ':'),
                    );

                    await getFilePath();
                    await saveFile(await _getCode(
                        _users.byIndex(0).email.replaceAll('.', ':'),
                        Provider.of<Plants>(context, listen: false).returnId(),
                        _formData['ssid'].toString(),
                        _formData['pass'].toString()));
                    await uploadArduinoFile(_idFolder);
                    deleteFile();

                    await Provider.of<Plants>(context, listen: false).put(
                      Plant(
                        plantId: Provider.of<Plants>(context, listen: false)
                            .returnId(),
                        title: _formData['title'].toString(),
                        imageUrl:
                            (file != null) ? _imgUrl : _default.getPlantUrl(),
                        moistureMin: _formData['moisMin'] as double,
                        moistureMax: _formData['moisMax'] as double,
                        temperatureMin: _formData['tempMin'] as double,
                        temperatureMax: _formData['tempMax'] as double,
                        temperature: 0,
                        lightingMin: _formData['lightingMin'] as double,
                        lightingMax: _formData['lightingMax'] as double,
                        lighting: 0,
                        arduino: _arduinoUrl,
                        date: DateFormat('dd-MM-yyyy hh:mm:ss a')
                            .format(DateTime.now())
                            .toString(),
                        situation: false,
                        timer: 0,
                        register: {},
                        ssid: _formData['ssid'].toString(),
                        pass: _formData['pass'].toString(),
                      ),
                      _users.byIndex(0).email.replaceAll('.', ':'),
                    );

                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          );
  }
}
