package net.psykosoft.psykopaint2.controller.gestures
{

	import net.psykosoft.psykopaint2.signal.notifications.NotifyGlobalGestureSignal;

	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.PanGestureDirection;
	import org.gestouch.gestures.SwipeGesture;
	import org.gestouch.gestures.SwipeGestureDirection;
	import org.gestouch.gestures.ZoomGesture;

	import starling.display.Stage;

	public class GestureManager
	{
		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		private var _stage:Stage;

		public function GestureManager() {
			super();
		}

		public function set stage( value:Stage ):void {
			_stage = value;
			initializeGestures();
		}

		private function initializeGestures():void {

			trace( this, "initializing textures on stage: " + _stage );

			initTwoFingerVerticalSwipe();
			initOneFingerHorizontalPan();
			initPinch();

		}

		// ---------------------------------------------------------------------
		// Pinch.
		// ---------------------------------------------------------------------

		private var _pinchGesture:ZoomGesture;
		private var _initialPinchDistance:Number;
		private var _finalPinchDistance:Number;

		private function initPinch():void {
			_pinchGesture = new ZoomGesture( _stage );
			_pinchGesture.lockAspectRatio = false;
			_pinchGesture.addEventListener( GestureEvent.GESTURE_BEGAN, onPinchGestureStarted );
			_pinchGesture.addEventListener( GestureEvent.GESTURE_ENDED, onPinchGestureEnded );
			_pinchGesture.addEventListener( GestureEvent.GESTURE_CHANGED, onPinchGestureChanged );
		}

		private function onPinchGestureStarted( event:GestureEvent ):void {
			var x:Number = _pinchGesture.scaleX;
			var y:Number = _pinchGesture.scaleY;
			_initialPinchDistance = Math.sqrt( x * x + y * y );
		}

		private function onPinchGestureEnded( event:GestureEvent ):void {
			var x:Number = _pinchGesture.scaleX;
			var y:Number = _pinchGesture.scaleY;
			_finalPinchDistance = Math.sqrt( x * x + y * y );
			if( _finalPinchDistance - _initialPinchDistance > 0 ) { // grew?
				notifyGlobalGestureSignal.dispatch( GestureType.PINCH_GREW );
			}
			else {
				notifyGlobalGestureSignal.dispatch( GestureType.PINCH_SHRANK );
			}
		}

		private function onPinchGestureChanged( event:GestureEvent ):void {
		}

		// ---------------------------------------------------------------------
		// Two finger vertical swipe.
		// ---------------------------------------------------------------------

		private function initTwoFingerVerticalSwipe():void {

			var twoFingerSwipeGestureUp:SwipeGesture = new SwipeGesture( _stage );
			twoFingerSwipeGestureUp.numTouchesRequired = 2;
			twoFingerSwipeGestureUp.direction = SwipeGestureDirection.UP;
			twoFingerSwipeGestureUp.addEventListener( GestureEvent.GESTURE_RECOGNIZED, onTwoFingerSwipeUp );

			var twoFingerSwipeGestureDown:SwipeGesture = new SwipeGesture( _stage );
			twoFingerSwipeGestureDown.numTouchesRequired = 2;
			twoFingerSwipeGestureDown.direction = SwipeGestureDirection.DOWN;
			twoFingerSwipeGestureDown.addEventListener( GestureEvent.GESTURE_RECOGNIZED, onTwoFingerSwipeDown );
		}

		private function onTwoFingerSwipeUp( event:GestureEvent ):void {
			notifyGlobalGestureSignal.dispatch( GestureType.TWO_FINGER_SWIPE_UP );
		}

		private function onTwoFingerSwipeDown( event:GestureEvent ):void {
			notifyGlobalGestureSignal.dispatch( GestureType.TWO_FINGER_SWIPE_DOWN );
		}

		// ---------------------------------------------------------------------
		// Horizontal pan.
		// ---------------------------------------------------------------------

		private function initOneFingerHorizontalPan():void {
			var panGestureHorizontal:PanGesture = new PanGesture( _stage );
			panGestureHorizontal.direction = PanGestureDirection.HORIZONTAL;
			panGestureHorizontal.addEventListener( GestureEvent.GESTURE_BEGAN, onHorizontalPanGestureBegan );
			panGestureHorizontal.addEventListener( GestureEvent.GESTURE_ENDED, onHorizontalPanGestureEnded );
		}

		private function onHorizontalPanGestureBegan( event:GestureEvent ):void {
			notifyGlobalGestureSignal.dispatch( GestureType.HORIZONTAL_PAN_GESTURE_BEGAN );
		}

		private function onHorizontalPanGestureEnded( event:GestureEvent ):void {
			notifyGlobalGestureSignal.dispatch( GestureType.HORIZONTAL_PAN_GESTURE_ENDED );
		}
	}
}
