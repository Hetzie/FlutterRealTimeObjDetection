import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:real_time_obj_detection/controller/scan_controller.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GetBuilder<ScanController>(
          init: ScanController(),
          builder: (controller) {
            double factorX = screenWidth;
            double factorY = screenHeight / screenHeight * screenWidth;

            return controller.isCameraInitialized.value
                ? Stack(
                    children: [
                      CameraPreview(controller.cameraController),
                      Positioned(
                          left: (controller.x ?? 0.2) * factorX,
                          top: (controller.y ?? 0.2) * (factorY) * 1.6,
                          width: (controller.w ?? 0.2) * factorX,
                          height:
                              (controller.h ?? 0.2) * controller.imageHeight,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                              color: Colors.greenAccent.shade200,
                              width: 3,
                            )),
                            child: Text(
                              controller.label,
                              style: TextStyle(
                                background: Paint()..color = Colors.blue,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ))
                    ],
                  )
                : const Center(child: Text('Loading Preview...'));
          }),
    );
  }
}
