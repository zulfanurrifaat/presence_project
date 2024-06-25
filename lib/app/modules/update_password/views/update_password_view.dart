import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/update_password_controller.dart';

class UpdatePasswordView extends GetView<UpdatePasswordController> {
  const UpdatePasswordView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPDATE PASSWORD'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: controller.currC,
            autocorrect: false,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Password saat ini",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: controller.newC,
            autocorrect: false,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Password baru",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: controller.confirmC,
            autocorrect: false,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Konfirmasi password baru",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          Obx(
            () => ElevatedButton(
              onPressed: () {
                if (controller.isLoading.isFalse) {
                  controller.updatePass();
                }
              },
              child: Text((controller.isLoading.isFalse)
                  ? "UBAH PASSWORD"
                  : "LOADING..."),
            ),
          ),
        ],
      ),
    );
  }
}
