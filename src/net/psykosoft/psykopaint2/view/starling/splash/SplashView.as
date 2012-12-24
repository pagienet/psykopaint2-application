package net.psykosoft.psykopaint2.view.starling.splash
{

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import net.psykosoft.psykopaint2.assets.starling.StarlingTextureAssetsManager;
	import net.psykosoft.psykopaint2.view.starling.base.StarlingViewBase;

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

			// White Bg.
			_bg = new Image( StarlingTextureAssetsManager.getTextureById( StarlingTextureAssetsManager.WhiteTexture ) );
			addChild( _bg );

			// Display logo.
			_logo = new Image( StarlingTextureAssetsManager.getTextureById( StarlingTextureAssetsManager.LogoTexture ) );
			addChild( _logo );

			// Start auto death timer.
			_autoDieTimer = new Timer( 5000, 1 );
			_autoDieTimer.addEventListener( TimerEvent.TIMER, onDieTimer );
			_autoDieTimer.start();
		}

		override protected function onStageAvailable():void {

			// Listen for stage clicks.
			stage.addEventListener( TouchEvent.TOUCH, onStageTouched );

			super.onStageAvailable();

		}

		override public function disable():void {

			if( _autoDieTimer ) {
				_autoDieTimer.stop();
			}

			super.disable();
		}

		private function onDieTimer( event:TimerEvent ):void {
			die();
		}

		private function onStageTouched( event:TouchEvent ):void {
			var touches:Vector.<Touch> = event.getTouches( this );
			for( var i:uint = 0; i < touches.length; i++ ) {
				var touch:Touch = touches[ i ];
				if( touch.phase == TouchPhase.BEGAN ) { // began acts as a mouse down
					stage.removeEventListener( TouchEvent.TOUCH, onStageTouched );
					die();
				}
			}
		}

		override protected function onLayout():void {

			// Fit bg.
			_bg.width = stage.stageWidth;
			_bg.height = stage.stageHeight;

			// Center logo.
			_logo.x = stage.stageWidth / 2 - _logo.width / 2;
			_logo.y = stage.stageHeight / 2 - _logo.height / 2;

		}

		override public function dispose():void {

			// Make sure texture is freed ( logo will probably not be used again ).
			_logo.texture.dispose();
			_logo.dispose();
			_logo = null;

			// Clear bg, but not its texture.
			_bg.dispose();
			_bg = null;

			super.dispose();
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
