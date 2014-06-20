package net.psykosoft.psykopaint2.core.views.splash
{

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	public class SplashView extends Sprite
	{
		// TODO: embed lower res on non retina?
		[Embed(source="../../../../../../../../../modules/module-core/assets/embedded/images/launch/ipad-hr/Default-Landscape2x.png")]
		public static var SplashImageAsset:Class;
		
		[Embed(source="../../../../../../../../../modules/module-core/assets/packaged/core-packaged/swf/quotes.swf", symbol="quotes")]
		private var QuotesAsset:Class;

		private var _splashScreen:Sprite;
		private var _splashScreenBM:Bitmap;
		private var _quotes:MovieClip;

		public function SplashView() {
			super();
			initSplashScreen();
		}

		private function initSplashScreen():void {

			_splashScreen = new Sprite();
			addChild( _splashScreen );

			_splashScreenBM = new SplashImageAsset();
			_splashScreenBM.scaleX = _splashScreenBM.scaleY = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 1 : 0.5;
			if( CoreSettings.TINT_SPLASH_SCREEN ) {
				_splashScreenBM.transform.colorTransform = new ColorTransform( -1, -1, -1, 1, 255, 255, 255 );
			}
			_splashScreen.addChild( _splashScreenBM );

			_quotes = MovieClip( new QuotesAsset() );
			_quotes.scaleX = _quotes.scaleY = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 2 : 1;
			_quotes.x = 0;
			_quotes.y = 50 * CoreSettings.GLOBAL_SCALING;
			_quotes.gotoAndStop( Math.floor( 16 * Math.random() ) + 1 );
			_splashScreen.addChild( _quotes );
		}

		public function dispose():void {
			trace( this, "removing splash ---------------" );
			removeChild( _splashScreen );
			_splashScreenBM.bitmapData.dispose();
			_splashScreenBM = null;
			_quotes = null;
			_splashScreen = null;
		}
	}
}
