import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';
import '../models/user.dart';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  User _authenicatedUser;
  int _selProductIndex;

  void addProduct(
      String title, String description, String image, double price) {
    final Product newProduct = Product(
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: _authenicatedUser.email,
        userId: _authenicatedUser.id);
    _products.add(newProduct);
    notifyListeners();
  }
}

class ProductsModel extends ConnectedProductsModel {
  
  
  bool _showFavorites = false;

  List<Product> get allProducts {
    return List.from(_products);
  }

    List<Product> get displayProducts {
      if(_showFavorites){
        return List.from(_products.where((Product product) => product.isFavorited).toList());
      }
    return List.from(_products);
  }

  int get selectedProductIndex {
    return _selProductIndex;
  }

  Product get selectedProduct {
    if (_selProductIndex == null) {
      return null;
    }
    return _products[_selProductIndex];
  }

  bool get displayFavoritesOnly{
    return _showFavorites;
  }

  void selectProduct(int index) {
    _selProductIndex = index;
    notifyListeners();
  }

  void toggleProductFavorite() {
    final bool isCurrentlyFavorite = selectedProduct.isFavorited;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updateProduct = Product(
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavorited: newFavoriteStatus);
        _products[selectedProductIndex] = updateProduct;
        _selProductIndex = null;
        notifyListeners();
  }

  

  void updateProduct(String title, String description, String image, double price) {
        final Product updatedProduct = Product(
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId);
    _products[selectedProductIndex] = updatedProduct;
    
     notifyListeners();
  }

  void toogleDisplayMode(){
    _showFavorites = !_showFavorites;
    notifyListeners();
    
  }

  void deleteProduct(int index) {
    _products.removeAt(selectedProductIndex);
     notifyListeners();
  }
}

class UserModel extends ConnectedProductsModel {
  

  void login(email, password){
    _authenicatedUser = User(id: 'dasjdsd', email: email, password: password);
  }
}