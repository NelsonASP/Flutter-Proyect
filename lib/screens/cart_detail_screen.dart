
import 'dart:convert';

import 'package:app_one/firebase/firebase_action.dart';
import 'package:app_one/model/cart_model.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elegant_number_button/flutter_elegant_number_button.dart';

class CartDatail extends StatefulWidget{

  CartDatail({Key key}) : super(key: key);

  @override
  CartDatailState createState() => CartDatailState();


}

class CartDatailState extends State<CartDatail> {
  List<CartModel> cartModels = new List<CartModel>.empty(growable: true);
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Center(child: Text('Cart'),),
      ),
      body: StreamBuilder(
        stream:
        FirebaseDatabase.instance.reference().child('Cart').child('UNIQUE_USER_ID').onValue,
        builder: (BuildContext context, AsyncSnapshot<Event> snapshot){
          if(snapshot.hasData)
          {
            var map = snapshot.data.snapshot.value as Map<dynamic,dynamic>;
            cartModels.clear(); // limpia l lista
           if(map != null){
             map.forEach((key, value) {
               var cartModel =
               new CartModel.fromJson(json.decode(json.encode(value)));
               cartModel.key = key;
               cartModels.add(cartModel);
             });
           }
            return cartModels.length > 0
                ? ListView.builder(
                itemCount: cartModels.length,
                itemBuilder: (context,index){
                  return Stack(
                    children: [
                      Card(
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 6.0 ),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: ClipRRect(child: Image(
                                    image: NetworkImage(
                                        cartModels[index].image),
                                    fit: BoxFit.cover,
                                ),
                                    borderRadius: BorderRadius.all(Radius.circular(4)),
                                ),
                                  flex: 2,
                              ),
                              Expanded(flex: 4, child: Container(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8,right: 8),
                                    child: Text(cartModels[index].name,
                                      style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:  FontWeight.bold
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,right: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .start,
                                        children: [
                                          Text('Total: \$${cartModels[index].totalPrice}', style: TextStyle(fontSize: 24),),
                                          ElegantNumberButton(
                                              initialValue:
                                                cartModels[index]
                                                    .quantity,
                                              buttonSizeHeight: 20,
                                              buttonSizeWidth: 25,
                                              color: Colors.white38,
                                              minValue: 1,
                                              maxValue: 99,
                                              onChanged: (value) async{
                                                cartModels[index]
                                                    .quantity = value;
                                                cartModels[index]
                                                    .totalPrice =
                                                    double.parse(
                                                        cartModels[index]
                                                            .price) *
                                                        cartModels[index]
                                                            .quantity;
                                                update(scaffoldKey, cartModels[index]);
                                              },
                                              decimalPlaces: 0)
                                        ],

                                      ),),
                                  ],
                                ),
                              ))
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(padding: const EdgeInsets.all(8),
                          child: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () async {
                              if(await confirm(context,
                              title: Text('Borrar Articulo'),
                              content: Text('Realmente dese borrar el articulo'),
                              textOK: Text('borrar', style: TextStyle(color: Colors.red)),
                              textCancel: Text('Cancelar', style: TextStyle(color: Colors.red)
                              ))){
                                return delete(scaffoldKey, cartModels[index]);
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  );
                }):
                  Center(
                    child: Text('Empy Cart'),
                  );
          }
          else return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}