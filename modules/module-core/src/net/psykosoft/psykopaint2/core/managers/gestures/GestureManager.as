package net.psykosoft.psykopaint2.core.managers.gestures
{

	import flash.display.Stage;
	
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyBlockingGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal;
	
	import org.gestouch.core.Gestouch;
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.LongPressGesture;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.PanGestureDirection;
	import org.gestouch.gestures.SwipeGesture;
	import org.gestouch.gestures.SwipeGestureDirection;
	import org.gestouch.gestures.TransformGesture;
	import org.gestouch.input.NativeInputAdapter;

	public class GestureManager
	{
		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyBlockingGestureSignal:NotifyBlockingGestureSignal;

		[Inject]
		public var notifyStateChangeSignal:NotifyStateChangeSignal;
		
		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;
		
		private var _stage:Stage;
		
		public static var gesturesEnabled:Boolean = true;
		
		public function GestureManager() {
			
		}
		
		[PostConstruct]
		public function postConstruct() : void
		{
			notifyStateChangeSignal.add( onStateChange );
		}

		public function set stage( value:Stage ):void {
			_stage = value;
			Gestouch.inputAdapter = new NativeInputAdapter( _stage, true, true );
			initializeGestures();
		}

		private function initializeGestures():void {
			initTwoFingerSwipes();
			initOneFingerHorizontalPan();
			initOneFingerVerticalPan();
			initTransform();
			initLongPressGesture();
//			initPinch();
//			initTap();
		}

		// ---------------------------------------------------------------------
		// Two finger swipes.
		// ---------------------------------------------------------------------

		private function initTwoFingerSwipes():void {

			var twoFingerSwipeGestureRight:SwipeGesture = new SwipeGesture( _stage );
			twoFingerSwipeGestureRight.numTouchesRequired = 2;
			twoFingerSwipeGestureRight.direction = SwipeGestureDirection.RIGHT;
			twoFingerSwipeGestureRight.addEventListener( GestureEvent.GESTURE_RECOGNIZED, onTwoFingerSwipeRight );

			var twoFingerSwipeGestureLeft:SwipeGesture = new SwipeGesture( _stage );
			twoFingerSwipeGestureLeft.numTouchesRequired = 2;
			twoFingerSwipeGestureLeft.direction = SwipeGestureDirection.LEFT;
			twoFingerSwipeGestureLeft.addEventListener( GestureEvent.GESTURE_RECOGNIZED, onTwoFingerSwipeLeft );
		}

		private function onTwoFingerSwipeRight( event:GestureEvent ):void {
			if( !gesturesEnabled ) return;
			notifyGlobalGestureSignal.dispatch( GestureType.TWO_FINGER_SWIPE_RIGHT, event );
			notifyBlockingGestureSignal.dispatch( false );
		}

		private function onTwoFingerSwipeLeft( event:GestureEvent ):void {
			if( !gesturesEnabled ) return;
			notifyGlobalGestureSignal.dispatch( GestureType.TWO_FINGER_SWIPE_LEFT, event );
			notifyBlockingGestureSignal.dispatch( false );
		}

		// ---------------------------------------------------------------------
		// 1 finger, horizontal pan.
		// ---------------------------------------------------------------------

		private function initOneFingerHorizontalPan():void {
			var panGestureHorizontal:PanGesture = new PanGesture( _stage );
			panGestureHorizontal.minNumTouchesRequired = panGestureHorizontal.maxNumTouchesRequired = 1;
			panGestureHorizontal.direction = PanGestureDirection.HORIZONTAL;
			panGestureHorizontal.addEventListener( GestureEvent.GESTURE_BEGAN, onHorizontalPanGestureBegan );
			panGestureHorizontal.addEventListener( GestureEvent.GESTURE_ENDED, onHorizontalPanGestureEnded );
		}

		private function onHorizontalPanGestureBegan( event:GestureEvent ):void {
			if ( gesturesEnabled )
				notifyGlobalGestureSignal.dispatch( GestureType.HORIZONTAL_PAN_GESTURE_BEGAN, event );
		}

		private function onHorizontalPanGestureEnded( event:GestureEvent ):void {
		//	if ( gesturesEnabled )
				notifyGlobalGestureSignal.dispatch( GestureType.HORIZONTAL_PAN_GESTURE_ENDED, event );
		}

		// ---------------------------------------------------------------------
		// 1 finger, vertical pan.
		// ---------------------------------------------------------------------

		private function initOneFingerVerticalPan():void {
			var panGestureVertical:PanGesture = new PanGesture( _stage );
			panGestureVertical.minNumTouchesRequired = panGestureVertical.maxNumTouchesRequired = 2;
			panGestureVertical.direction = PanGestureDirection.VERTICAL;
			panGestureVertical.addEventListener( GestureEvent.GESTURE_BEGAN, onVerticalPanGestureBegan );
			panGestureVertical.addEventListener( GestureEvent.GESTURE_ENDED, onVerticalPanGestureEnded );
		}

		private function onVerticalPanGestureBegan( event:GestureEvent ):void {
			if ( gesturesEnabled )
				notifyGlobalGestureSignal.dispatch( GestureType.VERTICAL_PAN_GESTURE_BEGAN, event );
		}

		private function onVerticalPanGestureEnded( event:GestureEvent ):void {
		//	if ( gesturesEnabled )
				notifyGlobalGestureSignal.dispatch( GestureType.VERTICAL_PAN_GESTURE_ENDED, event );
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
 		/*
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
		*/
		
		// ---------------------------------------------------------------------
		// Transform.
		// ---------------------------------------------------------------------
		
		private var _transformGesture:TransformGesture;
		
		private function initTransform():void {
			_transformGesture = new TransformGesture( _stage );
			_transformGesture.enabled = false;
			_transformGesture.addEventListener( GestureEvent.GESTURE_BEGAN, onTransformGestureStarted );
			
		}
		
		private function onTransformGestureStarted( event:GestureEvent ):void {
			if ( gesturesEnabled )
			{
				notifyGlobalGestureSignal.dispatch( GestureType.TRANSFORM_GESTURE_BEGAN, event );
				_transformGesture.addEventListener( GestureEvent.GESTURE_ENDED, onTransformGestureEnded );
				_transformGesture.addEventListener( GestureEvent.GESTURE_CHANGED, onTransformGestureChanged );	
			}
		}
		
		private function onTransformGestureEnded( event:GestureEvent ):void {
			notifyGlobalGestureSignal.dispatch( GestureType.TRANSFORM_GESTURE_ENDED, event );
			_transformGesture.removeEventListener( GestureEvent.GESTURE_ENDED, onTransformGestureEnded );
			_transformGesture.removeEventListener( GestureEvent.GESTURE_CHANGED, onTransformGestureChanged );	
		}
		
		private function onTransformGestureChanged( event:GestureEvent ):void {
			notifyGlobalGestureSignal.dispatch( GestureType.TRANSFORM_GESTURE_CHANGED, event );
		}
		
		
		// ---------------------------------------------------------------------
		// Long Press.
		// ---------------------------------------------------------------------
		
		private var _longPressGesture:LongPressGesture;
		
		private function initLongPressGesture():void {
			_longPressGesture = new LongPressGesture( _stage );
			_longPressGesture.minPressDuration = 230;
			_longPressGesture.addEventListener( GestureEvent.GESTURE_BEGAN, onLongPressGestureStarted );
			
		}
		
		private function onLongPressGestureStarted( event:GestureEvent ):void {
			if ( gesturesEnabled )
			{
				notifyGlobalGestureSignal.dispatch( GestureType.LONG_PRESS_GESTURE_BEGAN, event );
			}
		}
		
		protected function onStateChange( newState:String ):void {
			_transformGesture.enabled = ( newState == StateType.PAINT_TRANSFORM );
		}
	}
}
