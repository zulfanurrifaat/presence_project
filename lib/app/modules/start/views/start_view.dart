import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:presence/app/routes/app_pages.dart';
import '../controllers/start_controller.dart';

class StartView extends GetView<StartController> {
  const StartView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Presensi",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Text("Selamat datang di aplikasi presensi"),
            const Text("Masuk atau daftar jika belum memiliki akun"),
            const SizedBox(height: 15),
            SizedBox(
              width: 280,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(Routes.LOGIN);
                },
                child: Text("Masuk"),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 280,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(Routes.REGISTRATION);
                },
                child: Text("Daftar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
