import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';

class ProductsModel extends Model {
  List<Product> _products = [];
  int _selectedProductIndex;
  bool _showFavorites = false;

  List<Product> get products {
    return List.from(_products);
  }

    List<Product> get displayProducts {
      if(_showFavorites){
        return List.from(_products.where((Product product) => product.isFavorited).toList());
      }
    return List.from(_products);
  }

  int get selectedProductIndex {
    return _selectedProductIndex;
  }

  Product get selectedProduct {
    if (_selectedProductIndex == null) {
      return null;
    }
    return _products[_selectedProductIndex];
  }

  bool get displayFavoritesOnly{
    return _showFavorites;
  }

  void selectProduct(int index) {
    _selectedProductIndex = index;
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
        isFavorited: newFavoriteStatus);
        _products[_selectedProductIndex] = updateProduct;
        _selectedProductIndex = null;
        notifyListeners();
  }

  void addProduct(Product product) {
    _products.add(product);
    _selectedProductIndex = null;
     notifyListeners();
  }

  void updateProduct(Product product) {
    _products[_selectedProductIndex] = product;
    _selectedProductIndex = null;
     notifyListeners();
  }

  void toogleDisplayMode(){
    _showFavorites = !_showFavorites;
    notifyListeners();
    _selectedProductIndex = null;
  }

  void deleteProduct(int index) {
    _products.removeAt(_selectedProductIndex);
    _selectedProductIndex = null;
     notifyListeners();
  }
}
