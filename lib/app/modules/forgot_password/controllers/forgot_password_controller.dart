import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  sendEmail() async {
    print(emailC.value.text + "value");
    print(emailC.text + "text");
    if (emailC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        // await auth.sendPasswordResetEmail(email: emailC.text);
        await auth.sendPasswordResetEmail(email: emailC.text);

        print(emailC.text);

        Get.snackbar("Berhasil",
            "Kami telah mengirimkan email reset passsword. Periksa email kamu");
      } catch (e) {
        Get.snackbar(
            "Terjadi Kesalahan", "Tiddak dapat mengirim email reset passwprd");
      } finally {
        isLoading.value = false;
      }
    }
  }
}
