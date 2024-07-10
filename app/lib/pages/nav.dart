import 'package:app/pages/tabs/horarios.dart';
import 'package:app/pages/tabs/rutinas.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signOut(BuildContext context) async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    TextStyle estilo_titulo = TextStyle(fontSize: 25,fontWeight: FontWeight.bold ,color: Colors.white);
    return Center(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Workout App! 🏋️‍♂️', style: estilo_titulo),
            actions: [
            IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _signOut(context),
          ),
        ],
            backgroundColor: Colors.black,
            bottom:
             TabBar(
              //hace scrolleable el tabBar
              //isScrollable: true,
              //estilo de las tabs
              labelStyle: TextStyle(color: Colors.green),
              unselectedLabelStyle: TextStyle(color: Colors.grey),
              tabs: [               
                Tab(
                  text: 'Horarios',
                  icon: Icon(MdiIcons.tournament),
                ),
                Tab(
                  text: 'Rutinas',
                  icon: Icon(MdiIcons.accountGroupOutline),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Horarios(),
              RutinasScreen(),
            ],
          ),
        ),
      ),
    );
  }
}