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
		private static var LogoTextureAsset:Class;

		[Embed(source="../../../../../assets/images/barViewBg.png")]
		private static var NavigationBackgroundTextureAsset:Class;

		// Available assets ( must be reported on the initialize() method ).
		public static const NavigationBackgroundTexture:uint = 0;
		public static const LogoTexture:uint = 1;
		public static const WhiteTexture:uint = 2;
		public static const RedTexture:uint = 3;

		private static function initialize():void {

			_textures = new Dictionary();
			_rawAssetData = new Dictionary();

			// Register individual bitmaps.
			_rawAssetData[ NavigationBackgroundTexture ] = NavigationBackgroundTextureAsset;
			_rawAssetData[ LogoTexture ] = LogoTextureAsset;

			// Register generative textures.
			_textures[ WhiteTexture ] = generateTextureOfColor( 0xFFFFFF );
			_textures[ RedTexture ] = generateTextureOfColor( 0xFF0000 );

			_initialized = true;
		}

		private static var _rawAssetData:Dictionary;
		private static var _textures:Dictionary;
		private static var _initialized:Boolean;

		public static function getTextureById( id:uint ):Texture {
			if( !_initialized ) initialize();
			if( _textures[ id ] ) return _textures[ id ];
			var texture:Texture = Texture.fromBitmapData( getBitmapDataById( id ), false, false, Settings.CONTENT_SCALE_FACTOR );
			_textures[ id ] = texture;
			return texture;
		}

		private static function getBitmapDataById( id:uint ):BitmapData {
			var assetClass:Class = _rawAssetData[ id ];
			if( !assetClass ) Cc.fatal( "AssetManager.as - the asset [ " + id + " ] does not exist." );
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
