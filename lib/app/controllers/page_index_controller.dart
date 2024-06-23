import 'package:get/get.dart';
import 'package:presence/app/routes/app_pages.dart';
import 'package:geolocator/geolocator.dart';

class PageIndexController extends GetxController {
  RxInt PageIndex = 0.obs;

  void changedPage(int i) async {
    switch (i) {
      case 1:
        print("ABSENI");
        await _determinePosition();
        print("SELESAI");
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
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
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
