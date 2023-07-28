import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';

import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTflite();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;

  var x, y, w, h = 0.0;
  var label = "";

  var isCameraInitialized = false.obs;
  var cameraCount = 0;
  bool hasWebCamPermission = false;

  initCamera() async {
    if (kIsWeb) {
      if (await (Permission.camera.request().isGranted)) {
        print("Web Cam Permission Granted.");
        cameras = await availableCameras();
        print("Cameras ---> $cameras");
        cameraController = CameraController(cameras[0], ResolutionPreset.max);
        // window.navigator.mediaDevices!
        //     .getUserMedia({'video': true, 'audio': false})
        //     .asStream().first.then((stream) {
        //     print("Strea${stream.getVideoTracks()[0].getSettings()}");
        //
        // });
      } else {
        print("Web Cam Permission not Granted.");
      }
    } else {
      if (await (Permission.camera.request().isGranted)) {
        cameras = await availableCameras();
        print("Cameras ---> $cameras");
        cameraController = CameraController(cameras[0], ResolutionPreset.max);
        await cameraController.initialize().then((value) {
          cameraController.startImageStream((image) {
            cameraCount++;
            if (cameraCount % 20 == 0) {
              cameraCount = 0;
              objectDetector(image);
            }
            update();
          });
        });

        isCameraInitialized(true);
        update();
      } else {
        print("Camera Permission Denied");
      }
    }
  }

  initTflite() async {
    await Tflite.loadModel(
        model: "assets/mobilenet_v1.tflite",
        labels: "assets/labels_mobilenet.txt",
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false);
  }

  objectDetector(CameraImage image) async {

    var detector = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        threshold: 0.4,
        asynch: true,
        numResults: 1);

    if (detector != null && detector.isNotEmpty) {
      var ourDetectorObject = detector.first;
      if (ourDetectorObject['confidence'] * 100 > 35) {
        label = ourDetectorObject['label'].toString();
        //   h = image.height.toDouble();
        //   w = image.width.toDouble();
        // x = ourDetectorObject['rect']['x'];
        // y = ourDetectorObject['rect']['y'];
        // label = detector.toString();
        print(detector);
      }
      update();
    } else {
      label = "🤔...";
      update();
    }
  }
}
