import 'package:cactus_v3/pages/home_page.dart';
import 'package:cactus_v3/provider/users_provider.dart';
import 'package:cactus_v3/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  Widget _createItem(IconData icon, String label, Function() onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Users _users = Provider.of(context);
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: (_users.byIndex(0).premium == true)
                ? Row(
                    children: [
                      Text(_users.byIndex(0).name),
                      Icon(
                        Icons.star_rate_rounded,
                        color: Colors.yellow,
                        size: 15,
                      )
                    ],
                  )
                : Text(_users.byIndex(0).name),
            accountEmail: Text(_users.byIndex(0).email.toLowerCase()),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(_users.byIndex(0).imageUrl),
              radius: 50.0,
              backgroundColor: Colors.white60,
            ),
          ),
          _createItem(
            Icons.person_outline_sharp,
            'Minha Conta',
            () {
              Navigator.pushNamed(context, AppRoutes.PROFILE);
            },
          ),
          Divider(),
          _createItem(
            Icons.help_outline,
            'Ajuda',
            () {
              Navigator.pushNamed(context, AppRoutes.HELP);
            },
          ),
          _createItem(
            Icons.logout_outlined,
            'Sair',
            () {
              Future.delayed(Duration(milliseconds: 250), () {
                try {
                  timer.cancel();
                } catch (e) {
                  print(e);
                }
                Navigator.pushReplacementNamed(context, AppRoutes.LOGIN);
              });
            },
          ),
        ],
      ),
    );
  }
}
