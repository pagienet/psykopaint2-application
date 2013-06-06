package net.psykosoft.psykopaint2.core.managers.gestures
{

	import flash.display.Stage;

	import net.psykosoft.psykopaint2.core.signals.NotifyBlockingGestureSignal;

	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;

	import org.gestouch.core.Gestouch;
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.PanGestureDirection;
	import org.gestouch.gestures.SwipeGesture;
	import org.gestouch.gestures.SwipeGestureDirection;
	import org.gestouch.gestures.TapGesture;
	import org.gestouch.gestures.ZoomGesture;
	import org.gestouch.input.NativeInputAdapter;

	public class GestureManager
	{
		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyBlockingGestureSignal:NotifyBlockingGestureSignal;

		private var _stage:Stage;

		public function GestureManager() {
		}

		public function set stage( value:Stage ):void {
			_stage = value;
			Gestouch.inputAdapter = new NativeInputAdapter( _stage, true, true );
			initializeGestures();
		}

		private function initializeGestures():void {
//			initTwoFingerVerticalSwipe();
			initOneFingerHorizontalPan();
			initOneFingerVerticalPan();
//			initPinch();
//			initTap();
		}

		// ---------------------------------------------------------------------
		// 1 finger, horizontal pan.
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

		// ---------------------------------------------------------------------
		// 1 finger, vertical pan.
		// ---------------------------------------------------------------------

		private function initOneFingerVerticalPan():void {
			var panGestureVertical:PanGesture = new PanGesture( _stage );
			panGestureVertical.direction = PanGestureDirection.VERTICAL;
			panGestureVertical.addEventListener( GestureEvent.GESTURE_BEGAN, onVerticalPanGestureBegan );
			panGestureVertical.addEventListener( GestureEvent.GESTURE_ENDED, onVerticalPanGestureEnded );
		}

		private function onVerticalPanGestureBegan( event:GestureEvent ):void {
			notifyGlobalGestureSignal.dispatch( GestureType.VERTICAL_PAN_GESTURE_BEGAN );
		}

		private function onVerticalPanGestureEnded( event:GestureEvent ):void {
			notifyGlobalGestureSignal.dispatch( GestureType.VERTICAL_PAN_GESTURE_ENDED );
		}

		// ---------------------------------------------------------------------
		// Tap.
		// ---------------------------------------------------------------------

		/*private var _tapGesture:TapGesture;

		private function initTap():void {
			// TODO: do we need the tap gesture here?
			_tapGesture = new TapGesture( _stage );
			_tapGesture.addEventListener( GestureEvent.GESTURE_RECOGNIZED, onTapGestureRecognized );
		}

		private function onTapGestureRecognized( event:GestureEvent ):void {
			trace( this, "tap recognized" );
		}*/

		// ---------------------------------------------------------------------
		// Pinch.
		// ---------------------------------------------------------------------

		/*private var _pinchGesture:ZoomGesture;
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
		}*/

		// ---------------------------------------------------------------------
		// Two finger vertical swipe.
		// ---------------------------------------------------------------------

		/*private function initTwoFingerVerticalSwipe():void {

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
			notifyBlockingGestureSignal.dispatch( false );
		}

		private function onTwoFingerSwipeDown( event:GestureEvent ):void {
			notifyGlobalGestureSignal.dispatch( GestureType.TWO_FINGER_SWIPE_DOWN );
			notifyBlockingGestureSignal.dispatch( false );
		}*/
	}
}
