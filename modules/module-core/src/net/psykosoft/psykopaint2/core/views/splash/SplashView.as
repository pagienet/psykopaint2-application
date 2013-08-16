package net.psykosoft.psykopaint2.core.views.splash
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import org.osflash.signals.Signal;

	public class SplashView extends Sprite
	{
		// TODO: embed lower res on non retina?
		[Embed(source="../../../../../../../../../modules/module-core/assets/embedded/images/launch/ipad-hr/Default-Landscape@2x.png")]
		public static var SplashImageAsset:Class;
		[Embed(source="../../../../../../../../../modules/module-core/assets/embedded/images/launch/ipad-hr/homePainting.jpg")]
		public static var PaintingImageAsset:Class;

		[Embed(source="../../../../../../../../../modules/module-core/assets/packaged/core-packaged/swf/quotes.swf", symbol="quotes")]
		private var QuotesAsset:Class;

		private var _splashScreen:Sprite;
		private var _splashScreenBM:Bitmap;
		private var _splashScreen1BM:Bitmap;
		private var _quotes:MovieClip;

		public var fadeOutCompleteSignal:Signal;

		public function SplashView() {
			super();
			initSplashScreen();
		}

		private function initSplashScreen():void {

			fadeOutCompleteSignal = new Signal();

			_splashScreen = new Sprite();
			addChild( _splashScreen );

			_splashScreenBM = new SplashImageAsset();
			_splashScreenBM.scaleX = _splashScreenBM.scaleY = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 1 : 0.5;
			if( CoreSettings.TINT_SPLASH_SCREEN ) {
				_splashScreenBM.transform.colorTransform = new ColorTransform( -1, -1, -1, 1, 255, 255, 255 );
			}
			_splashScreen.addChild( _splashScreenBM );

			_splashScreen1BM = new PaintingImageAsset();
			_splashScreen1BM.scaleX = _splashScreen1BM.scaleY = _splashScreenBM.scaleX;
			_splashScreen1BM.visible = false;
			_splashScreen1BM.alpha = 0;
			_splashScreen.addChild( _splashScreen1BM );

			_quotes = MovieClip( new QuotesAsset() );
			_quotes.scaleX = _quotes.scaleY = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 2 : 1;
			_quotes.x = 0;
			_quotes.y = 50 * CoreSettings.GLOBAL_SCALING;
			_quotes.gotoAndStop( Math.floor( 16 * Math.random() ) + 1 );
			_splashScreen.addChild( _quotes );
		}

		private function fadeScreens():void {
			_splashScreen1BM.visible = true;
			TweenLite.to( _splashScreen1BM, 1, { alpha: 1, ease: Strong.easeIn, onComplete: onFadeComplete } );
		}

		private function onFadeComplete():void {
			trace( this, "removing splash, done" );
			removeChild( _splashScreen );
			_splashScreenBM.bitmapData.dispose();
			_splashScreen1BM.bitmapData.dispose();
			_splashScreenBM = null;
			_splashScreen1BM = null;
			_quotes = null;
			_splashScreen = null;
			fadeOutCompleteSignal.dispatch();
		}

		public function removeSplashScreen():void {
			trace( this, "removing splash, fading... ---------------" );
			fadeScreens();
		}
	}
}
