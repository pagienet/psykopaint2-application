package net.psykosoft.psykopaint2.assets
{

	import com.junkbyte.console.Cc;

	import flash.display.Bitmap;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.config.Settings;

	import starling.textures.Texture;

	public class AssetManager
	{
		[Embed(source="../../../../../assets/images/PsykopaintLogo500x230.jpg")]
		private static var LogoImageAsset:Class;

		[Embed(source="../../../../../assets/images/barViewBg.png")]
		private static var NavigationBackgroundImageAsset:Class;

		// Available assets ( must be reported on the initialize() method ).
		public static const NavigationBackgroundImage:String = "NavigationBackgroundImage";
		public static const LogoImage:String = "LogoImageAsset";

		private static function initialize():void {
			_assets = new Dictionary();
			_assets[ NavigationBackgroundImage ] = NavigationBackgroundImageAsset;
			_assets[ LogoImage ] = LogoImageAsset;
			_initialized = true;
		}

		private static var _assets:Dictionary;
		private static var _initialized:Boolean;

		public static function getBitmapDataByName( name:String ):BitmapData {
			if( !_initialized ) initialize();
			var assetClass:Class = _assets[ name ];
			if( !assetClass ) Cc.fatal( "AssetManager.as - the asset [ " + name + " ] does not exist." );
			var bitmap:Bitmap = new assetClass() as Bitmap;
			return bitmap.bitmapData;
		}

		public static function getTextureByName( name:String ):Texture {
			return Texture.fromBitmapData( getBitmapDataByName( name ), false, false, Settings.CONTENT_SCALE_FACTOR );
		}
	}
}
