import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:presence/app/routes/app_pages.dart';

class PageIndexController extends GetxController {
  RxInt PageIndex = 0.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void changedPage(int i) async {
    switch (i) {
      case 1:
        Map<String, dynamic> dataResponse = await determinePosition();
        if (dataResponse["error"] != true) {
          Position position = dataResponse["position"];

          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          String address =
              "${placemarks[0].street}, ${placemarks[0].subLocality}, ${placemarks[0].locality}";
          await updatePosition(position, address);

          // cek distance beetwen 2 position
          double distance = Geolocator.distanceBetween(
              -6.340033, 106.7914093, position.latitude, position.longitude);
          //presensi
          await presensi(position, address, distance);

          // Get.snackbar("Berhasil", "Kamu telah mengisi daftar hadir");
        } else {
          Get.snackbar("Terjadi kesalahan", dataResponse["message"]);
        }
        break;
      case 2:
        PageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        PageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> presensi(
      Position position, String address, double distantce) async {
    String uid = await auth.currentUser!.uid;

    CollectionReference<Map<String, dynamic>> colPresence =
        await firestore.collection("pegawai").doc(uid).collection("presence");

    QuerySnapshot<Map<String, dynamic>> snapPresence = await colPresence.get();

    // print();
    DateTime now = DateTime.now();
    String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");

    String status = "Di Luar Area";

    if (distantce <= 200) {
      status = "Di Dalam Area";
    }

    if (snapPresence.docs.length == 0) {
      // belum pernah absen & set absen masuk pertama kalinya

      await Get.defaultDialog(
        title: "Validasi Presensi",
        middleText: "Apakah kamu yakin akan absen (MASUK) sekarang?",
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () async {
              await colPresence.doc(todayDocID).set({
                "date": now.toIso8601String(),
                "masuk": {
                  "date": now.toIso8601String(),
                  "lat": position.latitude,
                  "long": position.longitude,
                  "address": address,
                  "status": status,
                  "distance": distantce,
                },
              });
              Get.back();
              Get.snackbar(
                  "Berhasil", "Kamu telah mengisi daftar hadir (MASUK)");
            },
            child: Text("YES"),
          ),
        ],
      );
    } else {
      // Sudah pernah absen -> cek hari ini udah absen masuk/keluar belum?
      DocumentSnapshot<Map<String, dynamic>> todayDoc =
          await colPresence.doc(todayDocID).get();

      if (todayDoc.exists == true) {
        // tinggal absen keluar atau sudah absen masuk dan keluar
        Map<String, dynamic>? dataPresenceToday = todayDoc.data();
        if (dataPresenceToday?["keluar"] != null) {
          // sudah absen masuk dan keluar
          Get.snackbar("Informasi Penting",
              "Kamu telah absen masuk & keluar. Silahkan absen lagi besok");
        } else {
          // absen keluar
          await Get.defaultDialog(
            title: "Validasi Presensi",
            middleText: "Apakah kamu yakin akan absen (KELUAR) sekarang?",
            actions: [
              OutlinedButton(
                onPressed: () => Get.back(),
                child: Text("CANCEL"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await colPresence.doc(todayDocID).update({
                    "keluar": {
                      "date": now.toIso8601String(),
                      "lat": position.latitude,
                      "long": position.longitude,
                      "address": address,
                      "status": status,
                      "distance": distantce,
                    },
                  });
                  Get.back();
                  Get.snackbar("Berhasil", "Kamu telah mengisi absen (KELUAR)");
                },
                child: Text("YES"),
              ),
            ],
          );
        }
      } else {
        // absen masuk
        await Get.defaultDialog(
          title: "Validasi Presensi",
          middleText: "Apakah kamu yakin akan absen (MASUK) sekarang?",
          actions: [
            OutlinedButton(
              onPressed: () => Get.back(),
              child: Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () async {
                await colPresence.doc(todayDocID).set({
                  "date": now.toIso8601String(),
                  "masuk": {
                    "date": now.toIso8601String(),
                    "lat": position.latitude,
                    "long": position.longitude,
                    "address": address,
                    "status": status,
                    "distance": distantce,
                  },
                });
                Get.back();
                Get.snackbar("Berhasil", "Kamu telah mengisi absen (MASUK)");
              },
              child: Text("YES"),
            ),
          ],
        );
      }
    }
  }

  Future<void> updatePosition(Position position, String address) async {
    String uid = await auth.currentUser!.uid;

    await firestore.collection("pegawai").doc(uid).update({
      "position": {
        "lat": position.latitude,
        "long": position.longitude,
      },
      "address": address,
    });
  }

  Future<Map<String, dynamic>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // return Future.error('Location services are disabled.');
      return {
        "message": "Tidak dapat mengambil GPS dari device ini.",
        "error": true,
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
        // ignore: dead_code
        return {
          "message": "Izin menggunakan GPS ditolak.",
          "error": true,
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return {
        "message":
            "Settingan hp kamu tidak memperbolehkan untuk mengakses GPS. Ubah pada settingan hp kamu.",
        "error": true,
      };
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return {
      "position": position,
      "message": "Berhasil mendapatkan posisi device.",
      "error": false,
    };
  }
}
