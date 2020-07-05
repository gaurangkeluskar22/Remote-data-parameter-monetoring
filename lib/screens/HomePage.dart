import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:testapp/Shared/progress.dart';
import 'package:testapp/models/user_model.dart';
import 'package:testapp/screens/Graph.dart';
import 'package:testapp/screens/Tablular.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth auth = FirebaseAuth.instance;
FirebaseUser user;
User currentUser;

final userRef = Firestore.instance.collection('users');

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAuth = false;
  bool isLoading = true;
  PageController pageController;
  int pageIndex = 0;
  @override
  void initState() {
    super.initState();

    auth.currentUser().then((user) {
      if (user != null) {
        userRef.document(user.uid).get().then((doc) {
          DocumentSnapshot documentSnapshot = doc;
          currentUser = User.fromDocument(documentSnapshot);
          setState(() {
            isAuth = true;
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });

    pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 100), curve: Curves.bounceInOut);
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildHomeScreen() : buildLoginScreen();
  }

  Widget buildHomeScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[GraphPage(), TabularPage()],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.data_usage)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          // BottomNavigationBarItem(
          //     icon: Icon(
          //   Icons.photo_camera,
          //   size: 35.0,
          // )),
          // BottomNavigationBarItem(icon: Icon(Icons.search)),
          // BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  Widget buildLoginScreen() {
    return isLoading
        ? circularProgress()
        : Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: isAuth
                        ? CircularProgressIndicator(
                            backgroundColor: Colors.blue,
                          )
                        : Image.asset(
                            'assets/images/logo.png',
                            height: 250.0,
                          )),
                Text(
                  'RDPM',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 32.0,
                    letterSpacing: 3.0,
                    fontFamily: 'mont',
                  ),
                ),
                SizedBox(
                  height: 100.0,
                ),
                Center(
                  child: InkWell(
                    onTap: () {
                      signInWithGoogle();
                    },
                    child: Image.asset(
                      'assets/images/google_signin_button.png',
                      height: 65.0,
                    ),
                  ),
                ),
              ],
            ));
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    final AuthResult authResult = await auth.signInWithCredential(credential);
    user = authResult.user;
    print('User created : ${user.displayName}');

    final FirebaseUser firebaseUser = await auth.currentUser();

    // Let's add user to database
    userRef.document(firebaseUser.uid).setData({
      'id': firebaseUser.uid,
      'photoUrl': firebaseUser.photoUrl,
      'email': firebaseUser.email,
      'displayName': firebaseUser.displayName,
    });

    DocumentSnapshot documentSnapshot =
        await userRef.document(firebaseUser.uid).get();
    currentUser = User.fromDocument(documentSnapshot);

    setState(() {
      isAuth = true;
    });
  }
}
