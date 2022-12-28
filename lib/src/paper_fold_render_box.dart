part of 'paper_fold.dart';

class PaperFoldRenderBox extends RenderProxyBox {
  /// The transform matrix for a strip. We need two because odd strips need
  /// another matrix than even strips.
  ///
  /// The values are only calculated in _performDryLayout.
  /// It is not necessary to calculate it every time on painting.
  final List<Matrix4> _stripTransforms = List.filled(2, Matrix4.identity());

  /// This color value is fix.
  final _baseGradientColor = const Color.fromARGB(5, 20, 20, 20);

  /// Pixelratio for offScreenChild.
  final double _pixelRatio;

  /// This is the perspective matrix. All matrices will multiply with this to
  /// get the perspective effect we want.
  final Matrix4 _perspectiveMatrix;

  /// Set anti aliasing on(true) or off(false)
  /// Default is off
  final bool _isAntiAliased;

  /// Filter quality for strip painting.
  /// Default is FilterQuality.none
  final FilterQuality _filterQuality;

  /// The size of one strip for the main axis.
  ///
  /// The value is only calculated in _performDryLayout.
  /// It is not necessary to calculate it every time on painting.
  Size _axialStripContentSize = Size.zero;

  /// This is the offset of the strip content for the main axis.
  ///
  /// The value is only calculated in _performDryLayout.
  /// It is not necessary to calculate it every time on painting.
  Offset _axialStripContentOffset = Offset.zero;

  /// This is the offset after the rotation to align all strips on both axis.
  ///
  /// dx = horizontal, dy = vertical
  /// The value is only calculated in _performDryLayout.
  /// It is not necessary to calculate it every time on painting.
  Offset _axialStripOffset = Offset.zero;

  /// This is needed for the transform to move the strips into the center of
  /// the "camera" on the main axis.
  Offset _perspectiveCorrectionOffset = Offset.zero;

  /// Number of strips. Can any value >= 1
  int _strips = 1;

  /// Fold value
  double _foldValue = 1.0;

  /// Main axis
  PaperFoldMainAxis _mainAxis = PaperFoldMainAxis.horizontal;

  /// Gradients to fake shadows if strips folded together.
  ///
  /// Two gradients needed because the colors need to be swapped for odd strips.
  /// The values are only calculated in _performDryLayout.
  /// It is not necessary to calculate it every time on painting.
  final List<Gradient?> _gradients = List.filled(2, null);

  /// Offscreen picture of the child. The child is drawn on this picture and
  /// used to paint the strips.
  ///
  /// This picture is created once if @[_foldValue] is < 1.0 and disposed if
  /// @[_foldValue] is 1.0.
  Picture? _offscreenChild;

  /// Offscreen picture size of the child.
  Size _offscreenChildSize = Size.zero;

