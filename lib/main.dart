// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
// import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(
            () => _supportState = isSupported
                ? _SupportState.supported
                : _SupportState.unSupported,
          ),
        );
  }

  Future<void> _checkbiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      // ignore: avoid_print
      print(e);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
      availableBiometrics = <BiometricType>[];
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    });
  }

  _authenticateWithBiometrics(BuildContext context) async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    });
    if (authenticated) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() {
      _isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Biometrics Authentication'),
          ),
          body: ListView(
            padding: const EdgeInsets.only(top: 350),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // if (_supportState == _SupportState.unknown)
                  //   const CircularProgressIndicator()
                  // else if (_supportState == _SupportState.supported)
                  //   const Text('This device is supported')
                  // else
                  //   const Text('This device is not supported'),
                  // const Divider(
                  //   height: 100,
                  // ),
                  // Text('Can check biometrics: $_canCheckBiometrics \n'),
                  // ElevatedButton(
                  //   onPressed: _checkbiometrics,
                  //   child: const Text('Check Biometrics'),
                  // ),
                  // const Divider(
                  //   height: 100,
                  // ),
                  // Text('Availabe biometrics: $_availableBiometrics \n'),
                  // ElevatedButton(
                  //   onPressed: _getAvailableBiometrics,
                  //   child: const Text('Get Available Biometrics'),
                  // ),
                  // const Divider(
                  //   height: 100,
                  // ),
                  Text('Current State: $_authorized \n'),
                  // if (_isAuthenticating)
                  // ElevatedButton(
                  //   onPressed: _cancelAuthentication,
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: const <Widget>[
                  //       Text('Cancel Authentication'),
                  //       Icon(Icons.perm_device_information),
                  //     ],
                  //   ),
                  // )
                  // else
                  Column(
                    children: <Widget>[
                      // ElevatedButton(
                      //   onPressed: _authenticate,
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: const <Widget>[
                      //       Text('Authenticate'),
                      //       Icon(Icons.perm_device_information),
                      //     ],
                      //   ),
                      // ),
                      ElevatedButton(
                        onPressed: () => _authenticateWithBiometrics(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const <Widget>[
                            Text('Authenticate with'),
                            Icon(Icons.fingerprint),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

enum _SupportState {
  unknown,
  supported,
  unSupported,
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Biometrics Authentication'),
        ),
        body: const Center(
          child: Text('Welcome to home page'),
        ),
      ),
    );
  }
}
