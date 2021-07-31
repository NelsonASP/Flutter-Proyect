import 'dart:convert';

import 'package:app_one/model/cart_model.dart';
import 'package:app_one/screens/cart_detail_screen.dart';
import 'package:badges/badges.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:page_transition/page_transition.dart';

import 'firebase/firebase_action.dart';
import 'model/drink_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp();
  runApp(MyApp(app:app));
}

class MyApp extends StatelessWidget {
  final FirebaseApp app;

  MyApp({this.app}); // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings){
        switch(settings.name){

          case'/cartPage':
            return PageTransition(
                settings: settings,
                child: CartDatail(), type: PageTransitionType.fade);
            break;
          default:
          return null;
        }
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Tienda',app:app),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.app}) : super(key: key);

  final FirebaseApp app;

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  List<DrinkModel> drinkModels = new  List<DrinkModel>.empty(growable: true);
  List<CartModel> cartsModels = new  List<CartModel>.empty(growable: true);


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(child: Text(widget.title),),
        actions: [
          Padding(padding: const EdgeInsets.only(top: 10, right: 20),
            child: StreamBuilder(
              stream: FirebaseDatabase.instance
              .reference()
              .child('Cart')
              .child('UNIQUE_USER_ID')
              .onValue,
              builder: (BuildContext context, AsyncSnapshot<Event> snapshot){
                var numberItemIntCart = 0;
                if(snapshot.hasData){
                    Map<dynamic,dynamic> map = snapshot.data.snapshot.value;
                    cartsModels.clear();
                    if(map != null) {
                      map.forEach((key, value) {
                        var cartModel = CartModel.fromJson(json.decode(json
                            .encode(value)));
                        cartModel.key = key;
                        cartsModels.add(cartModel);
                      });
                      numberItemIntCart =
                      cartsModels
                          .map<int>((m) => m.quantity)
                          .reduce((s1, s2) => s1+s2);
                    }

                    return GestureDetector(
                      onTap: (){
                        Navigator.of(context).pushNamed('/cartPage');
                      },
                      child: Center(child: Badge(
                      showBadge: true,
                      badgeContent: Text('${numberItemIntCart > 9 ? 9.toString() + "+": numberItemIntCart.toString()}', style: TextStyle(color: Colors.white),),
                      child: Icon(Icons.shopping_cart, color: Colors.white,
                      ),
                    ),),);
                  }
                else
                  return Center(
                    child: Badge(
                      showBadge: true,
                      badgeContent: Text('0', style: TextStyle(color: Colors.white),),
                      child: Icon(Icons.shopping_cart, color: Colors.white,
                      ),
                    ),
                  );
              },
            ),
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Expanded(
              child: StreamBuilder(
          stream:
              FirebaseDatabase.instance.reference().child('Drink').onValue,
          builder: (BuildContext context, AsyncSnapshot<Event> snapshot){
            if(snapshot.hasData)
            {
              var map = snapshot.data.snapshot.value as Map<dynamic,dynamic>;
              drinkModels.clear(); // limpia l lista
              map.forEach((key, value) {
                var drinkModel =
                new DrinkModel.fromJson(json.decode(json.encode(value)));
                drinkModel.key = key;
                drinkModels.add(drinkModel);
              });
              return StaggeredGridView.countBuilder(
                  crossAxisCount: 2,
                  itemCount: drinkModels.length,
                  padding: const EdgeInsets.all(2.0),
                  mainAxisSpacing: 2.0,
                  crossAxisSpacing: 2.0,
                  itemBuilder: (BuildContext context, int index){
                    return InkWell(
                      child: GestureDetector(
                        onTap: (){
                          addToCart(_scaffoldKey,drinkModels[index]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 8,
                            child: Column(
                              children: [
                                Expanded(
                                  child:
                                      Image.network(drinkModels[index].image),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(child: Text('${drinkModels[index].name}'),),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Center(child: Text('\$${drinkModels[index].price}',
                                  style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  staggeredTileBuilder: (int index) =>StaggeredTile.count(1,index.isEven ? 1.1 : 1.0));
            }
            else return Center(child: CircularProgressIndicator(),);
          },
        ))
      ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

