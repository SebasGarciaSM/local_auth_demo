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
            ElevatedButton.icon(
              onPressed: () {
                // Implement Face ID authentication logic here
                print('Face ID login pressed');
                // Navigate to the home page
                Navigator.pushReplacementNamed(context, '/home');
              },
              icon: const Icon(Icons.tag_faces),
              label: const Text('Login with Face ID'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
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
