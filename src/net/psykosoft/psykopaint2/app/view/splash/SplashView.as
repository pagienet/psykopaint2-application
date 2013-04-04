package net.psykosoft.psykopaint2.app.view.splash
{

	import com.junkbyte.console.Cc;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import net.psykosoft.psykopaint2.app.assets.starling.StarlingTextureManager;
	import net.psykosoft.psykopaint2.app.assets.starling.data.StarlingTextureType;
	import net.psykosoft.psykopaint2.app.view.base.StarlingViewBase;

	import org.osflash.signals.Signal;

	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class SplashView extends StarlingViewBase
	{
		private var _logo:Image;
		private var _bg:Image;
		private var _autoDieTimer:Timer;

		public var splashDiedSignal:Signal;

		public function SplashView() {
			super();
			splashDiedSignal = new Signal();
		}

		// ---------------------------------------------------------------------
		// Overrides.
		// ---------------------------------------------------------------------

		override protected function onEnabled():void {

			// White Bg.
			_bg = new Image( StarlingTextureManager.getTextureById( StarlingTextureType.TRANSPARENT_WHITE ) );
			_bg.width = stage.stageWidth;
			_bg.height = stage.stageHeight;
			addChild( _bg );

			// Display logo.
			_logo = new Image( StarlingTextureManager.getTextureById( StarlingTextureType.LOGO ) );
			_logo.x = stage.stageWidth / 2 - _logo.width / 2;
			_logo.y = stage.stageHeight / 2 - _logo.height / 2;
			addChild( _logo );

			// Start auto death timer.
			_autoDieTimer = new Timer( 2000, 1 );
			_autoDieTimer.addEventListener( TimerEvent.TIMER, onDieTimer );
			_autoDieTimer.start();

			addEventListener( TouchEvent.TOUCH, onStageTouched );
		}

		override protected function onDisabled():void {

			if( _bg ) {
				removeChild( _bg );
			}

			if( _logo ) {
				removeChild( _logo );
			}

			if( _autoDieTimer ) {
				_autoDieTimer.stop();
			}

			if( hasEventListener( TouchEvent.TOUCH ) ) {
				removeEventListener( TouchEvent.TOUCH, onStageTouched );
			}

		}

		override protected function onDispose():void {

			// TODO: ask texture manager to dispose images?

			if( _bg ) {
				_bg.texture.dispose();
				_bg.dispose();
				_bg = null;
			}

			if( _logo ) {
				_logo.texture.dispose();
				_logo.dispose();
				_logo = null;
			}

			if( _autoDieTimer ) {
				_autoDieTimer = null;
			}

			splashDiedSignal = null;
		}

// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function onStageTouched( event:TouchEvent ):void {
			var touches:Vector.<Touch> = event.getTouches( this );
			for( var i:uint = 0; i < touches.length; i++ ) {
				var touch:Touch = touches[ i ];
				if( touch.phase == TouchPhase.BEGAN ) { // began acts as a mouse down
					removeEventListener( TouchEvent.TOUCH, onStageTouched );
					die();
				}
			}
		}

		private function onDieTimer( event:TimerEvent ):void {
			die();
		}

		private function die():void {

			// Dispose timer.
			_autoDieTimer.removeEventListener( TimerEvent.TIMER, onDieTimer );
			_autoDieTimer.stop();

			// Notify removal.
			splashDiedSignal.dispatch();

		}
	}
}
