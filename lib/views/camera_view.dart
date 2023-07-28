import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:real_time_obj_detection/controller/scan_controller.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanController>(
          init: ScanController(),
          builder: (controller) {
            return controller.isCameraInitialized.value
                ? Column(
                    children: [
                      Stack(
                        children: [
                          CameraPreview(controller.cameraController),
                          /*Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Container(
                              width: 200,
                              height: 100,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.lightGreenAccent, width: 4.0)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    color: Colors.white,
                                    child: Text("${controller.label}"),
                                  ),
                                ],
                              ),
                            ),
                          )*/
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                color: Colors.blue.shade200),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                controller.label,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            )),
                      )
                    ],
                  )
                : const Center(child: Text('Loading Preview...'));
          }),
    );
  }
}
