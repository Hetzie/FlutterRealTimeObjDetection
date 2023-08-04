import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';

import 'package:permission_handler/permission_handler.dart';

class  ScanController extends GetxController {
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

  var x = 0.0, y = 0.0, w = 0.0, h = 0.0, imageHeight = 0.0;
  var label = "";

  var isCameraInitialized = false.obs;
  var cameraCount = 0;
  bool hasWebCamPermission = false;

  initCamera() async {
    if (kIsWeb) {
      if (await (Permission.camera.request().isGranted)) {
        cameras = await availableCameras();
        cameraController = CameraController(cameras[0], ResolutionPreset.max);
        // window.navigator.mediaDevices!
        //     .getUserMedia({'video': true, 'audio': false})
        //     .asStream().first.then((stream) {
        //
        // });
      } else {
      }
    } else {
      if (await (Permission.camera.request().isGranted)) {
        cameras = await availableCameras();
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
      }
    }
  }

  initTflite() async {
    await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/labels_ssd_mobilenet.txt");
  }

  objectDetector(CameraImage image) async {

    var detector = await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      model: "SSDMobileNet",
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 3,
      threshold: 0.4,
    );

    if (detector != null && detector.isNotEmpty) {
      var ourDetectorObject = detector.first;
      if(ourDetectorObject['confidenceInClass']!=null) {
        if (ourDetectorObject['confidenceInClass'] * 100 > 50) {
          label = ourDetectorObject['detectedClass'].toString();
          imageHeight = image.height.toDouble();

          h = ourDetectorObject['rect']['h'];
          w = ourDetectorObject['rect']['w'];
          x = ourDetectorObject['rect']['x'];
          y = ourDetectorObject['rect']['y'];
        }
        update();
      }else {
        label = "🤔...";
        update();
      }
    } else {
      label = "🤔...";
      update();
    }
  }
}
