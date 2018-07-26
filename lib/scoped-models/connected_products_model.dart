import 'dart:convert';
import 'dart:async';

import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../models/auth.dart';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  User _authenicatedUser;
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
    notifyListeners();
  }

  Future<bool> addProduct(
      String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'http://morningnoonandnight.files.wordpress.com/2007/09/chocolate.jpg',
      'price': price,
      'userEmail': _authenicatedUser.email,
      'userId': _authenicatedUser.id
    };

    return http
        .post(
            'https://flutter-project-70069.firebaseio.com/products.json?auth=${_authenicatedUser.token}',
            body: jsonEncode(productData))
        .then((http.Response response) {
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _isLoading = false;
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: _authenicatedUser.email,
          userId: _authenicatedUser.id);
      _products.add(newProduct);
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    notifyListeners();
    return http
        .get(
            'https://flutter-project-70069.firebaseio.com/products.json?auth=${_authenicatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        _products = fetchedProductList;
        _isLoading = false;
        notifyListeners();
        return;
      }
      productListData.forEach((String productId, dynamic productData) {
        final Product product = Product(
            id: productId,
            title: productData['description'],
            description: productData['description'],
            image: productData['image'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId']);
        fetchedProductList.add(product);
      });
      _products = fetchedProductList;
      _isLoading = false;
      _selProductId = null;
      notifyListeners();
      return;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  void toggleProductFavorite() {
    final bool isCurrentlyFavorite = selectedProduct.isFavorited;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updateProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavorited: newFavoriteStatus);
    _products[selectedProductIndex] = updateProduct;
    _selProductId = null;
    notifyListeners();
  }

  Future<bool> updateProduct(
      String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image':
          'http://morningnoonandnight.files.wordpress.com/2007/09/chocolate.jpg',
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId
    };
    return http
        .put(
            'https://flutter-project-70069.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenicatedUser.token}',
            body: json.encode(updateData))
        .then((http.Response response) {
      _isLoading = false;
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);

      _products[selectedProductIndex] = updatedProduct;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
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
            'https://flutter-project-70069.firebaseio.com/products/${deletedProductId}.json?auth=${_authenicatedUser.token}')
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


/********************************* UserModel *******************************/

class UserModel extends ConnectedProductsModel {
Timer _authTimer;
PublishSubject<bool> _userSubject = PublishSubject();

User get user{
  return _authenicatedUser;
}

PublishSubject<bool> get userSubject{
  return _userSubject;
}

void logout() async {

  _authenicatedUser = null;
  _authTimer.cancel();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('token');
  prefs.remove('userEmail');
  prefs.remove('userId');
  

}

void setAuthTimeout(int time){
  _authTimer = Timer(Duration(seconds: time), (){

    logout();
    _userSubject.add(false);
  });
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
      _authenicatedUser = User(
          id: responseData['localId'],
          email: email,
          token: responseData['idToken']);
          _userSubject.add(true);
          setAuthTimeout(int.parse(responseData['expiresIn']));
          final DateTime now = DateTime.now();
          final DateTime expiryTime = now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
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

  void autoAuthenicate() async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if(token != null){
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTimeString);
      if(parsedExpiryTime.isBefore(now)){
        _authenicatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = prefs.getString('useraEmail');
      final String userId =  prefs.getString('userId');
      final tokenLifeSpan = parsedExpiryTime.difference(now).inSeconds;
      _userSubject.add(true);
      setAuthTimeout(tokenLifeSpan);
      _authenicatedUser = User(id: userId, email: userEmail, token: token );
      notifyListeners();
    }
  }
}

class UtilityModel extends ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
