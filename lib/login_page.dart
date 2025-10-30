import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBioemtrics() async {
    late List<BiometricType> availableBioemtrics;
    try {
      availableBioemtrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBioemtrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _availableBiometrics = availableBioemtrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = AuthorizedState.authenticating;
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        if (e.code != LocalAuthExceptionCode.userCanceled &&
            e.code != LocalAuthExceptionCode.systemCanceled) {
          _authorized =
              'Error - ${e.code.name}${e.description != null ? ': ${e.description}' : ''}';
        }
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Unexpected error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }
    setState(
      () => _authorized = authenticated
          ? AuthorizedState.authorized
          : AuthorizedState.notAuthorized,
    );

    // Navigate to home page on successful authentication
    if (authenticated && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = AuthorizedState.authenticating;
      });
      authenticated = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        persistAcrossBackgrounding: true,
        biometricOnly: true,
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = AuthorizedState.authenticating;
      });
    } on LocalAuthException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        if (e.code != LocalAuthExceptionCode.userCanceled &&
            e.code != LocalAuthExceptionCode.systemCanceled) {
          _authorized =
              'Error - ${e.code.name}${e.description != null ? ': ${e.description}' : ''}';
        }
      });
      return;
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Unexpected error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    final String message = authenticated
        ? AuthorizedState.authorized
        : AuthorizedState.notAuthorized;
    setState(() {
      _authorized = message;
    });

    // Navigate to home page on successful authentication
    if (authenticated && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
      (bool isSupported) => setState(
        () => _supportState = isSupported
            ? _SupportState.supported
            : _SupportState.unsupported,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_supportState == _SupportState.unknown)
              const CircularProgressIndicator()
            else if (_supportState == _SupportState.supported)
              const Text("This device is supported")
            else
              const Text("This device is not supported"),
            const SizedBox(height: 50.0),
            Text("Can check biometrics: $_canCheckBiometrics"),
            ElevatedButton(
              onPressed: _checkBiometrics,
              child: const Text("Check biometrics"),
            ),
            const SizedBox(height: 50.0),
            Text("Available biometrics: $_availableBiometrics"),
            ElevatedButton(
              onPressed: _getAvailableBioemtrics,
              child: const Text("Get available biometrics"),
            ),
            const SizedBox(height: 50.0),
            Text("Current State: $_authorized"),
            if (_isAuthenticating)
              ElevatedButton(
                onPressed: _cancelAuthentication,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("Cancel Authentication"),
                    Icon(Icons.cancel),
                  ],
                ),
              )
            else
              Column(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _authenticate,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("Authenticate"),
                        Icon(Icons.perm_device_information),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _authenticateWithBiometrics,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _isAuthenticating
                              ? 'Cancel'
                              : 'Authenticate: biometrics only',
                        ),
                        Icon(Icons.tag_faces),
                      ],
                    ),
                  ),
                ],
              ),
            // ElevatedButton.icon(
            //   onPressed: () {
            //     // Implement Face ID authentication logic here
            //     print('Face ID login pressed');
            //     // Navigate to the home page
            //     Navigator.pushReplacementNamed(context, '/home');
            //   },
            //   icon: const Icon(Icons.tag_faces),
            //   label: const Text('Login with Face ID'),
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 24,
            //       vertical: 12,
            //     ),
            //     textStyle: const TextStyle(fontSize: 18),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class AuthorizedState {
  static const String authenticating = 'Authenticating';
  static const String authorized = 'Authorized';
  static const String notAuthorized = 'Not Authorized';
}
