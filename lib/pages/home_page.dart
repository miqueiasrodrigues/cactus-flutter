import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:cactus_v3/components/main_drawer.dart';
import 'package:cactus_v3/pages/dashboard_page.dart';
import 'package:cactus_v3/pages/plant_list_page.dart';
import 'package:cactus_v3/provider/plants_provider.dart';
import 'package:cactus_v3/provider/users_provider.dart';
import 'package:cactus_v3/routes/app_routes.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

late Timer timer;

class _HomePageState extends State<HomePage> {
  Future<void> _refreshPlants(BuildContext context, String userId) {
    return Provider.of<Plants>(context, listen: false).load(userId);
  }

  int _currentTab = 0;
  String _textPage = 'Cactus';

  final PageStorageBucket bucket = PageStorageBucket();
  bool _isLoading = true;

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  void initState() {
    super.initState();

    FlutterDownloader.registerCallback(downloadCallback);
    try {
      timer.cancel();
    } catch (e) {
      print(e);
    }

    try {
      final Users _users = Provider.of(context, listen: false);
      timer = Timer.periodic(
        Duration(seconds: 4),
        (Timer t) => setState(() {
          print('Update');
          _refreshPlants(context, _users.byIndex(0).email.replaceAll('.', ':'));
        }),
      );
      Provider.of<Plants>(context, listen: false)
          .load(_users.byIndex(0).email.replaceAll('.', ':'))
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    } catch (e) {
      print('erro');
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  final PageController controller = PageController(initialPage: 0);

  Widget _currentPage = PlantListPage();
  @override
  Widget build(BuildContext context) {
    final Users _users = Provider.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(_textPage),
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.more_vert_outlined), // add this line
              itemBuilder: (_) => [
                new PopupMenuItem<String>(
                    child: Container(
                      child: Text(
                        "Informações",
                      ),
                    ),
                    value: 'report'),
              ],
              onSelected: (index) async {
                Navigator.of(context).pushNamed(AppRoutes.INFO_PAGE);
              },
            )
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : DoubleBackToCloseApp(
                snackBar: SnackBar(
                  elevation: 2,
                  behavior: SnackBarBehavior.floating,
                  width: 250,
                  duration: Duration(milliseconds: 2000),
                  content: Text('Toque novamente para sair',
                      textAlign: TextAlign.center),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
                child: RefreshIndicator(
                  onRefresh: () => _refreshPlants(
                      context, _users.byIndex(0).email.replaceAll('.', ':')),
                  child: PageStorage(
                    bucket: bucket,
                    child: _currentPage,
                  ),
                ),
              ),
        drawer: MainDrawer(),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Container(
            height: 50,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  splashRadius: 60,
                  icon: Icon(
                    Icons.home_outlined,
                    color: _currentTab == 0 ? Colors.lightGreen : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      try {
                        timer.cancel();
                      } catch (e) {
                        print(e);
                      }
                      _currentPage = PlantListPage();
                      _currentTab = 0;
                      _textPage = 'Cactus';
                      timer = Timer.periodic(
                        Duration(seconds: 8),
                        (Timer t) => setState(() {
                          print('Update');
                          _refreshPlants(context,
                              _users.byIndex(0).email.replaceAll('.', ':'));
                        }),
                      );
                    });
                  },
                ),
                SizedBox(width: 50.0),
                IconButton(
                  splashRadius: 60,
                  icon: Icon(
                    Icons.dashboard_outlined,
                    color: _currentTab == 1 ? Colors.lightGreen : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentPage = DashboardPage();
                      _currentTab = 1;
                      _textPage = 'Dashboard';
                      try {
                        timer.cancel();
                      } catch (e) {
                        print(e);
                      }

                      timer = Timer.periodic(
                        Duration(seconds: 2),
                        (Timer t) => setState(() {
                          print('Update');
                          _refreshPlants(context,
                              _users.byIndex(0).email.replaceAll('.', ':'));
                        }),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).pushNamed(
              AppRoutes.PLANT_FORM,
            );
            setState(() {
              _currentPage = PlantListPage();
              _currentTab = 0;
              _textPage = 'Cactus';
            });
          },
          child: Icon(Icons.add_outlined),
        ));
  }
}
