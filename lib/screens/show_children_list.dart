import 'package:flutter/material.dart';
import 'add_children.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' show get;
import 'dart:convert';
import '../models/user_model.dart';

class ShowChildrenList extends StatefulWidget {
  @override
  _ShowChildrenListState createState() => _ShowChildrenListState();
}

class _ShowChildrenListState extends State<ShowChildrenList>
    with WidgetsBindingObserver {
  String titleAppBar = 'บุตรหลานของ ท่าน';
  int idLogin;
  List<String> idCodeList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    getSharePreferance();
  }

  void getSharePreferance() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    idLogin = sharedPreferences.getInt('id');

    String urlString =
        'http://tscore.ms.ac.th/App/getUserWhereId.php?isAdd=true&id=$idLogin';
    var respense = await get(urlString);
    var result = json.decode(respense.body);

    for (var objJson in result) {
      UserModel userModel = UserModel.fromJson(objJson);
      String idCodeString = userModel.idCode.toString();
      idCodeString = idCodeString.substring(1, ((idCodeString.length) - 1));

      idCodeList = idCodeString.split(',');
      print('idCodeList ==> $idCodeList');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    setState(() {
      _notification = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("_appLiftcycleState ==> $_notification");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(titleAppBar),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[900],
        child: Icon(Icons.group_add),
        onPressed: () {
          print('You click Add');
          var addChildrenRoute = MaterialPageRoute(
              builder: (BuildContext context) => AddChildren());
          Navigator.of(context).push(addChildrenRoute);
        },
      ),
      body: Text('_appLiftcycleState ==> $_notification'),
    );
  }
}
