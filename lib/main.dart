import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:launcher_assist/launcher_assist.dart';
import 'package:simple_permissions/simple_permissions.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: MyHomePage(title: 'Flutter Laucher'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var wallpaper;

  _getList() async {
    List<dynamic> apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: true,
        onlyAppsWithLaunchIntent: true);
    return Container(
      child: ListView.builder(
        itemCount: apps.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(apps.elementAt(index).appName),
            leading: Image.memory(
              apps.elementAt(index).icon,
              height: 40,
            ),
            onTap: () {
              DeviceApps.openApp(apps.elementAt(index).packageName);
            },
          );
        },
      ),
    );
  }

  @override
  initState() {
    super.initState();
    LauncherAssist.getWallpaper().then((image) {
      setState(() {
        wallpaper = image;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    requestPermission();
    return Scaffold(
        body: Stack(
      children: <Widget>[
        wallpaper != null
            ? Image.memory(
                wallpaper,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              )
            : Center(),
        FutureBuilder(
          future: _getList(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data;
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ],
    ));
  }

  requestPermission() async {
    if (await SimplePermissions.getPermissionStatus(
            Permission.ReadExternalStorage) !=
        PermissionStatus.authorized) {
      await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
    }
  }
}
