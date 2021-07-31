import 'dart:convert';

import 'package:app_one/model/cart_model.dart';
import 'package:app_one/model/drink_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void addToCart(GlobalKey<ScaffoldState> scaffoldKey, DrinkModel drinkModel) {
  var cart = FirebaseDatabase.instance
      .reference()
      .child('Cart')
      .child('UNIQUE_USER_ID');
  cart.child(drinkModel.key).once().then((DataSnapshot snapshot){
    if(snapshot.value != null)
    {
      var cartModel =CartModel.fromJson(json.decode(json.encode(snapshot.value)));
      cartModel.quantity+=1;
      cartModel.totalPrice = double.parse(drinkModel.price) * cartModel.quantity;
      cart.child(
          drinkModel.key)
          .set(cartModel.toJson())
          .then((value) => ScaffoldMessenger.of(scaffoldKey.currentContext)
          .showSnackBar(SnackBar(content: Text('Update Successfully'))))
          .catchError((e) => ScaffoldMessenger.of(scaffoldKey.currentContext)
          .showSnackBar(SnackBar(content: Text('$e'))));

    } else{
      CartModel cartModel = new CartModel(
          name: drinkModel.name,
          key: drinkModel.key,
          price: drinkModel.price,
          image: drinkModel.image,
          quantity: 1,
          totalPrice: double.parse(drinkModel.price));

      cart.child(
          drinkModel.key)
          .set(cartModel.toJson())
          .then((value) => ScaffoldMessenger.of(scaffoldKey.currentContext)
          .showSnackBar(SnackBar(content: Text('Add to Cart'))))
          .catchError((e) => ScaffoldMessenger.of(scaffoldKey.currentContext)
          .showSnackBar(SnackBar(content: Text('$e'))));
    }
  } );
}

void update(GlobalKey<ScaffoldState> scaffoldKey, CartModel cartModel) {
  var cart = FirebaseDatabase.instance
      .reference()
      .child('Cart')
      .child('UNIQUE_USER_ID');
  cart.child(cartModel.key).set(cartModel.toJson())
      .then((value) => ScaffoldMessenger.of(scaffoldKey.currentContext)
      .showSnackBar(SnackBar(content: Text('Update Successfully'))))
      .catchError((e) => ScaffoldMessenger.of(scaffoldKey.currentContext)
      .showSnackBar(SnackBar(content: Text('$e'))));
}

void delete(GlobalKey<ScaffoldState> scaffoldKey, CartModel cartModel) {
  var cart = FirebaseDatabase.instance
      .reference()
      .child('Cart')
      .child('UNIQUE_USER_ID');
  cart.child(cartModel.key).remove()
      .then((value) => ScaffoldMessenger.of(scaffoldKey.currentContext)
      .showSnackBar(SnackBar(content: Text('Update Successfully'))))
      .catchError((e) => ScaffoldMessenger.of(scaffoldKey.currentContext)
      .showSnackBar(SnackBar(content: Text('$e'))));
}