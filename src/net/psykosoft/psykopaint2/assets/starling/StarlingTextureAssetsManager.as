package net.psykosoft.psykopaint2.assets.starling
{

	import com.junkbyte.console.Cc;

	import flash.display.Bitmap;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.config.Settings;

	import starling.textures.Texture;

	public class StarlingTextureAssetsManager
	{
		[Embed(source="../../../../../../assets/images/ui/PsykopaintLogo500x230.jpg")]
		private static var LogoTextureAsset:Class;

		[Embed(source="../../../../../../assets/images/ui/barViewBg.png")]
		private static var NavigationBackgroundTextureAsset:Class;

		// Available assets ( must be reported on the constructor ).
		public static const NavigationBackgroundTexture:String = "barViewBg.png";
		public static const LogoTexture:String = "PsykopaintLogo500x230.jpg";
		public static const WhiteTexture:String = "generatedWhite";
		public static const RedTexture:String = "generatedRed";

		public static function initialize() {

			_assets = new Dictionary();
			_rawAssetData = new Dictionary();

			// Register individual bitmaps.
			_rawAssetData[ NavigationBackgroundTexture ] = NavigationBackgroundTextureAsset;
			_rawAssetData[ LogoTexture ] = LogoTextureAsset;

			// Register generative textures.
			// TODO: can avoid generation unless requested?
			_assets[ WhiteTexture ] = generateTextureOfColor( 0xFFFFFF );
			_assets[ RedTexture ] = generateTextureOfColor( 0xFF0000 );

			_initialized = true;

		}

		private static var _rawAssetData:Dictionary;
		private static var _assets:Dictionary;
		private static var _initialized:Boolean;

		public static function getTextureById( id:String ):Texture {
			if( !_initialized ) initialize();
			if( _assets[ id ] ) return _assets[ id ];
			var texture:Texture = Texture.fromBitmapData( getBitmapDataById( id ), false, false, Settings.CONTENT_SCALE_FACTOR );
			_assets[ id ] = texture;
			return texture;
		}

		private static function getBitmapDataById( id:String ):BitmapData {
			var assetClass:Class = _rawAssetData[ id ];
			if( !assetClass ) Cc.fatal( "The asset [ " + id + " ] does not exist." );
			var bitmap:Bitmap = new assetClass() as Bitmap;
			return bitmap.bitmapData;
		}

		private static function generateTextureOfColor( color:uint ):Texture {
			var bmd:BitmapData = new BitmapData( 32, 32, false, color );
			var texture:Texture = Texture.fromBitmapData( bmd, false, false, Settings.CONTENT_SCALE_FACTOR );
			return texture;
		}
	}
}
