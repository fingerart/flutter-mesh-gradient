import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Controls the animation state for an [AnimatedMeshGradient] widget.
///
/// This controller uses a [ValueNotifier] to manage the animation state, allowing
/// widgets to react to changes in animation status.
class AnimatedMeshGradientController extends Listenable
    with AnimationEagerListenerMixin, AnimationLocalListenersMixin {
  AnimatedMeshGradientController({
    required TickerProvider vsync,
  }) {
    _ticker = vsync.createTicker(_tick);
  }

  Ticker? _ticker;

  /// Recreates the [Ticker] with the new [TickerProvider].
  void resync(TickerProvider vsync) {
    final Ticker oldTicker = _ticker!;
    _ticker = vsync.createTicker(_tick);
    _ticker!.absorbTicker(oldTicker);
  }

  /// The amount of time that has passed between the time the animation started
  /// and the most recent tick of the animation.
  ///
  /// If the controller is not animating, the last elapsed duration is null.
  Duration? get lastElapsedDuration => _lastElapsedDuration;
  Duration? _lastElapsedDuration;

  /// Whether this animation is currently animating in either the forward or reverse direction.
  ///
  /// This is separate from whether it is actively ticking. An animation
  /// controller's ticker might get muted, in which case the animation
  /// controller's callbacks will no longer fire even though time is continuing
  /// to pass. See [Ticker.muted] and [TickerMode].
  bool get isAnimating => _ticker != null && _ticker!.isActive;

  /// Starts the animation.
  ///
  /// Sets the value of [isAnimating] to `true`, indicating that the animation
  /// should be running. Widgets listening to this [ValueNotifier] will be
  /// rebuilt to reflect the change in state.
  void start() {
    _ticker!.start();
  }

  /// Stops the animation.
  ///
  /// Sets the value of [isAnimating] to `false`, indicating that the animation
  /// should no longer be running. Widgets listening to this [ValueNotifier]
  /// will be rebuilt to reflect the change in state.
  void stop({bool canceled = true}) {
    assert(
      _ticker != null,
      'AnimationController.stop() called after AnimationController.dispose()\n'
      'AnimationController methods should not be used after calling dispose.',
    );
    _lastElapsedDuration = null;
    _ticker!.stop(canceled: canceled);
  }

  /// Disposes the controller and its resources.
  @override
  void dispose() {
    _ticker!.dispose();
    _ticker = null;
    clearListeners();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    assert(() {
      if (_ticker == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('AnimationController.dispose() called more than once.'),
          ErrorDescription(
              'A given $runtimeType cannot be disposed more than once.\n'),
          DiagnosticsProperty<AnimatedMeshGradientController>(
            'The following $runtimeType object was disposed multiple times',
            this,
            style: DiagnosticsTreeStyle.errorProperty,
          ),
        ]);
      }
      return true;
    }());
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    _lastElapsedDuration = elapsed;
    final double elapsedInSeconds =
        elapsed.inMicroseconds.toDouble() / Duration.microsecondsPerSecond;
    assert(elapsedInSeconds >= 0.0);
    notifyListeners();
  }
}
