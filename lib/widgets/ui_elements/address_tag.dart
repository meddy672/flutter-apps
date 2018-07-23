import 'package:flutter/material.dart';

class AddressTag extends StatelessWidget{

  final String address;

  AddressTag(this.address);

  @override
    Widget build(BuildContext context) {
      // TODO: implement build
      return Text(
          address,
          style: TextStyle(
            fontSize: 20.0,
            fontFamily: 'Oswald',
            fontWeight: FontWeight.bold
          ),
        
        );
    }
  
}