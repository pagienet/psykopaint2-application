package net.psykosoft.psykopaint2.view.starling.base
{

	import com.junkbyte.console.Cc;

	import feathers.controls.Button;
	import feathers.core.DisplayListWatcher;

	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.view.starling.navigation.NavigationView;
	import net.psykosoft.psykopaint2.view.starling.popups.base.PopUpManagerView;
	import net.psykosoft.psykopaint2.view.starling.selectimage.SelectImageView;
	import net.psykosoft.psykopaint2.view.starling.splash.SplashView;

	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.SwipeGesture;
	import org.gestouch.gestures.SwipeGestureDirection;
	import org.gestouch.gestures.TapGesture;
	import org.osflash.signals.Signal;

	import starling.display.Sprite;
	import starling.events.Event;

	public class StarlingRootSprite extends StarlingViewBase
	{
		private var _mainLayer:Sprite;
		private var _debugLayer:Sprite;

		public var swipedUpSignal:Signal;
		public var swipedDownSignal:Signal;

		public function StarlingRootSprite() {
			super();
			swipedUpSignal = new Signal();
			swipedDownSignal = new Signal();
		}

		override protected function onStageAvailable():void {

			// -----------------------
			// Ui theme.
			// -----------------------

			var theme:DisplayListWatcher = new Psykopaint2Ui( stage, Settings.RUNNING_ON_HD );

			// -----------------------
			// Layering.
			// -----------------------

			addChild( _mainLayer = new Sprite() );
			if( Settings.ENABLE_DEBUG_CONSOLE ) {
				addChild( _debugLayer = new Sprite() );
			}

			// -----------------------
			// << VIEWS >>.
			// -----------------------

			_mainLayer.addChild( new SelectImageView() );
			_mainLayer.addChild( new NavigationView() );
			_mainLayer.addChild( new PopUpManagerView() );
			if( Settings.SHOW_SPLASH_SCREEN ) {
				_mainLayer.addChild( new SplashView() );
			}

			// -----------------------
			// Global gestures.
			// -----------------------

			var globalSwipeGestureUp:SwipeGesture = new SwipeGesture( stage );
			globalSwipeGestureUp.numTouchesRequired = 2;
			globalSwipeGestureUp.direction = SwipeGestureDirection.UP;
			globalSwipeGestureUp.addEventListener( GestureEvent.GESTURE_RECOGNIZED, onGlobalSwipeGestureUp );

			var globalSwipeGestureDown:SwipeGesture = new SwipeGesture( stage );
			globalSwipeGestureDown.numTouchesRequired = 2;
			globalSwipeGestureDown.direction = SwipeGestureDirection.DOWN;
			globalSwipeGestureDown.addEventListener( GestureEvent.GESTURE_RECOGNIZED, onGlobalSwipeGestureDown );

			// -----------------------
			// Debugging console.
			// -----------------------

			if( Settings.ENABLE_DEBUG_CONSOLE ) {
			    // Place a little button at the left corner of the app for toggling the console.
				var button:Button = new Button();
				button.label = "console";
				button.x = Settings.SHOW_STATS ? 50 : 0;
				button.addEventListener( Event.TRIGGERED, onConsoleButtonTriggered );
				_debugLayer.addChild( button );
			}

			super.onStageAvailable();
		}

		private function onConsoleButtonTriggered( event:Event ):void {
			Cc.visible = !Cc.visible;
		}

		// ---------------------------------------------------------------------
		// Gesture handlers.
		// ---------------------------------------------------------------------

		private function onGlobalSwipeGestureUp( event:GestureEvent ):void {
			trace( "swiped up!" );
			swipedUpSignal.dispatch();
		}

		private function onGlobalSwipeGestureDown( event:GestureEvent ):void {
			trace( "swiped down!" );
			swipedDownSignal.dispatch();
		}
	}
}