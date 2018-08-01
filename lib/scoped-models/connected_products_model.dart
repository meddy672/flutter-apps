import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:mime/mime.dart';

import 'package:http_parser/http_parser.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../models/auth.dart';
import '../models/location_data.dart';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  User _authenticatedUser;
  String _selProductId;
  bool _isLoading = false;
}

class ProductsModel extends ConnectedProductsModel {
  bool _showFavorites = false;

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayProducts {
    if (_showFavorites) {
      return List.from(
          _products.where((Product product) => product.isFavorited).toList());
    }
    return List.from(_products);
  }

  // String get _selectedProductId {
  //   return _selProductId;
  // }

  Product get selectedProduct {
    if (_selProductId == null) {
      return null;
    }
    return _products.firstWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  void selectProduct(String productId) {
    _selProductId = productId;
    if (productId != null) {
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> uploadImage(File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://us-central1-flutter-project-70069.cloudfunctions.net/storeImage'));
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }

    imageUploadRequest.headers['Authorization'] =
        'Bearer ${_authenticatedUser.token}';

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something Went wrong');
        print(json.decode(response.body));
        return null;
      }
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> addProduct(String title, String description, File image,
      double price, LocationData locData) async {
    _isLoading = true;
    notifyListeners();

    final uploadData = await uploadImage(image);
    if (uploadData == null) {
      print('Upload failed');
      return false;
    }

    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
      'imagePath':uploadData['imagePath'],
      'imageUrl':uploadData['imageUrl'],
      'loc_lat': locData.latitude,
      'loc_lng': locData.longitude,
      'loc_address': locData.address
    };

    return http.post(
        'https://flutter-project-70069.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
        body: jsonEncode(productData),
        headers: {
          'Content-Type': 'application/json'
        }).then((http.Response response) {
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      try {
        _isLoading = false;
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Product newProduct = Product(
            id: responseData['name'],
            title: title,
            description: description,
            image: uploadData['imageUrl'],
            imagePath: uploadData['imagePath'],
            price: price,
            location: locData,
            userEmail: _authenticatedUser.email,
            userId: _authenticatedUser.id);
        _products.add(newProduct);
        notifyListeners();
        return true;
      } catch (error) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    });

  }

  Future<Null> fetchProducts({onlyForUser = false}) {
    _isLoading = true;
    notifyListeners();
    return http
        .get(
            'https://flutter-project-70069.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      print(productListData);
      productListData.forEach((String productId, dynamic productData) {
        final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            image: productData['imageUrl'],
            imagePath: productData['imagePath'],
            price: productData['price'],
            location: LocationData(
                address: productData['loc_address'],
                latitude: productData['loc_lat'],
                longitude: productData['loc_lng']),
            userEmail: productData['userEmail'],
            userId: productData['userId'],
            isFavorited: productData['userfavorites'] == null
                ? false
                : (productData['userfavorites'] as Map<String, dynamic>)
                    .containsKey(_authenticatedUser.id));
        fetchedProductList.add(product);
      });
      _products = onlyForUser
          ? fetchedProductList.where((Product product) {
              return product.userId == _authenticatedUser.id;
            }).toList()
          : fetchedProductList;
      _isLoading = false;
      notifyListeners();
      _selProductId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  void toggleProductFavorite() async {
    final bool isCurrentlyFavorite = selectedProduct.isFavorited;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updateProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        imagePath: selectedProduct.imagePath,
        location: selectedProduct.location,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavorited: newFavoriteStatus);
    _products[selectedProductIndex] = updateProduct;
    notifyListeners();
    http.Response response;
    if (newFavoriteStatus) {
      response = await http.put(
          'https://flutter-project-70069.firebaseio.com/products/${selectedProduct.id}/userfavorites/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await http.delete(
          'https://flutter-project-70069.firebaseio.com/products/${selectedProduct.id}/userfavorites/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Product updateProduct = Product(
          id: selectedProduct.id,
          title: selectedProduct.title,
          description: selectedProduct.description,
          price: selectedProduct.price,
          image: selectedProduct.image,
          imagePath: selectedProduct.imagePath,
          location: selectedProduct.location,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId,
          isFavorited: !newFavoriteStatus);
      _products[selectedProductIndex] = updateProduct;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(String title, String description, File image,
      double price, LocationData locData) async{
    _isLoading = true;
    notifyListeners();
    String imageUrl = selectedProduct.image;
    String imagePath = selectedProduct.imagePath;
    if( image != null){

      final uploadData = await uploadImage(image);
      if (uploadData == null) {
        print('Upload failed');
        return false;
      }
      imageUrl = uploadData['imageUrl'];
      imagePath = uploadData['imagePath'];
    }

    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'price': price,
      'loc_lat': locData.latitude,
      'loc_lng': locData.longitude,
      'loc_address': locData.address,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId,
    };
    try{
    final http.Response response = await http.put(
        'https://flutter-project-70069.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
        body: json.encode(updateData),
        headers: {
          'Content-Type': 'application/json'
        });
      _isLoading = false;
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          image: imageUrl,
          imagePath: imagePath,
          price: price,
          location: locData,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
      _products[selectedProductIndex] = updatedProduct;
      notifyListeners();
      return true;
    }
    catch(error){
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  void toogleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }

  Future<bool> deleteProduct(int index) {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    notifyListeners();
    return http
        .delete(
            'https://flutter-project-70069.firebaseio.com/products/${deletedProductId}.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      _selProductId = null;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }
}

////////////////////////////// UserModel //////////////////////////////////

class UserModel extends ConnectedProductsModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }

  Future<Map<String, dynamic>> authenticate(email, password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyA9IVjY-qAZXb5C919YznesR84uHJpBWFI',
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'});
    } else {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyA9IVjY-qAZXb5C919YznesR84uHJpBWFI',
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'});
    }
    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong';

    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authenication succeded';
      _authenticatedUser = User(
          id: responseData['localId'],
          email: email,
          token: responseData['idToken']);
      _userSubject.add(true);
      setAuthTimeout(int.parse(responseData['expiresIn']));
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', responseData['email']);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'The email already exists.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'The password is invalid.';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'The email already exists.';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenicate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      final tokenLifeSpan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifeSpan);
      notifyListeners();
    }
  }
}

class UtilityModel extends ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
