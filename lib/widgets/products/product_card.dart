import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../scoped-models/main.dart';
import './price_tag.dart';
import '../ui_elements/title_default.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int productIndex;

  ProductCard(this.product, this.productIndex);
  
  Widget buildTitlePriceRow() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TitleDefault(product.title),
          SizedBox(width: 8.0),
          PriceTag(product.price.toString())
        ],
      ),
    );
  }

  Widget buildDecoratedBox() {
    return DecoratedBox(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(4.0)),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
            child: Column(
              children: <Widget>[
                Text(product.location.address),
                Text(product.userEmail),
              ],
            )));
  }

  Widget buildButtonBar(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget widget, MainModel model) {
        return ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                color: Colors.deepPurple,
                icon: Icon(Icons.info),
                onPressed: () => Navigator.pushNamed<bool>(
                    context, '/product/' + model.allProducts[productIndex].id),
              ),
              IconButton(
                  color: Colors.red,
                  icon: Icon(model.allProducts[productIndex].isFavorited
                      ? Icons.favorite
                      : Icons.favorite_border),
                  onPressed: () {
                    model.selectProduct(model.allProducts[productIndex].id);
                    model.toggleProductFavorite();
                  }),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          FadeInImage(
            image: NetworkImage(product.image),
            height: 300.0,
            fit: BoxFit.cover,
            placeholder: AssetImage('assets/food.jpg'),
          ),
          buildTitlePriceRow(),
          buildDecoratedBox(),
          buildButtonBar(context),
        ],
      ),
    );
  }
}
