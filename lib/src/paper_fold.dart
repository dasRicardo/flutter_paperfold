import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart' as math64;

import 'paper_fold_direction.dart';

part 'paper_fold_extensions.dart';

part 'paper_fold_render_box.dart';

part 'paper_fold_render_box_parent_data.dart';

class PaperFold extends SingleChildRenderObjectWidget {
  /// Number of paper strips, must have a minimum value of 2
  final int strips;

  /// Main axis to fold.
  final PaperFoldMainAxis mainAxis;

  /// Normalized fold value. Can have a value between 0-1.
  ///
  /// 0 = completely folded
  /// 1 = completely unfolded
  final double foldValue;

  /// Perspective distortion factor. This value is used to add perspective distortion.
  final double perspectiveDistortionFactor;

  /// Device pixel ration. Need this for the offscreen child.
  final double pixelRatio;

  /// Set anti aliasing on(true) or off(false)
  /// Default is off
  final bool isAntiAliased;

  /// Filter quality for strip painting.
  /// Default is FilterQuality.none
  final FilterQuality filterQuality;

  /// Constructor
  const PaperFold({
    super.key,
    required Widget child,
    required this.strips,
    required this.foldValue,
    required this.pixelRatio,
    this.isAntiAliased = false,
    this.filterQuality = FilterQuality.none,
    this.mainAxis = PaperFoldMainAxis.horizontal,
    this.perspectiveDistortionFactor = .0025,
  })  : assert(strips > 1, "Failure, strips need top be greater then 1."),
        super(
          child: child,
        );

  @override
  RenderObject createRenderObject(BuildContext context) => PaperFoldRenderBox(
        strips: strips,
        foldValue: foldValue,
        mainAxis: mainAxis,
        perspectiveDistortionFactor: perspectiveDistortionFactor,
        pixelRatio: pixelRatio,
        isAntiAliased: isAntiAliased,
        filterQuality: filterQuality,
      );

  @override
  void updateRenderObject(
      BuildContext context, PaperFoldRenderBox renderObject) {
    renderObject
      ..mainAxis = mainAxis
      ..strips = strips
      ..foldValue = foldValue;
  }
}
