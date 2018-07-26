import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped-models/main.dart';
import '../models/auth.dart';

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
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;

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
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\."
                    "[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)"
                    "+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Email is invalid';
        }
      },
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
          labelText: 'Confirm Password', filled: true, fillColor: Colors.white),
      validator: (String value) {
        if (_passwordTextController.text != value) {
          return 'Passwords do not match';
        }
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
          labelText: 'Password', filled: true, fillColor: Colors.white),
      controller: _passwordTextController,
      onSaved: (String value) {
        _formData['password'] = value;
      },
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
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

  void _submitForm(Function authenicate) async {
    if (!_formKey.currentState.validate() || !_formData['acceptTerms']) {
      return;
    }
    _formKey.currentState.save();
    Map<String, dynamic> successInformation;
    successInformation =
        await authenicate(_formData['email'], _formData['password'], _authMode);

    if (successInformation['success']) {
      Navigator.pushReplacementNamed(context, '/products');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('An Error Has Occured'),
              content: Text(successInformation['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
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
                              SizedBox(
                                height: 10.0,
                              ),
                              _authMode == AuthMode.Signup
                                  ? _buildConfirmPasswordTextField()
                                  : Container(),
                              _buildAcceptSwitch(),
                              SizedBox(
                                height: 10.0,
                              ),
                              FlatButton(
                                child: Text(
                                    'Switch to ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}'),
                                onPressed: () {
                                  setState(() {
                                    _authMode = _authMode == AuthMode.Login
                                        ? AuthMode.Signup
                                        : AuthMode.Login;
                                  });
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              ScopedModelDescendant<MainModel>(
                                builder: (BuildContext context, Widget widget,
                                    MainModel model) {
                                  return model.isLoading
                                      ? CircularProgressIndicator()
                                      : RaisedButton(
                                          textColor: Colors.white,
                                          child: Text(
                                              _authMode == AuthMode.Login
                                                  ? 'LOGIN'
                                                  : 'SIGNUP'),
                                          onPressed: () =>
                                              _submitForm(model.authenticate),
                                        );
                                },
                              )
                            ],
                          )))),
            )));
  }
}