  /// Set the strip value, is used to determine if the RenderBox need to be updated.
  set strips(int value) {
    if (_strips == value || value == 0) return;
    _strips = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  /// Set the fold value, is used to determine if the RenderBox need to be updated.
  set foldValue(double value) {
    if (_foldValue == value) return;
    _foldValue = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  /// Set the main axis value, is used to determine if the RenderBox need to be updated.
  set mainAxis(PaperFoldMainAxis value) {
    if (value == _mainAxis) return;
    _mainAxis = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing {
    return _foldValue > 0 && _foldValue < 1;
  }

  /// Constructor
  PaperFoldRenderBox({
    required int strips,
    required double foldValue,
    required PaperFoldMainAxis mainAxis,
    required double pixelRatio,
    required bool isAntiAliased,
    required FilterQuality filterQuality,
    double perspectiveDistortionFactor = .0015,
  })  : _pixelRatio = pixelRatio,
        _strips = strips,
        _foldValue = foldValue <= 1 && foldValue >= 0 ? foldValue : 1,
        _mainAxis = mainAxis,
        _isAntiAliased = isAntiAliased,
        _filterQuality = filterQuality,
        _perspectiveMatrix = Matrix4.identity()
          ..setEntry(3, 2, perspectiveDistortionFactor);

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return _foldValue == 1 && super.hitTest(result, position: position);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _PaperFoldRenderBoxParentData) {
      child.parentData = _PaperFoldRenderBoxParentData();
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _performDryLayout(
        constraints: constraints,
        layoutChild: ChildLayoutHelper.dryLayoutChild);
  }

  @override
  void performLayout() {
    size = _performDryLayout(
        constraints: constraints, layoutChild: ChildLayoutHelper.layoutChild);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    /// Nothing to paint.
    if (size.isEmpty || child == null || _foldValue == 0) return;

    /// Complete unfolded so paint only firstChild and were are done.
    if (_foldValue == 1) {
      context.paintChild(child!, offset);
      _offscreenChild?.dispose();
      _offscreenChild = null;
      return;
    }

    final mainAxisOffset = _mainAxis.offset;
    var clipRectBounds = Rect.fromLTRB(
      0,
      0,
      _axialStripContentSize.width,
      _axialStripContentSize.height,
    );

    if (_offscreenChild == null) {
      final offsetLayer = OffsetLayer(offset: offset);
      context.pushLayer(offsetLayer, (layerContext, layerOffset) {
        layerContext.paintChild(child!, Offset.zero);
      }, Offset.zero);
      _generateOffscreenChild(offsetLayer);
    } else {
      for (double stripIndex = 0; stripIndex < _strips; stripIndex++) {
        final oddEvenValue = stripIndex % 2;
        final Offset stripOffset =
            _axialStripOffset.multiplyWithOffset(mainAxisOffset) *
                (stripIndex + oddEvenValue);
        final fullTransformOffset =
            offset + stripOffset + _perspectiveCorrectionOffset;
        callback(PaintingContext maskContext, Offset maskOffset) {
          maskContext.canvas.save();
          maskContext.canvas.translate(maskOffset.dx, maskOffset.dy);
          maskContext.canvas.drawPicture(_offscreenChild!);
          maskContext.canvas.restore();
        }

        _paintStrip(
          context,
          clipRectBounds,
          fullTransformOffset,
          _axialStripContentOffset * stripIndex,
          _stripTransforms[oddEvenValue.toInt()],
          _gradients[oddEvenValue.toInt()]!,
          callback,
        );
      }
    }
  }

  /// Create a picture of the child. This picture is drawn on on all strips.
  Future<void> _generateOffscreenChild(OffsetLayer offsetLayer) async {
    if (_offscreenChild != null) return;
    final image = await offsetLayer.toImage(Offset.zero & _offscreenChildSize,
        pixelRatio: _pixelRatio);
    final recorder = PictureRecorder();
    final imageCanvas = Canvas(recorder);
    paintImage(
        isAntiAlias: _isAntiAliased,
        image: image,
        rect: Offset.zero & _offscreenChildSize,
        canvas: imageCanvas,
        fit: BoxFit.scaleDown,
        filterQuality: _filterQuality);
    _offscreenChild = recorder.endRecording();
    markNeedsPaint();
  }

  /// Painting a single strip.
  ///
  /// Add the clipping and transformation.
  void _paintStrip(
    PaintingContext context,
    Rect clipRectBounds,
    Offset offset,
    Offset clipRectOffset,
    Matrix4 transform,
    Gradient gradient,
    PaintingContextCallback painterCallback,
  ) {
    final layer = ShaderMaskLayer()
      ..shader = gradient.createShader(Offset.zero & _axialStripContentSize)
      ..maskRect = offset & _axialStripContentSize
      ..blendMode = BlendMode.srcATop;

    context.pushTransform(
      needsCompositing,
      offset,
      transform,
      (pushTransformContext, pushTransformOffset) {
        pushTransformContext.pushClipRect(
          needsCompositing,
          pushTransformOffset,
          clipRectBounds,
          (pushClipRectContext, pushClipRectOffset) {
            pushClipRectContext.pushLayer(
              layer,
              painterCallback,
              pushClipRectOffset - clipRectOffset,
            );
          },
        );
      },
    );
  }

  /// Calculate the parent RenderBox size.
  /// Calculate all needed values for later painting.
  Size _performDryLayout(
      {required BoxConstraints constraints,
      required ChildLayouter layoutChild}) {
    if (child == null) {
      return Size.zero;
    }

    final contentSize = layoutChild(child!, constraints);
    _offscreenChildSize = contentSize;

    if (contentSize.width == 0 || contentSize.height == 0 || _foldValue == 1) {
      return contentSize;
    }

    final mainAxisOffset = _mainAxis.offset;
    if (_foldValue == 0) {
      return Size(contentSize.width * mainAxisOffset.dy,
          contentSize.height * mainAxisOffset.dx);
    }

    /// Angle in radiance for a given fold value.
    ///
    /// All strips have the same angle.
    var radiance = math64.radians(90 - 90 * _foldValue);
    if (_mainAxis == PaperFoldMainAxis.horizontal) {
      radiance *= -1;
    }

    _axialStripContentSize = _calculateStripContentSize(
      contentSize.divideByNumber(_strips),
      contentSize,
      mainAxisOffset,
    );

    _axialStripOffset = _calculateStripOffset(
      radiance,
      mainAxisOffset,
    );

    _axialStripContentOffset =
        mainAxisOffset.multiplyWithSize(_axialStripContentSize);

    final finalContentSize = Size(
      _axialStripOffset.dx * _strips +
          _axialStripContentSize.width * mainAxisOffset.dy,
      _axialStripOffset.dy * _strips +
          _axialStripContentSize.height * mainAxisOffset.dx,
    );

    _perspectiveCorrectionOffset = Offset(
      mainAxisOffset.dy * finalContentSize.width / 2,
      mainAxisOffset.dx * finalContentSize.height / 2,
    );

    _setupGradients();
    _setupStripMatrix(radiance, mainAxisOffset);

    return finalContentSize;
  }

  /// Calculate the offset of a rotated strip to align all strips together.
  ///
  /// The result depends on the main axis.
  Offset _calculateStripOffset(double radiance, Offset mainAxisOffset) {
    final transform = Matrix4.identity()
      ..multiply(_perspectiveMatrix)
      ..rotate(
          math64.Vector3(mainAxisOffset.dy, mainAxisOffset.dx, 0.0), radiance);
    return MatrixUtils.transformPoint(
      transform,
      mainAxisOffset.multiplyWithSize(_axialStripContentSize),
    );
  }

  /// Calculate the content size of a strip depending on the main axis.
  Size _calculateStripContentSize(
      Size stripSize, Size contentSize, Offset mainAxisOffset) {
    return Size(
      stripSize.width * mainAxisOffset.dx +
          contentSize.width * mainAxisOffset.dy,
      stripSize.height * mainAxisOffset.dy +
          contentSize.height * mainAxisOffset.dx,
    );
  }

  /// Setup the transform matrix for the strips.
  ///
  /// We need a different matrix for even and odd strips.
  void _setupStripMatrix(double radiance, Offset mainAxisOffset) {
    final axialStripContentOffset =
        mainAxisOffset.multiplyWithOffset(_axialStripContentOffset);

    _stripTransforms[0] = Matrix4.identity()
      ..multiply(_perspectiveMatrix)
      ..rotate(
        math64.Vector3(mainAxisOffset.dy, mainAxisOffset.dx, 0.0),
        radiance,
      )
      ..translate(
        -_perspectiveCorrectionOffset.dx,
        -_perspectiveCorrectionOffset.dy,
      );

    _stripTransforms[1] = Matrix4.identity()
      ..multiply(_perspectiveMatrix)
      ..rotate(
        math64.Vector3(mainAxisOffset.dy, mainAxisOffset.dx, 0.0),
        radiance * -1,
      )
      ..translate(
        -_perspectiveCorrectionOffset.dx - axialStripContentOffset.dx,
        -_perspectiveCorrectionOffset.dy - axialStripContentOffset.dy,
      );
  }

  /// Setup the gradients to fake the shadow effect.
  ///
  /// We need different gradient for even and odd strips.
  void _setupGradients() {
    final foldColor = Color.fromARGB(150 - (150 * _foldValue).toInt(), 0, 0, 0);
    final begin = _mainAxis == PaperFoldMainAxis.horizontal
        ? Alignment.centerLeft
        : Alignment.topCenter;
    final end = _mainAxis == PaperFoldMainAxis.horizontal
        ? Alignment.centerRight
        : Alignment.bottomCenter;

    _gradients[0] = LinearGradient(
      begin: begin,
      end: end,
      colors: [_baseGradientColor, foldColor],
    );
    _gradients[1] = LinearGradient(
      begin: begin,
      end: end,
      colors: [foldColor, _baseGradientColor],
    );
  }
}
