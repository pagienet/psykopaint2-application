package net.psykosoft.psykopaint2.core.managers.gestures
{

	import flash.display.Bitmap;
	import flash.display.Stage;
	
	import net.psykosoft.psykopaint2.core.signals.NotifyBlockingGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyToggleSwipeGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyToggleTransformGestureSignal;
	
	import org.gestouch.core.Gestouch;
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.LongPressGesture;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.PanGestureDirection;
	import org.gestouch.gestures.SwipeGesture;
	import org.gestouch.gestures.SwipeGestureDirection;
	import org.gestouch.gestures.TapGesture;
	import org.gestouch.gestures.TransformGesture;
	import org.gestouch.input.NativeInputAdapter;

	public class GestureManager
	{
		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyBlockingGestureSignal:NotifyBlockingGestureSignal;

		[Inject]
		public var toggleTransformGestureSignal:NotifyToggleTransformGestureSignal;
		
		[Inject]
		public var notifyToggleSwipeGestureSignal:NotifyToggleSwipeGestureSignal;
		
		
		
		private var _stage:Stage;
		private var _delegate:GestureDelegate;
		
		private static var _gesturesEnabled:Boolean = false;
		private static var _instance:GestureManager;

		
		private var _swipeGestureRight:SwipeGesture;
		private var _swipeGestureLeft:SwipeGesture;
		private var _panGestureHorizontal:PanGesture;
		private var _panGestureVertical:PanGesture;
		private var _transformGesture:TransformGesture;
		private var _tapGesture:TapGesture;
		private var _doubleTapGesture:TapGesture;
		private var _twoFingerTapGesture:TapGesture;
		private var _longTapGesture:LongPressGesture;
		
		
		public function GestureManager() {
			//KIND OF A HACK. BUT HEY THIS IS MEANT TO BE A SINGLETON!
			_instance = this;
		}
		
		[PostConstruct]
		public function postConstruct() : void
		{
			toggleTransformGestureSignal.add( onToggleTransformGesture );
			notifyToggleSwipeGestureSignal.add( onToggleSwipeGesture );
		}

		private function onToggleTransformGesture( value:Boolean ):void {
			_transformGesture.enabled = value;
		}
		
		private function onToggleSwipeGesture( value:Boolean ):void {
			_swipeGestureRight.enabled = _swipeGestureLeft.enabled = value;
		}

		public function set stage( value:Stage ):void {
			_stage = value;
			Gestouch.inputAdapter = new NativeInputAdapter( _stage, true, true );
			initializeGestures();
		}

		private function initializeGestures():void {

			_delegate = new GestureDelegate();

			initTwoFingerSwipes();
			initOneFingerHorizontalPan();
			initOneFingerVerticalPan();
			initTransformGesture();
			initTapGesture();
		}

		// ---------------------------------------------------------------------
		// Two finger swipes.
		// ---------------------------------------------------------------------


		private function initTwoFingerSwipes():void {

			_swipeGestureRight = new SwipeGesture( _stage );
			_swipeGestureRight.numTouchesRequired = 2;
			_swipeGestureRight.direction = SwipeGestureDirection.RIGHT;
			_swipeGestureRight.addEventListener( GestureEvent.GESTURE_RECOGNIZED, onTwoFingerSwipeRight );
			_swipeGestureRight.delegate = _delegate;

			_swipeGestureLeft = new SwipeGesture( _stage );
			_swipeGestureLeft.numTouchesRequired = 2;
			_swipeGestureLeft.direction = SwipeGestureDirection.LEFT;
			_swipeGestureLeft.addEventListener( GestureEvent.GESTURE_RECOGNIZED, onTwoFingerSwipeLeft );
			_swipeGestureLeft.delegate = _delegate;
		}

		private function onTwoFingerSwipeRight( event:GestureEvent ):void {
//			trace( this, "onTwoFingerSwipeRight" );
			if( !_gesturesEnabled ) return;
			notifyGlobalGestureSignal.dispatch( GestureType.TWO_FINGER_SWIPE_RIGHT, event );
			notifyBlockingGestureSignal.dispatch( false );
		}

		private function onTwoFingerSwipeLeft( event:GestureEvent ):void {
//			trace( this, "onTwoFingerSwipeLeft" );
			if( !_gesturesEnabled ) return;
			notifyGlobalGestureSignal.dispatch( GestureType.TWO_FINGER_SWIPE_LEFT, event );
			notifyBlockingGestureSignal.dispatch( false );
		}

		// ---------------------------------------------------------------------
		// 1 finger, horizontal pan.
		// ---------------------------------------------------------------------

		
		private function initOneFingerHorizontalPan():void {
			_panGestureHorizontal = new PanGesture( _stage );
			_panGestureHorizontal.minNumTouchesRequired = _panGestureHorizontal.maxNumTouchesRequired = 1;
			_panGestureHorizontal.direction = PanGestureDirection.HORIZONTAL;
			_panGestureHorizontal.addEventListener( GestureEvent.GESTURE_BEGAN, onHorizontalPanGestureBegan );
			_panGestureHorizontal.delegate = _delegate;
		}

		private function onHorizontalPanGestureBegan( event:GestureEvent ):void {
//			trace( this, "onHorizontalPanGestureBegan" );
			if ( _gesturesEnabled )
			{
				_panGestureHorizontal.addEventListener( GestureEvent.GESTURE_ENDED, onHorizontalPanGestureEnded );
				notifyGlobalGestureSignal.dispatch( GestureType.HORIZONTAL_PAN_GESTURE_BEGAN, event );
			}
		}
		
		private function onHorizontalPanGestureEnded( event:GestureEvent ):void {
//			trace( this, "onHorizontalPanGestureEnded" );
			_panGestureHorizontal.removeEventListener( GestureEvent.GESTURE_ENDED, onHorizontalPanGestureEnded );
			notifyGlobalGestureSignal.dispatch( GestureType.HORIZONTAL_PAN_GESTURE_ENDED, event );
		}

		// ---------------------------------------------------------------------
		// 1 finger, vertical pan.
		// ---------------------------------------------------------------------

		private function initOneFingerVerticalPan():void {
			_panGestureVertical = new PanGesture( _stage );
			_panGestureVertical.minNumTouchesRequired = _panGestureVertical.maxNumTouchesRequired = 1;
			_panGestureVertical.direction = PanGestureDirection.VERTICAL;
			_panGestureVertical.addEventListener( GestureEvent.GESTURE_BEGAN, onVerticalPanGestureBegan );
			_panGestureVertical.delegate = _delegate;
		}

		private function onVerticalPanGestureBegan( event:GestureEvent ):void {
//			trace( this, "onVerticalPanGestureBegan" );
			if ( _gesturesEnabled )
			{
				_panGestureVertical.addEventListener( GestureEvent.GESTURE_ENDED, onVerticalPanGestureEnded );
				notifyGlobalGestureSignal.dispatch( GestureType.VERTICAL_PAN_GESTURE_BEGAN, event );
			}
		}

		private function onVerticalPanGestureEnded( event:GestureEvent ):void {
//			trace( this, "onVerticalPanGestureEnded" );
			_panGestureVertical.removeEventListener( GestureEvent.GESTURE_ENDED, onVerticalPanGestureEnded );
			notifyGlobalGestureSignal.dispatch( GestureType.VERTICAL_PAN_GESTURE_ENDED, event );
		}

		
		// ---------------------------------------------------------------------
		// Transform.
		// ---------------------------------------------------------------------
		
		private function initTransformGesture():void {
			_transformGesture = new TransformGesture( _stage );
			_transformGesture.enabled = false;
			_transformGesture.addEventListener( GestureEvent.GESTURE_BEGAN, onTransformGestureStarted );
			_transformGesture.delegate = _delegate;
		}
		
		private function onTransformGestureStarted( event:GestureEvent ):void {
//			trace( this, "onTransformGestureStarted" );
			if ( _gesturesEnabled )
			{
				if (TransformGesture( event.target).touchesCount > 1 )
				{
					notifyGlobalGestureSignal.dispatch( GestureType.TRANSFORM_GESTURE_BEGAN, event );
					_transformGesture.addEventListener( GestureEvent.GESTURE_ENDED, onTransformGestureEnded );
					_transformGesture.addEventListener( GestureEvent.GESTURE_CHANGED, onTransformGestureChanged );
				}
			}
		}
		
		private function onTransformGestureEnded( event:GestureEvent ):void {
//			trace( this, "onTransformGestureEnded" );
			notifyGlobalGestureSignal.dispatch( GestureType.TRANSFORM_GESTURE_ENDED, event );
			_transformGesture.removeEventListener( GestureEvent.GESTURE_ENDED, onTransformGestureEnded );
			_transformGesture.removeEventListener( GestureEvent.GESTURE_CHANGED, onTransformGestureChanged );	
		}
		
		private function onTransformGestureChanged( event:GestureEvent ):void {
//			trace( this, "onTransformGestureChanged" );
			notifyGlobalGestureSignal.dispatch( GestureType.TRANSFORM_GESTURE_CHANGED, event );
		}

		// ---------------------------------------------------------------------
		// Tap.
		// ---------------------------------------------------------------------
		
		
		//temporary fix until tap conflict with buttons has been resolved:
		//private var _tapGesture:LongPressGesture;
		
		private function initTapGesture():void {
			
			_longTapGesture = new LongPressGesture( _stage );
			_longTapGesture.minPressDuration = 300;//170;
			_longTapGesture.slop = 0.01;
			_longTapGesture.addEventListener( GestureEvent.GESTURE_BEGAN, onLongTapGestureBegan );
			
			
			_tapGesture = new TapGesture( _stage );
			_tapGesture.addEventListener( GestureEvent.GESTURE_RECOGNIZED, onTapGestureRecognized );
			_tapGesture.maxTapDuration = 100;
		
			
			_twoFingerTapGesture = new TapGesture( _stage );
			_twoFingerTapGesture.numTouchesRequired = 2;
			_twoFingerTapGesture.addEventListener( GestureEvent.GESTURE_RECOGNIZED, onTwoFingerTapGestureRecognized );
			//_tapGesture.addEventListener( GestureEvent.GESTURE_BEGAN, onTapGestureRecognized );
			_twoFingerTapGesture.delegate = _delegate;
		}
		
		private function onTapGestureRecognized( event:GestureEvent ):void {
//			trace( this, "onTapGestureRecognized" );
			if ( _gesturesEnabled )
				notifyGlobalGestureSignal.dispatch( GestureType.TAP_GESTURE_RECOGNIZED, event );
		}
		
		private function onLongTapGestureBegan( event:GestureEvent ):void {
			//			trace( this, "onTapGestureRecognized" );
			//var target:Stage =  Stage(LongPressGesture(event.target).target);
			//var obj:Array = target.getObjectsUnderPoint(LongPressGesture(event.target).location);
			//if (obj.length == 0 || (obj.length == 1 && obj[0] is Bitmap) )
			//{
			if ( _gesturesEnabled )
			{
				notifyGlobalGestureSignal.dispatch( GestureType.LONG_TAP_GESTURE_BEGAN, event );
				_longTapGesture.addEventListener( GestureEvent.GESTURE_ENDED, onLongTapGestureEnded );
			}
			//}
		}
		
		private function onLongTapGestureEnded( event:GestureEvent ):void {
			_longTapGesture.removeEventListener( GestureEvent.GESTURE_ENDED, onLongTapGestureEnded );
			notifyGlobalGestureSignal.dispatch( GestureType.LONG_TAP_GESTURE_ENDED, event );
			
		}
		
		private function onTwoFingerTapGestureRecognized( event:GestureEvent ):void {
//			trace( this, "onTwoFingerTapGestureRecognized" );
			if ( _gesturesEnabled )
			{
				var target:Stage =  Stage(TapGesture(event.target).target);
				var obj:Array = target.getObjectsUnderPoint(TapGesture(event.target).location);
				if (obj.length == 0 || (obj.length == 1 && obj[0] is Bitmap) )
				{
					notifyGlobalGestureSignal.dispatch( GestureType.TWO_FINGER_TAP_GESTURE_RECOGNIZED, event );
				}
			}
		}
		
		// ---------------------------------------------------------------------
		// Double Tap.
		// ---------------------------------------------------------------------
		
		
		private function initDoubleTapGesture():void {
			_doubleTapGesture = new TapGesture( _stage );
			_doubleTapGesture.numTapsRequired = 2;
			_doubleTapGesture.addEventListener( GestureEvent.GESTURE_RECOGNIZED, onDoubleTapGestureRecognized );
			_doubleTapGesture.delegate = _delegate;
		}
		
		private function onDoubleTapGestureRecognized( event:GestureEvent ):void {
//			trace( this, "onTwoFingerTapGestureRecognized" );
			if ( _gesturesEnabled )
			{
				notifyGlobalGestureSignal.dispatch( GestureType.DOUBLE_TAP_GESTURE_RECOGNIZED, event );
			}
		}

		// ---------------------------------------------------------------------
		// Setters & getters.
		// ---------------------------------------------------------------------

		public static function get gesturesEnabled():Boolean {
			return _gesturesEnabled;
		}

		public static function set gesturesEnabled( value:Boolean ):void {
			trace( "GestureManager - gesturesEnabled: " + value );
			_gesturesEnabled = value;
			
			//
			if(value==false){
				if(_instance._panGestureHorizontal.hasEventListener(GestureEvent.GESTURE_ENDED)){
					_instance.onHorizontalPanGestureEnded(null);
				}

			}
				
		}
	}
}
