import 'dart:io';

import 'package:cactus_v3/components/snackbar.dart';
import 'package:cactus_v3/models/user.dart';
import 'package:cactus_v3/provider/users_provider.dart';
import 'package:cactus_v3/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Map<String, Object> _formData = {};
  final Snackbar _snackbar = new Snackbar();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  CollectionReference _users = FirebaseFirestore.instance.collection('users');

  Future<void> _getUser() {
    return _users
        .doc(_formData['email'].toString())
        .get()
        .then((DocumentSnapshot snapshot) async {
      if (!snapshot.exists) {
        setState(() {
          _isLoading = false;
        });
        _snackbar.snackbar('E-mail não cadastrado!', context, true);
      } else if ((snapshot.id.toString() == _formData['email']) &&
          ((snapshot.data() as Map<String, dynamic>)['password'].toString() !=
              _formData['password'])) {
        setState(() {
          _isLoading = false;
        });
        _snackbar.snackbar('E-mail e senha não coincidem!', context, true);
      } else if ((snapshot.id.toString() == _formData['email']) &&
          ((snapshot.data() as Map<String, dynamic>)['password'].toString() ==
              _formData['password'])) {
        final Users _users = Provider.of(context, listen: false);
        _users.put(User(
          email: _formData['email'].toString(),
          name: (snapshot.data() as Map<String, dynamic>)['name'].toString(),
          password: _formData['password'].toString(),
          premium: (snapshot.data() as Map<String, dynamic>)['premium'],
          imageUrl:
              (snapshot.data() as Map<String, dynamic>)['imageUrl'].toString(),
        ));

        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacementNamed(AppRoutes.HOME);
        _clearFields();
      } else {
        setState(() {
          _isLoading = false;
        });
        _snackbar.snackbar(
            'Ocorreu um erro inesperado. Tente novamente mais tarde',
            context,
            true);
      }
    });
  }

  _clearFields() {
    _emailController.clear();
    _passwordController.clear();
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
            : DoubleBackToCloseApp(
                snackBar: SnackBar(
                  duration: Duration(milliseconds: 2000),
                  content: Text('Toque novamente para sair'),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 40.0, vertical: 40.0),
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 60.0, bottom: 30.0),
                              width: 180,
                              height: 200,
                              child: Image.asset('assets/images/cactus_2.png'),
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
                                      .toUpperCase();
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
                                      _passwordController.text;
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
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    _formKey.currentState!.save();
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    try {
                                      final result =
                                          await InternetAddress.lookup(
                                              'example.com');
                                      if (result.isNotEmpty &&
                                          result[0].rawAddress.isNotEmpty) {
                                        _getUser();
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
                                },
                                child: Text('ENTRAR'),
                              ),
                            ),
                            Container(
                              child: TextButton(
                                onPressed: () async {
                                  Navigator.of(context)
                                      .pushNamed(AppRoutes.CREATE_ACCOUNT);
                                  _clearFields();
                                },
                                child: Text('CRIAR SUA CONTA'),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
