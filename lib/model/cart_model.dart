
class CartModel{
  String key,name,price,image;
  int quantity;
  double totalPrice;

  CartModel(
      {this.key,
      this.name,
      this.price,
      this.image,
      this.quantity,
      this.totalPrice});

  CartModel.fromJson(Map<String,dynamic> json){
    key = json['key'];
    name = json['name'];
    price = json['price'].toString();
    image = json['image'];
    quantity = json['quantity'] as int;
    totalPrice = double.parse(json['totalPrice'].toString());
  }

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data = new Map<String,dynamic>();
    data['key'] = this.key;
    data['name'] = this.name;
    data['price'] = this.price.toString();
    data['image'] = this.image;
    data['quantity'] = this.quantity;
    data['totalPrice'] = this.totalPrice;

    return data;
  }
}