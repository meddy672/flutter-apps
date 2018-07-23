import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped-models/products.dart';
import '../widgets/products/products.dart';

class ProductsPage extends StatelessWidget {
  Widget buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin');
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildSideDrawer(context),
      appBar: AppBar(
        actions: <Widget>[
          ScopedModelDescendant(
            builder:
                (BuildContext context, Widget widget, ProductsModel model) {
              return IconButton(
                icon: Icon(model.displayFavoritesOnly
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () {
                  model.toogleDisplayMode();
                },
              );
            },
          )
        ],
        title: Text('EasyList'),
      ),
      body: Products(),
    );
  }
}
