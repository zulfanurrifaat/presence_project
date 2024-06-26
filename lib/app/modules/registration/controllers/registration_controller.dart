import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegistrationController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> register(
      String email, String password, String name, BuildContext context) async {
    try {
      UserCredential userCred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCred.user!.updateDisplayName(name);
      await firestore.collection('pegawai').doc(userCred.user!.uid).set({
        'name': name,
        'email': email,
        'role': "admin",
        'createdAt': Timestamp.now(),
      });
      Get.snackbar("Sukses", "Registrasi admin berhasil");
      Get.back();
      // Navigasi ke halaman lain jika diperlukan
      // Get.toNamed('/home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Get.snackbar("Terjadi kesalahan", "Akun dengan email ini sudah ada.");
      } else if (e.code == 'weak-password') {
        Get.snackbar("Error", "Password is too weak.");
      } else {
        Get.snackbar("Terjadi kesalahan", "Registrasi gagal: ${e.message}");
      }
    } catch (e) {
      Get.snackbar("Terjaadi kesalahan", "Ada yang salah: $e");
    }
  }
}
