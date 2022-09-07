import 'package:arisan_digital/blocs/auth_bloc/auth_bloc.dart';
import 'package:arisan_digital/screens/auth/login_screen.dart';
import 'package:arisan_digital/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class StartingScreen extends StatefulWidget {
  const StartingScreen({Key? key}) : super(key: key);

  @override
  State<StartingScreen> createState() => _StartingScreenState();
}

class _StartingScreenState extends State<StartingScreen> {
  void routeHomeScreen() {
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const HomeScreen()),
      ModalRoute.withName('/home-screen'),
    );
  }

  @override
  void initState() {
    // context.loaderOverlay.show();
    context.read<AuthBloc>().add(AuthUserFetched());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            context.loaderOverlay.show();
          } else if (state is AuthUser) {
            context.loaderOverlay.hide();
            if (state.authStatus == AuthStatus.authenticated) {
              routeHomeScreen();
              // Navigator.push(context, MaterialPageRoute(builder: (builder) {
              //   return const HomeScreen();
              // }));
            }
          } else {
            // Show a snackbar
            //...
            context.loaderOverlay.hide();
          }
        },
        child: LoaderOverlay(
          useDefaultLoading: false,
          overlayOpacity: 0.6,
          overlayWidget: Center(
            child: LoadingAnimationWidget.waveDots(
              color: Colors.white,
              size: 70,
            ),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello 👋',
                        style: TextStyle(
                            color: Colors.lightBlue[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                      ),
                      Text(
                        'Arisan Digital',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Kocok arisan jadi lebih mudah dan cepat.',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Atur anggota arisan ngga ribet.',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlue[700],
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (builder) {
                              return LoginScreen();
                            }));
                          },
                          child: Text('Pengelola'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.lightBlue[700],
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: BorderSide(color: Colors.grey)),
                              elevation: 0.5),
                          onPressed: () {},
                          child: Text(
                            'Peserta',
                            style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
