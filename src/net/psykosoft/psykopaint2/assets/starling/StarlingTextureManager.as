package net.psykosoft.psykopaint2.assets.starling
{

	import com.junkbyte.console.Cc;

	import flash.display.Bitmap;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.assets.starling.data.StarlingTextureType;

	import net.psykosoft.psykopaint2.config.Settings;

	import starling.core.Starling;

	import starling.textures.Texture;

	public class StarlingTextureManager
	{
		[Embed(source="../../../../../../assets-embed/textures/ui/psykopaintLogo_highRes.jpg")]
		private static var LogoTextureAsset:Class;

		[Embed(source="../../../../../../assets-embed/textures/ui/barViewBg_lowRes.png")]
		private static var NavigationBackgroundTextureAsset:Class;

		public static function initialize() {

			_textures = new Dictionary();
			_assets = new Dictionary();

			// Register individual bitmaps.
			_assets[ StarlingTextureType.NAVIGATION_BACKGROUND ] = NavigationBackgroundTextureAsset;
			_assets[ StarlingTextureType.LOGO ] = LogoTextureAsset;

			// Register generative textures.
			// TODO: can avoid generation unless requested?
			_textures[ StarlingTextureType.TRANSPARENT_WHITE ] = generateTextureOfColor( 0x33FFFFFF );
			_textures[ StarlingTextureType.TRANSPARENT_RED ] = generateTextureOfColor( 0x33FF0000 );
			_textures[ StarlingTextureType.TRANSPARENT_GREEN ] = generateTextureOfColor( 0x3300FF00 );
			_textures[ StarlingTextureType.TRANSPARENT ] = generateTextureOfColor( 0x00000000 );
			_textures[ StarlingTextureType.SOLID_GRAY ] = generateTextureOfColor( 0xFF666666 );

			_initialized = true;

		}

		private static var _assets:Dictionary;
		private static var _textures:Dictionary;
		private static var _initialized:Boolean;

		public static function getTextureById( id:String ):Texture {
			if( !_initialized ) initialize();
			if( _textures[ id ] ) return _textures[ id ];
			var texture:Texture = Texture.fromBitmapData( getBitmapDataById( id ), false, false, Starling.contentScaleFactor );
			_textures[ id ] = texture;
			return texture;
		}

		private static function getBitmapDataById( id:String ):BitmapData {
			var assetClass:Class = _assets[ id ];
			if( !assetClass ) Cc.fatal( "The asset [ " + id + " ] does not exist." );
			var bitmap:Bitmap = new assetClass() as Bitmap;
			return bitmap.bitmapData;
		}

		private static function generateTextureOfColor( color:uint ):Texture {
			var bmd:BitmapData = new BitmapData( 32, 32, true, color );
			var texture:Texture = Texture.fromBitmapData( bmd, false, false, Starling.contentScaleFactor );
			return texture;
		}
	}
}
