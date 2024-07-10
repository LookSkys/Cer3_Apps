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
    TextStyle estiloTitulo = TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Center(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: StreamBuilder<User?>(
              stream: _auth.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Cargando...', style: estiloTitulo);
                } else if (snapshot.hasError) {
                  return Text('Error', style: estiloTitulo);
                } else if (snapshot.hasData && snapshot.data != null) {
                  return Text(
                    'Bienvenido, ${snapshot.data!.displayName}!',
                    style: estiloTitulo,
                  );
                } else {
                  return Text('Workout App! 🏋️‍♂️', style: estiloTitulo);
                }
              },
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () => _signOut(context),
              ),
            ],
            backgroundColor: Color(0xff091819),
            bottom: TabBar(
              labelStyle: TextStyle(color: Colors.orange),
              unselectedLabelStyle: TextStyle(color: Colors.grey),
              indicatorColor: Colors.orange,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  text: 'Horarios',
                  icon: Icon(MdiIcons.clock),
                ),
                Tab(
                  text: 'Rutinas',
                  icon: Icon(MdiIcons.weightLifter),
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
