import 'dart:io';
import 'package:cactus_v3/models/user.dart';
import 'package:cactus_v3/provider/users_provider.dart';
import 'package:cactus_v3/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  String _imgUrl = '';
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

  Future<String> _updateUploadFileImg(Users _user) async {
    try {
      await Provider.of<Users>(context, listen: false)
          .deleteImg(_user.byIndex(0));
    } catch (e) {
      print('Erro');
    }

    final Users _users = Provider.of(context, listen: false);
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child(_users.byIndex(0).email.toString())
        .child('/avatar')
        .child('/avatar.jpg');
    UploadTask uploadTask = ref.putFile(file!);
    var dowurl = await (await uploadTask).ref.getDownloadURL();
    _imgUrl = dowurl.toString();
    return _imgUrl;
  }

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
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.PROFILE_EDIT);
                  },
                  icon: Icon(Icons.edit_outlined),
                ),
              ],
            ),
            body: Stack(
              children: [
                Column(
                  children: <Widget>[
                    Container(
                      color: Colors.lightGreen,
                      child: Container(
                        width: double.infinity,
                        height: 180.0,
                        child: Container(),
                      ),
                    ),
                  ],
                ),
                Container(
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 190,
                      ),
                      ListTile(
                        title: Text('Nome'),
                        leading: Icon(Icons.person_outline_sharp),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(_users.byIndex(0).name),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('E-mail'),
                        leading: Icon(Icons.email_outlined),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 1,
                              child:
                                  Text(_users.byIndex(0).email.toLowerCase()),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Plano'),
                        leading: Icon(Icons.manage_accounts_outlined),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 1,
                              child: (_users.byIndex(0).premium == false)
                                  ? Text('Grátis')
                                  : Text('Premium'),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundImage: (file == null)
                                ? NetworkImage(_users.byIndex(0).imageUrl)
                                : FileImage(File(file!.path)) as ImageProvider,
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 90, left: 90),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.lightGreen.shade600,
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
                                            topRight: Radius.circular(15.0)),
                                      ),
                                      context: context,
                                      builder: (context) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ListTile(
                                              leading:
                                                  new Icon(Icons.camera_alt),
                                              title: new Text('Câmera'),
                                              onTap: () {
                                                _getImageCamera();
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            ListTile(
                                              leading: new Icon(Icons.photo),
                                              title: new Text('Galeria'),
                                              onTap: () {
                                                _getImage();
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            (file != null)
                                                ? ListTile(
                                                    leading: new Icon(
                                                      Icons.delete,
                                                      color: Colors.red[300],
                                                    ),
                                                    title: new Text('Remover'),
                                                    onTap: () {
                                                      setState(() {
                                                        file = null;
                                                      });
                                                      Navigator.of(context)
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
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: (file != null)
                ? FloatingActionButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      if (file != null) {
                        await _updateUploadFileImg(_users);
                      }
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_users.byIndex(0).email)
                          .set({
                            'name': _users.byIndex(0).name,
                            'email': _users.byIndex(0).email,
                            'password': _users.byIndex(0).password,
                            'imageUrl': _imgUrl,
                            'premium': _users.byIndex(0).premium,
                          })
                          .then((value) => print('OK'))
                          .catchError(
                            (error) => print('Failed to Add user: $error'),
                          );
                      await Provider.of<Users>(context, listen: false).put(
                        User(
                            email: _users.byIndex(0).email,
                            name: _users.byIndex(0).name,
                            password: _users.byIndex(0).password,
                            imageUrl: _imgUrl,
                            premium: _users.byIndex(0).premium),
                      );

                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.done),
                  )
                : null,
          );
  }
}
