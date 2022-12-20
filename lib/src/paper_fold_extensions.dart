part of 'paper_fold.dart';

/// Different extensions helper.
/// Only needed in this package.
extension on Offset {
  /// Multiply two offsets in a direct way.
  Offset multiplyWithOffset(Offset other) {
    return Offset(dx * other.dx, dy * other.dy);
  }

  /// Multiply an Offset with a Size
  Offset multiplyWithSize(Size other) {
    return Offset(dx * other.width, dy * other.height);
  }
}

extension on Size {
  ///Divide a Size by an integer.
  Size divideByNumber(int value) {
    return Size(width / value, height / value);
  }
}

/// Extension to get an offset of the axis.
/// Use this to avoid if else blocs.
extension on PaperFoldMainAxis {
  Offset get offset {
    if (this == PaperFoldMainAxis.horizontal ) {
      return const Offset(1, 0);
    }
    return const Offset(0, 1);
  }
}