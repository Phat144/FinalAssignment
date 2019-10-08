import 'package:flutter/material.dart';
import 'auth.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onLoggedIn, this.userID});
  final BaseAuth auth;
  final VoidCallback onLoggedIn;
  String userID;
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType {
  login,
  register
}

class _LoginPageState extends State<LoginPage>{
  String _email;
  String _password;
  FormType _formType= FormType.login;
  final formKey= new GlobalKey<FormState>();

  bool validateAndSave(){
    final form= formKey.currentState;
    if (form.validate()){
      form.save();
      return true;
    }
    return false;
  }

  Future<void> validateAndSubmit() async {
    if (validateAndSave()){
      try{
        if (_formType == FormType.login){
          try{
            widget.userID = await widget.auth.signInWithEmailAndPassword(_email, _password);
            if (widget.userID != null){
            print ("Hello "+ widget.userID);
            widget.onLoggedIn();}
            else if (widget.userID==null){
              return Scaffold.of(context).showSnackBar(
                new SnackBar(content: new Text("Wrong Password or Email!"),)
              );
            }
          }
          catch (e){
            print(e);
          }
        }
        else {
          try{
          widget.userID= await widget.auth.createUserWithEmailAndPassword(_email, _password);
          //FirebaseUser user= (await _auth.createUserWithEmailAndPassword(email: _email, password: _password)).user;
          print ("Hello" + widget.userID);
          widget.onLoggedIn();
          }
          catch(e){
            print(e);
          }
        }
        
      }
      catch (e){
        print ("Error: $e");
      }
    }
  }

  void moveToRegister(){
    formKey.currentState.reset();
    setState(() {
      _formType= FormType.register;
    });
  }

  void moveToLogin(){
    setState(() {
      _formType= FormType.login;
    });
  }

  void clearInput(){
    formKey.currentState.reset();
  }
  @override
  Widget build(BuildContext context) {
    if (_formType == FormType.login){
      return new Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: new AppBar(
          title: new Text('Login Page'),
          centerTitle: true,
        ),
        body:       
        new Container(
          padding: EdgeInsets.all(16.0),
          child:    
          new Form(
            key: formKey,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              verticalDirection: VerticalDirection.down,
              children:             
              buildInputs() + buildSubmitButtons(),
            ),
          ),
        ),
      );
    }
    else {
      return new Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: new AppBar(
          title: new Text('Register Page'),
          centerTitle: true,
        ),
        body:       
        new Container(
          padding: EdgeInsets.all(16.0),
          child:    
          new Form(
            key: formKey,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              verticalDirection: VerticalDirection.down,
              children:             
              buildInputs() + buildSubmitButtons(),
            ),
          ),
        ),
      );
    }
  }
  List<Widget> buildInputs() {
    return [
      new Container(
        padding: EdgeInsets.all(10),
        child:
        Image.asset('asset/logo.PNG', width: 100, height: 100, alignment: Alignment.center),      
      ), 
      new TextFormField(
          decoration: new InputDecoration(labelText: 'Email'),
          validator: (value) => value.isEmpty ? 'Please enter email!' : null,
          onSaved: (value) => _email= value,
        ),
        new TextFormField(
          decoration: new InputDecoration(labelText: "Password"),
          obscureText: true,
          validator: (value) => value.isEmpty ? 'Please enter password!' : null,
          onSaved: (value) => _password= value,
        ),
    ];
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login){
      return [
        new RaisedButton(
          color: Colors.deepPurple,
          child: new Text(
            "Login", style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: validateAndSubmit,
        ),
        new RaisedButton(
          color: Colors.deepPurple,
          child: new Text(
            "Clear", style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: clearInput,
        ),
        new FlatButton(
          child: new Text("Create new Account!", style: new TextStyle(fontSize: 20.0,color: Colors.blue, fontWeight: FontWeight.bold)),
          onPressed: moveToRegister,
        )
    ];
    } else {
      return [
        new RaisedButton(
          color: Colors.deepPurple,
          child: new Text(
            "Create Account", style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: validateAndSubmit,
        ),
        new RaisedButton(
          color: Colors.deepPurple,
          child: new Text(
            "Clear", style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: clearInput,
        ),
        new FlatButton(
          child: new Text("Have an account? Login", style: new TextStyle(fontSize: 20.0, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          onPressed: moveToLogin,
        )
      ];
    }
  }
}