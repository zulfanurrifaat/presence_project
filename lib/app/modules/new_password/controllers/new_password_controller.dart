import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:presence/app/routes/app_pages.dart';

class NewPasswordController extends GetxController {
  TextEditingController newPassC = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  void newPassword() async {
    if (newPassC.text.isNotEmpty) {
      if (newPassC.text != "password") {
        try {
          String? email = auth.currentUser!.email;
          await auth.currentUser!.updatePassword(newPassC.text);

          await auth.signOut();

          await auth.signInWithEmailAndPassword(
            email: email!,
            password: newPassC.text,
          );

          Get.offAllNamed(Routes.HOME);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            Get.snackbar("Terjadi kesalahan",
                "Password telalu lemah, setidaknya 6 karakter");
          }
        } catch (e) {
          Get.snackbar("Terjadi kesalahan",
              "Password telalu lemah, tidak dapat membuat password baru. Hubungi admin atau customer service");
        }
      } else {
        Get.snackbar(
            "Terjadi Kesalahan", "Password baru harus diubah tidak boleh sama");
      }
    } else {
      Get.snackbar("Terjadi Kesalahan", "Password baru wajib diisi");
    }
  }
}
