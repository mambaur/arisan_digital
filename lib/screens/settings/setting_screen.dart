import 'package:arisan_digital/blocs/auth_bloc/auth_bloc.dart';
import 'package:arisan_digital/screens/settings/about_screen.dart';
import 'package:arisan_digital/screens/starting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// final GoogleSignIn _googleSignIn = GoogleSignIn(
//   scopes: [
//     'email',
//     'https://www.googleapis.com/auth/contacts.readonly',
//   ],
// );

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          context.loaderOverlay.show();
        } else if (state is AuthLogout) {
          context.loaderOverlay.hide();
          if (state.authStatus == AuthStatus.unauthenticated) {
            Navigator.pushAndRemoveUntil<void>(
              context,
              MaterialPageRoute<void>(
                  builder: (BuildContext context) => const StartingScreen()),
              ModalRoute.withName('/starting-screen'),
            );
          }
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
        child: Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                    floating: true,
                    iconTheme: IconThemeData(color: Colors.grey.shade300),
                    titleTextStyle: TextStyle(
                        color: Colors.lightBlue.shade800,
                        fontWeight: FontWeight.w500),
                    backgroundColor: Colors.white,
                    centerTitle: true,
                    elevation: 0,
                    title: Text('Pengaturan')),
                SliverList(
                    delegate: SliverChildListDelegate([
                  Container(
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (builder) {
                              return AboutScreen();
                            }));
                          },
                          trailing: Icon(Icons.chevron_right),
                          title: Text('Tentang Aplikasi'),
                        ),
                        ListTile(
                          onTap: () => _showLogoutDialog(context),
                          trailing: Icon(Icons.chevron_right),
                          title: Text('Keluar'),
                        ),
                      ],
                    ),
                  )
                ])),
                SliverList(delegate: SliverChildListDelegate([])),
              ]),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Keluar Aplikasi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Apakah kamu yakin ingin keluar dari aplikasi?'),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.white),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.blue.shade700),
              child:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthOnLogout());
              },
            ),
          ],
        );
      },
    );
  }
}
