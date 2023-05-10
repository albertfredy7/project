import 'package:flutter/material.dart';
import 'package:google_mao/view-model/auth/authentication_controller.dart';
import 'package:google_mao/view/auth/widgets/textfield.dart';
import 'package:provider/provider.dart';

TextEditingController phoneNumberController = TextEditingController();
TextEditingController otpController = TextEditingController();

class PhoneAuth extends StatelessWidget {
  const PhoneAuth({super.key});

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<AuthneticationController>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('OTP Authentication'),
        ),
        body: Consumer<AuthneticationController>(
          builder: (context, value, child) {
            if (provider.verificationID != '') {
              return const OtpChecking();
            } else {
              return PhoneNumberVerification(provider: provider);
            }
          },
        ));
  }
}

class OtpChecking extends StatelessWidget {
  const OtpChecking({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFieldWidget(
          hint: 'Enter OTP',
          otp: true,
          controller: otpController,
        ),
        ElevatedButton(
          onPressed: () {
            final provider =
                Provider.of<AuthneticationController>(context, listen: false);
            provider.verifyOTP(context, otpController.text);
          },
          child: const Text('Verify OTP'),
        ),
      ],
    );
  }
}

class PhoneNumberVerification extends StatelessWidget {
  const PhoneNumberVerification({
    Key? key,
    required this.provider,
  }) : super(key: key);

  final AuthneticationController provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFieldWidget(
          hint: 'Enter Phone Number',
          controller: phoneNumberController,
        ),
        ElevatedButton(
          onPressed: () {
            provider.loginWithPhone(phoneNumberController.text);
          },
          child: const Text('Verify Phone Number'),
        ),
      ],
    );
  }
}
