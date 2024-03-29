import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/news_model.dart';
import '../listviews/news_listview.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/noti_model.dart';
import './show_notification.dart';
import './show_children_list.dart';
import './add_children.dart';
import './authen.dart';

class ShowNewsList extends StatefulWidget {
  @override
  _ShowNewsListState createState() => _ShowNewsListState();
}

class _ShowNewsListState extends State<ShowNewsList> {
  String titleAppbar = 'ข่าวสาร น่ารู้';
  String titleTooltip = 'ออกจากผู้ใช้';
  String titleNotification = 'ข้อความจาก มาลี';

  String urlJson = 'http://tscore.ms.ac.th/App/getAllNews.php';
  List<NewsModel> newModels = [];
  List<NotiModel> notiModels = [];

  String myToken;
  String textValue = 'Show News List';
  bool rememberBool;
  int idLoginInt;
  String typeString;

  //  Abour Firebase
  FirebaseMessaging firebaseMessageing = new FirebaseMessaging();

  SharedPreferences sharePreferances;

  @override
  void initState() {
    // Get Data From Json for Create ListView
    getAllDataFromJson();

    // Load Config Setting from SharePreferance
    getCredectial();

    firebaseMessageing.configure(onLaunch: (Map<String, dynamic> msg) {
      print('onLaunch Call: ==> $msg');
      setState(() {
        var notimodel = NotiModel.fromDATA(msg);
        notiModels.add(notimodel);
      });
    }, onResume: (Map<String, dynamic> msg) {
      setState(() {
        setState(() {
          print('onResume Call: ==> $msg');
          var notiModel = NotiModel.fromOBJECT(msg);
          _showDialog(notiModel.title.toString(), notiModel.body.toString());
        });
      });
    }, onMessage: (Map<String, dynamic> msg) {
      setState(() {
        print('onMessage Call: ==> $msg');
        var notiModel = NotiModel.fromOBJECT(msg);
        _showDialog(notiModel.title.toString(), notiModel.body.toString());
      });
    });

    firebaseMessageing.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));

    firebaseMessageing.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('Ios Setting Registed');
    });

    // Find Token
    firebaseMessageing.getToken().then((token) {
      myToken = token;
      print('myToken ==>>> $myToken');
      updateToken(token);
    });
  } // initial

  void _showDialog(String title, String message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void getAllDataFromJson() async {
    var response = await http.get(urlJson);
    var result = json.decode(response.body);
    // print(result);
    setState(() {
      for (var objJson in result) {
        newModels.add(NewsModel.fromJSON(objJson));
      }
    });
  }

  void getCredectial() async {
    sharePreferances = await SharedPreferences.getInstance();
    setState(() {
      rememberBool = sharePreferances.getBool('Remember');
      idLoginInt = sharePreferances.getInt('id');
      typeString = sharePreferances.getString('Type');
     print('idLoginInt ==> $idLoginInt, currentToken ==> $myToken');
    });
  }

  void updateToken(String token) async{
    String currentToken = token;
    String urlPHP = 'http://tscore.ms.ac.th/App/editTokenMariaWhereId.php?isAdd=true&id=$idLoginInt&Token=$currentToken';
    var response = await http.get(urlPHP);
    var result = json.decode(response.body);
    print('result edit Token ==> ' + result.toString());
    
    
  }

  Widget exitApp() {
    return IconButton(
      tooltip: titleTooltip,
      icon: Icon(Icons.close),
      onPressed: () {
        exit(0);
      },
    );
  }

  Widget menuDrawer(BuildContext context) {
    String titleH1 = 'โรงเรียนมารีย์อนุสรณ์';
    String titleH2 = 'อำเภอเมือง จังหวัดบุรีรัมย์';
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue[300]),
            child: Container(
              padding: EdgeInsets.only(top: 10.0),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 70.0,
                    height: 70.0,
                    child: Image.asset('images/logo1.png'),
                  ),
                  Text(
                    titleH1,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    titleH2,
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.child_friendly,
              color: Colors.blue,
              size: 48.0,
            ),
            title: Text(
              'บุตรหลานของ ท่าน',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800]),
            ),
            subtitle: Text(
              'ดูบุตรหลาน ที่อยู่ในการดูแลของท่านผู้ปกครอง',
              style: TextStyle(color: Colors.blue[600]),
            ),
            onTap: () {
              print('Click Memu1');
              var showChildrenListRoute = MaterialPageRoute(
                  builder: (BuildContext context) => ShowChildrenList());
              Navigator.of(context).pop();
              Navigator.of(context).push(showChildrenListRoute);
            },
          ),
          ListTile(
            title: Text(
              'เพิ่ม บุตร หลาน ของท่าน',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800]),
            ),
            subtitle: Text(
              'เพิ่มบุตรหลาน ที่อยู่ในการดูแลของท่านผู้ปกครอง',
              style: TextStyle(color: Colors.blue[600]),
            ),
            leading: Icon(
              Icons.group_add,
              color: Colors.blue,
              size: 48.0,
            ),
            onTap: () {
              var addChildrenRoute = MaterialPageRoute(
                  builder: (BuildContext context) => AddChildren());
              Navigator.of(context).pop();
              Navigator.of(context).push(addChildrenRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.sync, size: 48.0, color: Colors.blue),
            title: Text(
              'Log Out',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800]),
            ),
            subtitle: Text(
              'การออกจาก User นี่ เพื่อ Login ใหม่',
              style: TextStyle(color: Colors.blue[600]),
            ),
            onTap: () {
              clearSharePreferance(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.close,
              size: 48.0,
              color: Colors.blue,
            ),
            title: Text(
              'ออกจาก Application',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800]),
            ),
            subtitle: Text(
              'ออกจาก App แต่ยังจดจำ User',
              style: TextStyle(color: Colors.blue[600]),
            ),
            onTap: () {
              exit(0);
            },
          )
        ],
      ),
    );
  }

  void clearSharePreferance(BuildContext context) async {
    sharePreferances = await SharedPreferences.getInstance();
    setState(() {
      sharePreferances.clear();
      print('Remember ===>> ${sharePreferances.getBool('Remember')}');
      if (sharePreferances.getBool('Remember') == null) {
        var backHomeRoute =
            MaterialPageRoute(builder: (BuildContext context) => Authen());
        Navigator.of(context)
            .pushAndRemoveUntil(backHomeRoute, (Route<dynamic> route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(titleAppbar),
        actions: <Widget>[exitApp()],
      ),
      body: NewsListView(newModels),
      drawer: menuDrawer(context),
    );
  }
}
