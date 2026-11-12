class ReceiptOcr {
  static const isSupported = false;

  static Future<String> recognize(String imagePath) {
    throw UnsupportedError('OCR hanya tersedia di Android dan iOS.');
  }
}
