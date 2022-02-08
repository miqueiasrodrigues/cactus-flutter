import 'dart:io';
import 'package:cactus_v3/components/snackbar.dart';
import 'package:cactus_v3/models/default.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remove_emoji/remove_emoji.dart';

class CreateNewAccount extends StatefulWidget {
  const CreateNewAccount({Key? key}) : super(key: key);

  @override
  _CreateNewAccountState createState() => _CreateNewAccountState();
}

class _CreateNewAccountState extends State<CreateNewAccount> {
  final Map<String, Object> _formData = {};
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final Snackbar _snackbar = new Snackbar();
  final Default _default = new Default();

  bool _isLoading = false;
  String _imgUrl = '';
  String _nameUser = '';

  CollectionReference _users = FirebaseFirestore.instance.collection('users');
  ImagePicker image = ImagePicker();
  File? file;

  Future<void> _addUser() {
    return _users
        .doc(_formData['email'].toString())
        .set({
          'name': _formData['name'].toString(),
          'email': _formData['email'].toString(),
          'password': _formData['password'].toString(),
          'imageUrl': (_imgUrl == '') ? _default.getUserUrl() : _imgUrl,
          'premium': false,
        })
        .then((value) => print('User Added'))
        .catchError((error) => print('Failed to Add user: $error'));
  }

  Future<void> _setUser() {
    return _users
        .doc(_formData['email'].toString())
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        _snackbar.snackbar('E-mail já cadastrado!', context, true);
        setState(() {
          _isLoading = false;
        });
      } else {
        if (file != null) {
          await _uploadFile();
        }
        setState(() {
          _isLoading = false;
        });
        _addUser();
        _clearFields();

        Navigator.of(context).pop();
        FocusScope.of(context).requestFocus(FocusNode());
        _snackbar.snackbar('Conta cadastrada com sucesso!', context, false);
      }
    });
  }

  Future<String> _uploadFile() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child(_formData['email'].toString())
        .child('/avatar')
        .child('/avatar.jpg');
    UploadTask uploadTask = ref.putFile(file!);
    var dowurl = await (await uploadTask).ref.getDownloadURL();
    _imgUrl = dowurl.toString();
    return _imgUrl;
  }

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

  firstCharacterUpper(String text) {
    List arrayPieces = [];

    String outPut = '';

    text.split(' ').forEach((sepparetedWord) {
      arrayPieces.add(sepparetedWord);
    });

    arrayPieces.forEach((word) {
      word =
          "${word[0].toString().toUpperCase()}${word.toString().substring(1)} ";
      outPut += word;
    });

    return outPut;
  }

  _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _passwordConfirmController.clear();
    file = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 40.0),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 30),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 70,
                                  backgroundImage: (file == null)
                                      ? AssetImage('assets/images/user.png')
                                      : FileImage(
                                          File(file!.path),
                                        ) as ImageProvider,
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
                                                topLeft: Radius.circular(15.0),
                                                topRight: Radius.circular(15.0),
                                              ),
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
                                            });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 30, bottom: 5),
                            child: TextFormField(
                              autofocus: false,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: 'Nome: ',
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.lightGreen,
                                  ),
                                ),
                              ),
                              controller: _nameController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor, digite um nome';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _nameUser =
                                    firstCharacterUpper(_nameController.text);
                                _formData['name'] = _nameUser.removemoji.trim();
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 5.0),
                            child: TextFormField(
                              autofocus: false,
                              decoration: InputDecoration(
                                labelText: 'E-mail: ',
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.lightGreen,
                                  ),
                                ),
                              ),
                              controller: _emailController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor, digite um e-mail';
                                } else if (!value.contains('@')) {
                                  return 'Por favor, digite um e-mail válido';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _formData['email'] = _emailController.text
                                    .trim()
                                    .toUpperCase()
                                    .removemoji;
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 5.0),
                            child: TextFormField(
                              autofocus: false,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Senha: ',
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.lightGreen,
                                  ),
                                ),
                              ),
                              controller: _passwordController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor, digite uma senha';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _formData['password'] =
                                    _passwordController.text.removemoji.trim();
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 5.0),
                            child: TextFormField(
                              autofocus: false,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Confirmar senha: ',
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.lightGreen,
                                  ),
                                ),
                              ),
                              controller: _passwordConfirmController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor, digite uma senha';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _formData['passwordConfirm'] =
                                    _passwordConfirmController.text.removemoji
                                        .trim();
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 30.0, bottom: 40.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                minimumSize: Size(double.infinity, 50),
                              ),
                              onPressed: () async {
                                // Validate returns true if the form is valid, otherwise false.
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  if (_formData['password'] !=
                                      _formData['passwordConfirm']) {
                                    _snackbar.snackbar(
                                        'As senhas digitadas não coincidem!',
                                        context,
                                        true);
                                  } else {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    try {
                                      final result =
                                          await InternetAddress.lookup(
                                              'example.com');
                                      if (result.isNotEmpty &&
                                          result[0].rawAddress.isNotEmpty) {
                                        _setUser();
                                      }
                                    } on SocketException catch (_) {
                                      _snackbar.snackbar(
                                          'Sem internet. Não foi possível conectar-se a rede',
                                          context,
                                          true);
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                }
                              },
                              child: Text('CRIAR SUA CONTA'),
                            ),
                          ),
                          Container(
                            child: TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                _clearFields();
                              },
                              child: Text('VOLTAR'),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
