package net.psykosoft.psykopaint2.assets
{

	import away3d.textures.BitmapTexture;

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	public class Away3dTextureAssetsManager
	{
		// Skybox images.
		[Embed(source="../../../../../assets/images/skymaps/gallery.jpg")]
		private static var GallerySkyboxImageAsset:Class;

		// Available assets ( must be reported on the initialize method ).
		public static const GallerySkyboxImage:String = "gallery.jpg";

		private static function initialize() {

			_assets = new Dictionary();
			_rawAssetData = new Dictionary();

			// Register individual bitmaps.
			_rawAssetData[ GallerySkyboxImage ] = GallerySkyboxImageAsset;

			_initialized = true;

		}

		private static var _rawAssetData:Dictionary;
		private static var _assets:Dictionary;
		private static var _initialized:Boolean;

		public static function getTextureById( id:String ):BitmapTexture {
			if( !_initialized ) initialize();
			if( _assets[ id ] ) return _assets[ id ];
			var assetClass:Class = _rawAssetData[ id ];
			if( !assetClass ) Cc.fatal( "The asset [ " + id + " ] does not exist." );
			var bitmapTexture:BitmapTexture = new BitmapTexture( new assetClass().bitmapData );
			_assets[ id ] = bitmapTexture;
			return bitmapTexture;
		}

		public static function getBitmapDataById( id:String ):BitmapData {
			if( !_initialized ) initialize();
			if( _assets[ id ] ) return _assets[ id ];
			var assetClass:Class = _rawAssetData[ id ];
			if( !assetClass ) Cc.fatal( "The asset [ " + id + " ] does not exist." );
			var bmd:BitmapData = new assetClass().bitmapData;
			_assets[ id ] = bmd;
			return bmd;
		}
	}
}
