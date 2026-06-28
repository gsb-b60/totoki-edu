import 'package:flutter/material.dart';

class PictureViewer extends StatelessWidget {
  final String imageAssetPath;

  const PictureViewer({super.key, required this.imageAssetPath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openZoomView(context),
      child: Hero(
        tag: imageAssetPath,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imageAssetPath,
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  void _openZoomView(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          final controller = TransformationController();
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            ),
            body: SizedBox.expand(
              child: Hero(
                tag: imageAssetPath,
                child: GestureDetector(
                  onDoubleTap: () {
                    final scale = controller.value.getMaxScaleOnAxis();
                    if (scale < 2.0) {
                      controller.value = Matrix4.diagonal3Values(3.0, 3.0, 1.0);
                    } else {
                      controller.value = Matrix4.identity();
                    }
                  },
                  child: InteractiveViewer(
                    transformationController: controller,
                    constrained: true,
                    clipBehavior: Clip.none,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: 1.0,
                    maxScale: 5.0,
                    child: Image.asset(imageAssetPath, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
