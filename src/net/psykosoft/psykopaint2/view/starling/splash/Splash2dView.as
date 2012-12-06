package net.psykosoft.psykopaint2.view.starling.splash
{

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import net.psykosoft.psykopaint2.view.starling.base.StarlingRootSprite;
	import net.psykosoft.psykopaint2.view.starling.base.StarlingViewBase;

	import org.osflash.signals.Signal;

	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	public class Splash2dView extends StarlingViewBase
	{
		[Embed(source="../../../../../../../assets/images/PsykopaintLogo500x230.jpg")]
		private var LogoImage:Class;

		private var _image:Image;
		private var _dieTimer:Timer;

		public var splashDiedSignal:Signal;

		public function Splash2dView() {
			super();
			splashDiedSignal = new Signal();
		}

		override protected function onSetup():void {

			// Listen for stage clicks.
			stage.addEventListener( TouchEvent.TOUCH, onStageTouched );

			// Display logo.
			var texture:Texture = Texture.fromBitmap( new LogoImage() );
			_image = new Image( texture );
			addChild( _image );

			// Start auto death timer.
			_dieTimer = new Timer( 5000, 1 );
			_dieTimer.addEventListener( TimerEvent.TIMER, onDieTimer );
			_dieTimer.start();

			onLayout();

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

			// Center logo.
			_image.x = stage.stageWidth / 2 - _image.width / 2;
			_image.y = stage.stageHeight / 2 - _image.height / 2;

		}

		override public function dispose():void {

			// Make sure texture is freed.
			_image.texture.dispose();
			_image.dispose();
			_image = null;

			super.dispose();
		}

		private function die():void {

			// Dispose timer.
			_dieTimer.removeEventListener( TimerEvent.TIMER, onDieTimer );
			_dieTimer.stop();

			// Notify removal.
			splashDiedSignal.dispatch();

		}
	}
}
