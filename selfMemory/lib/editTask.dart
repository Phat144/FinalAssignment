import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class EditTask extends StatefulWidget {
  EditTask({this.title,this.dueDate,this.note,this.index});
  final String title;
  final String note;
  final DateTime dueDate;
  final index;
  @override
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {

  TextEditingController titleController;
  TextEditingController noteController;

  DateTime _dueDate;
  String _dateText = "";

  String newTask="";
  String note="";
  

  Future<Null> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _dueDate,
        firstDate: DateTime(2019),
        lastDate: DateTime(2080));

    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dateText = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _dueDate= widget.dueDate;
    _dateText = "${_dueDate.day}/${_dueDate.month}/${_dueDate.year}";

    newTask= widget.title;
    note= widget.note;
  
    titleController= new TextEditingController(text: widget.title);
    noteController= new TextEditingController(text: widget.note);

  }

  void _updateTask(){
    Firestore.instance.runTransaction((Transaction transaction) async{
      DocumentSnapshot snapshot=
      await transaction.get(widget.index);
      await transaction.update(snapshot.reference, {
        "title" : newTask,
        "note" : note,
        "duedate" : _dueDate
      });
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      child: Column(
        children: <Widget>[
          Container(
            height: 200.0,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("asset/bg.jpg"), fit: BoxFit.cover),
                color: Colors.purple),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "My Notes",
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 40.0,
                    letterSpacing: 2.0,
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text("Edit Task",
                      style:
                          new TextStyle(fontSize: 24.0, color: Colors.white)),
                ),
                Icon(Icons.list, color: Colors.white, size: 30.0)
              ],
            ),
          ),
          new Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: titleController,
              onChanged: (String str){
                setState(() {
                 newTask=str; 
                });
              },
              decoration: new InputDecoration(
                  icon: Icon(Icons.dashboard),
                  hintText: "Edit task",
                  border: InputBorder.none),
              style: new TextStyle(fontSize: 22.0, color: Colors.black),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.all(16.0),
            child: new Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: new Icon(Icons.date_range),
                ),
                new Expanded(
                  child: Text(
                    "Due Date",
                    style: new TextStyle(fontSize: 22.0, color: Colors.black),
                  ),
                ),
                new FlatButton(
                  onPressed: () => _selectDueDate(context),
                  child: Text(_dateText, style: new TextStyle(fontSize: 22.0, color: Colors.black)),
                )
              ],
            ),
          ),
          new Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: noteController,
              onChanged: (String str){
                setState(() {
                 note=str; 
                });
              },
              decoration: new InputDecoration(
                  icon: Icon(Icons.note),
                  hintText: "Take Note",
                  border: InputBorder.none),
              style: new TextStyle(fontSize: 22.0, color: Colors.black),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.check, size: 40.0, color: Colors.green,),
                  onPressed: (){
                   _updateTask();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 40.0,color: Colors.red),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
