import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nova_fashion_admin/SignIn.dart';
import 'package:nova_fashion_admin/pages/Home.dart';
import 'package:nova_fashion_admin/pages/Shop.dart';
import 'package:provider/provider.dart';

import 'AuthService.dart';

final storageRef = FirebaseStorage.instance.ref();
final categoryRef = FirebaseFirestore.instance.collection('categories');
final collectionRef = FirebaseFirestore.instance.collection('collections');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
            create: (_) => AuthService(FirebaseAuth.instance)),
        StreamProvider(
            create: (context) => context.read<AuthService>().authStateChanges)
      ],
      child: MaterialApp(
        title: 'NOVA green',
        theme: ThemeData(
            fontFamily: 'Gilroy',
            appBarTheme: AppBarTheme(
                color: Colors.white,
                elevation: 0,
                centerTitle: true,
                iconTheme: IconThemeData(color: Colors.black))),
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User _firebaseUser = context.watch<User>();

    if (_firebaseUser != null) {
      print(_firebaseUser.displayName);
      print(_firebaseUser.email);
      print(_firebaseUser.photoURL);
      print(_firebaseUser.uid);
      return MainScreen(user: _firebaseUser);
    }
    return SignIn();
  }
}

class MainScreen extends StatefulWidget {
  final User user;

  MainScreen({Key key, title, this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;

  AnimationController _controller;
  Animation<double> _radiusAnimation;
  double _radius = 0;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _radiusAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _radiusAnimation.addListener(() {
      setState(() {
        _radius = _radiusAnimation.value;
      });
    });
    super.initState();
  }

  Widget menu({IconData leading, String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(leading, color: Colors.white70, size: 28),
          SizedBox(width: 15),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 20))
        ],
      ),
    );
  }

  int currentIndex = 0;

  setBottomBarIndex(index) {
    setState(() {
      currentIndex = index;
    });
  }

  List<Widget> _widgetOptions = <Widget>[Home(), Shop()];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Scaffold(
          body: Container(
              color: Color(0xff2F2A36),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: width * 0.05),
                child: Column(children: [
                  SizedBox(height: 40),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.grey[700],
                          radius: width * 0.07,
                          backgroundImage: NetworkImage(widget.user.photoURL)),
                      SizedBox(width: width * 0.03),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Enjoy shopping!',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.normal)),
                          SizedBox(height: 4),
                          SizedBox(
                            width: width * 0.65,
                            child: Text(widget.user.displayName,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          )
                        ],
                      ),
                      InkWell(
                        child: Container(
                          width: width * 0.08,
                          height: 40,
                          child: Icon(Icons.clear, color: Colors.white70),
                        ),
                        onTap: () {
                          setState(() {
                            if (isDrawerOpen) {
                              xOffset = 0;
                              yOffset = 0;
                              scaleFactor = 1;
                              _controller.reverse();
                              isDrawerOpen = !isDrawerOpen;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        menu(
                            leading: Icons.category_rounded,
                            title: 'Shop by Category'),
                        menu(leading: Icons.shopping_bag, title: 'Your Orders'),
                        menu(leading: Icons.favorite, title: 'Wish List'),
                        menu(leading: Icons.info, title: 'About Us'),
                        menu(leading: Icons.logout, title: 'Log out'),
                      ],
                    ),
                  )
                ]),
              )),
        ),
        AnimatedContainer(
            duration: Duration(milliseconds: 250),
            transform: Matrix4.translationValues(xOffset, yOffset, 0)
              ..scale(scaleFactor),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: isDrawerOpen
                    ? BorderRadius.all(Radius.circular(40))
                    : BorderRadius.zero),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isDrawerOpen) {
                    xOffset = 0;
                    yOffset = 0;
                    scaleFactor = 1;
                    _controller.reverse();
                    isDrawerOpen = !isDrawerOpen;
                  }
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(_radius * 40)),
                child: Scaffold(
                  appBar: AppBar(
                    brightness: Brightness.dark,
                    title: Text('NOVA Fashion',
                        style: TextStyle(color: Colors.black)),
                    centerTitle: true,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    leading: IconButton(
                      icon: Icon(Icons.menu, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          if (isDrawerOpen) {
                            xOffset = 0;
                            yOffset = 0;
                            scaleFactor = 1;
                            _controller.reverse();
                          } else {
                            xOffset = MediaQuery.of(context).size.width * 0.1;
                            yOffset = MediaQuery.of(context).size.height * 0.7;
                            scaleFactor = 0.8;
                            _controller.forward();
                          }
                          isDrawerOpen = !isDrawerOpen;
                        });
                      },
                    ),
                  ),
                  backgroundColor: Colors.white.withAlpha(55),
                  body: Stack(
                    children: [
                      _widgetOptions.elementAt(currentIndex),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: size.width,
                          height: 80,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CustomPaint(
                                size: Size(size.width, 80),
                                painter: BNBCustomPainter(),
                              ),
                              Center(
                                heightFactor: 0.6,
                                child: FloatingActionButton(
                                    backgroundColor: Color(0xFFFF7576),
                                    child: Icon(Icons.mic),
                                    elevation: 0.1,
                                    onPressed: () {}),
                              ),
                              Container(
                                width: size.width,
                                height: 80,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.home,
                                        color: currentIndex == 0
                                            ? Color(0xFFFF7576)
                                            : Colors.grey.shade400,
                                      ),
                                      onPressed: () {
                                        setBottomBarIndex(0);
                                      },
                                      splashColor: Colors.white,
                                    ),
                                    Container(
                                      width: size.width * 0.20,
                                    ),
                                    IconButton(
                                        icon: Icon(
                                          Icons.store,
                                          color: currentIndex == 1
                                              ? Colors.orange
                                              : Colors.grey.shade400,
                                        ),
                                        onPressed: () {
                                          setBottomBarIndex(1);
                                        }),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(20.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
