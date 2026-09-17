class AssetHelper {
  AssetHelper._();

  static String imageAssetPath(int seriesId, String filename) {
    final cleaned = filename.replaceAll('.jpg', '.jpeg');
    return "assets/ielts/picture/$seriesId/$cleaned";
  }
}
