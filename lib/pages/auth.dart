import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
   final Map<String, dynamic> _formData = {
     'email': null,
     'password': null,
     'acceptTerms': false,
   };

  BoxDecoration _buildBackgroundImage() {
    return BoxDecoration(
        image: DecorationImage(
      image: AssetImage('assets/background.jpg'),
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
    ));
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
          labelText: 'E-Mail', filled: true, fillColor: Colors.white),
      onSaved: (String value) {
          _formData['email'] = value;
      },
      validator: (String value){

        if(value.isEmpty || !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\."
        "[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)"
        "+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?").hasMatch(value)){
          return 'Email is invalid';
        }
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
          labelText: 'Password', filled: true, fillColor: Colors.white),
      onSaved: (String value) {
          _formData['password'] = value;
      },
      validator: (String value){
        if(value.isEmpty || value.length < 0){
          
          return 'Password is invalid';
        }
      },
    );
  }

  Widget _buildAcceptSwitch() {
    return SwitchListTile(
        value: _formData['acceptTerms'],
        title: Text('Accept Terms'),
        onChanged: (bool value) {
          setState(() {

              _formData['acceptTerms'] = value;     
          });
            
          
        });
  }

  void _submitForm() {
    if(!_formKey.currentState.validate() || !_formData['acceptTerms']){
      
      return;
    }
    _formKey.currentState.save();
    print(_formData);
    Navigator.pushReplacementNamed(context, '/products');
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 500.0 : deviceWidth * 0.95;
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Form(
          key: _formKey,
          child: Container(
          decoration: _buildBackgroundImage(),
          padding: EdgeInsets.all(10.0),
          child: Center(
              child: SingleChildScrollView(
                  child: Container(
                    width: targetWidth,
                      child: Column(
            children: <Widget>[
              _buildEmailTextField(),
              SizedBox(
                height: 10.0,
              ),
              _buildPasswordTextField(),
              _buildAcceptSwitch(),
              SizedBox(
                height: 10.0,
              ),
              RaisedButton(
                textColor: Colors.white,
                child: Text('LOGIN'),
                onPressed: _submitForm,
              ),
            ],
          )))),
        )));
  }
}
