
import 'package:flutter/cupertino.dart';

class DrinkModel{

  String key,name,price,image;

  DrinkModel({this.key, this.name, this.price, this.image});
  DrinkModel.fromJson(Map<String,dynamic> json)
  {
    key = json['key'];
    name = json['name'];
    price = json['price'];
    image = json['image'];
  }

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data = new Map<String,dynamic>();
    data['key'] = this.key;
    data['name'] = this.name;
    data['price'] = this.price;
    data['image'] = this.image;
  }
}