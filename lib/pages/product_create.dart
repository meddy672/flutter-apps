import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped-models/main.dart';
import '../widgets/form_inputs/location.dart';
import '../widgets/helpers/ensure_visible.dart';
import '../models/product.dart';
import '../models/location_data.dart';
import '../widgets/form_inputs/image.dart';

class ProductCreatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductCreatePageState();
  }
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': null,
    'location': null
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _titleTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();


  Widget _buildTitleTextField(Product product) {
    if(product == null && _titleTextController.text.trim() == ''){
      _titleTextController.text = '';
    }else if(product != null && _titleTextController.text.trim() == ''){
      _titleTextController.text = product.title;
    }else if(product != null && _titleTextController.text.trim() != ''){
      _titleTextController.text = _titleTextController.text;
    }else if(product == null && _titleTextController.text.trim() != ''){
      _titleTextController.text = _titleTextController.text;
    }else{
      _titleTextController.text = '';
    }
    return EnsureVisibleWhenFocused(
        focusNode: _titleFocusNode,
        child: TextFormField(
          focusNode: _titleFocusNode,
          decoration: InputDecoration(labelText: 'Product Title'),
          controller: _titleTextController,
         // initialValue: product == null ? '' : product.title,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Title is required';
            }
          },
          onSaved: (String value) {
            _formData['title'] = value;
          },
        ));
  }

  Widget _buildDescriptionTextField(Product product) {
    if(product == null && _descriptionTextController.text.trim() == ''){
      _descriptionTextController.text = '';
    }else if(product != null && _descriptionTextController.text.trim() == ''){
      _descriptionTextController.text = product.description;
    }
    return EnsureVisibleWhenFocused(
        focusNode: _descriptionFocusNode,
        child: TextFormField(
          focusNode: _descriptionFocusNode,
          decoration: InputDecoration(labelText: 'Product Description'),
          controller: _descriptionTextController,
          maxLines: 4,
          //initialValue: product == null ? '' : product.description,
          validator: (String value) {
            if (value.isEmpty || value.length < 10) {
              return 'Description is required and must be at least 10 characters.';
            }
          },
          onSaved: (String value) {
            //_formData['description'] = value;
          },
        ));
  }

  Widget _buildPriceTextField(Product product) {



    return EnsureVisibleWhenFocused(
        focusNode: _priceFocusNode,
        child: TextFormField(
          focusNode: _priceFocusNode,
          decoration: InputDecoration(labelText: 'Product Price'),
          keyboardType: TextInputType.number,
          //initialValue: product == null ? '' : product.price.toString(),
          validator: (String value) {
            if (value.isEmpty ||
                !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$').hasMatch(value)) {
              return 'Price is required';
            }
          },
          onSaved: (String value) {
            _formData['price'] = double.parse(value);
          },
        ));
  }

  Widget _buildSubmitButton(Product product) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                textColor: Colors.white,
                child: Text('Save'),
                onPressed: () => _createProduct(
                    model.addProduct,
                    model.updateProduct,
                    model.selectProduct,
                    model.selectedProductIndex
                    ),
              );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
            width: targetWidth,
            margin: EdgeInsets.all(10.0),
            child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
                  children: <Widget>[
                    _buildTitleTextField(product),
                    _buildDescriptionTextField(product),
                    _buildPriceTextField(product),
                    SizedBox(
                      height: 10.0,
                    ),
                    LocationInput(_setLocation, product),
                    SizedBox(height: 10.0,),
                    ImageInput(_setImage, product),
                    SizedBox(height: 10.0,),
                    _buildSubmitButton(product),
                  ],
                ))));
  }

  void _setLocation(LocationData locaData){

    _formData['location'] = locaData;
  }

  void _setImage(File image){

    _formData['image'] = image;
  }

  void _createProduct(
      Function addProduct, Function updateProduct, Function setSelectedProduct,
      [int selectedProductIndex]) {
    if (!_formKey.currentState.validate() || (_formData['image'] == null && selectedProductIndex == -1)) {
      
      return;
    }
    _formKey.currentState.save();
    if (selectedProductIndex == -1) {
      addProduct(
        _titleTextController.text,
        _descriptionTextController.text,
        _formData['image'],
        _formData['price'],
        _formData['location']
        ).then((bool success) {
          if(success){
           Navigator
            .pushReplacementNamed(context, '/products')
            .then((_) => setSelectedProduct(null));
          }
          else{
            showDialog(context: context, builder: (BuildContext context){
              return AlertDialog(title: Text('Something Went Wrong'), content: Text('Please try again'), actions: <Widget>[
                FlatButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: Text('Okay'),)
              ],);
            });
          }
        });
    } else {
      updateProduct(
        _titleTextController.text,
        _descriptionTextController.text,
        _formData['image'],
        _formData['price'],
        _formData['location']
        ).then((bool success) {
          if(success){
           Navigator
            .pushReplacementNamed(context, '/products')
            .then((_) => setSelectedProduct(null));
          }
          else{
            showDialog(context: context, builder: (BuildContext context){
              return AlertDialog(title: Text('Something Went Wrong'), content: Text('Please try again'), actions: <Widget>[
                FlatButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: Text('Okay'),)
              ],);
            });
          }
        });
    }

 
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedProduct);
        return model.selectedProductIndex == -1
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit Product'),
                ),
                body: pageContent,
              );
      },
    );
  }
}
