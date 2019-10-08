import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";

import 'addTask.dart';
import 'auth.dart';
import 'editTask.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onLoggedOut,this.uID});
  final BaseAuth auth;
  final VoidCallback onLoggedOut;
  final String uID;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    //log out
  void _logOut() {
    AlertDialog alertDialog = new AlertDialog(
      content: Container(
        height: 250.0,
        child: new Column(
          children: <Widget>[
            ClipOval(
                child: new Image.asset('asset/logo.PNG',
                    width: 100, height: 100, alignment: Alignment.center)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Log out?",
                style: new TextStyle(fontSize: 16.0),
              ),
            ),
            new Divider(),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    try {
                      await widget.auth.logOut();
                      Navigator.pop(context);
                      widget.onLoggedOut();
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.check, color: Colors.green),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                      ),
                      Text("Yes")
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                      ),
                      Text("Cancle")
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );

    showDialog(context: context, child: alertDialog);
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        floatingActionButton: new FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.purple,
          onPressed: () {
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new AddTask(uid: widget.uID)));
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: new BottomAppBar(
          elevation: 20.0,
          color: Colors.purple,
          child: ButtonBar(
            children: <Widget>[],
          ),
        ),
        appBar: new AppBar(
          title: new Text("Welcome"),
          centerTitle: true,
          actions: <Widget>[
            new FlatButton(
              child: new Icon(Icons.exit_to_app, color: Colors.white,),
              onPressed: _logOut,
            )
          ],
        ),
        body: new Stack(children: <Widget>[
          Center(
            child: new Image.asset(
              'asset/background.jpg',
              width: size.width,
              height: size.height,
              fit: BoxFit.fill,
            ),
          ),
          Center(
            child: StreamBuilder(
              stream: Firestore.instance
                      .collection("task")
                      .where("uid",isEqualTo: widget.uID)
                      .snapshots(),

              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                if (!snapshot.hasData)
                return new Container(child: Center(
                  child: CircularProgressIndicator(),
                ),);

                return new TaskList(document: snapshot.data.documents,);
              },
            ),
          ),
        ]
      )
    );
  }
}

class TaskList extends StatelessWidget {
  TaskList({this.document});
  final List<DocumentSnapshot> document;
  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: document.length,
      itemBuilder: (BuildContext context, int i){
        String title= document[i].data["title"].toString();
        String note= document[i].data["note"].toString();
        DateTime _date= document[i].data["duedate"].toDate();
        String dueDate= "${_date.day}/${_date.month}/${_date.year}";

        return new Dismissible(
          key: new Key(document[i].documentID),
          onDismissed: (direction){
            Firestore.instance.runTransaction((transaction) async {
              DocumentSnapshot snapshot=
              await transaction.get(document[i].reference);
              await transaction.delete(snapshot.reference);
            });

            Scaffold.of(context).showSnackBar(
              new SnackBar(content: new Text("Task Deleted"),)
            );
          },
                  child: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0,right:16.0,bottom: 8.0 ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Expanded(
                    child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(title, style: new TextStyle(fontSize: 24.0,letterSpacing:1.0, fontWeight: FontWeight.bold),),
                        ),
                        new Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Icon(Icons.date_range, color: Colors.purple,),
                            ),
                            Text(dueDate.toString(), style: new TextStyle(fontSize: 18.0,letterSpacing:1.0, color: Colors.red ),),
                          ],
                        ),
                        new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Icon(Icons.note, color: Colors.purple,),
                            ),
                            new Expanded(child: Text(note, style: new TextStyle(fontSize: 20.0,letterSpacing:1.0 ,color: Colors.grey,))),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                new IconButton(
                  icon: Icon(Icons.edit, color: Colors.purple,),
                  onPressed: (){
                    Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new EditTask(
                      title: title,
                      note: note,
                      dueDate: document[i].data["duedate"].toDate() ,
                      index: document[i].reference,
                    )));
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}