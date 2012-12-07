package net.psykosoft.psykopaint2.util
{

	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.OBJParser;
	import away3d.textures.BitmapTexture;

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;

	import flash.utils.Dictionary;

	public class Away3dAssetManager
	{
		// Frame model.
		[Embed(source="../../../../../assets/models/frames/frame0/frame0.obj", mimeType="application/octet-stream")]
		private static var Frame0ModelAsset:Class;

		// Skybox images.
		[Embed(source="../../../../../assets/images/skymaps/gallery.jpg")]
		private static var GallerySkyboxImageAsset:Class;

		// Available assets ( must be reported on the initialize() method ).
		public static const Frame0Model:uint = 0;
		public static const GallerySkyboxImage:uint = 1;

		private static function initialize():void {

			_assets = new Dictionary();
			_rawAssetData = new Dictionary();
			_targetGeometryNames = new Dictionary();

			// Register individual bitmaps.
			_rawAssetData[ Frame0Model ] = Frame0ModelAsset;
			_rawAssetData[ GallerySkyboxImage ] = GallerySkyboxImageAsset;

			_targetGeometryNames[ Frame0Model ] = "frame";

			_initialized = true;
		}

		private static var _rawAssetData:Dictionary;
		private static var _targetGeometryNames:Dictionary;
		private static var _assets:Dictionary;
		private static var _initialized:Boolean;

		public static function getModelById( id:uint, callback:Function ):void {
			if( !_initialized ) initialize();
			if( _assets[ id ] ) callback( _assets[ id ] );
			var assetClass:Class = _rawAssetData[ id ];
			if( !assetClass ) Cc.fatal( "Away3dAssetManager.as - the asset [ " + id + " ] does not exist." );
			var parser:OBJParser = new OBJParser(); // TODO... must support other formats
			parser.addEventListener( AssetEvent.ASSET_COMPLETE, function( event:AssetEvent ):void {
				if( event.asset.assetType == AssetType.MESH ) {
					if( event.asset.name == _targetGeometryNames[ id ] ) {
						Cc.info( this, "loaded a mesh: " + event.asset.name );
						var model:Mesh = event.asset as Mesh;
						_assets[ id ] = model;
						callback( model );
					}
				}
			} );
			parser.parseAsync( new assetClass() );
		}

		public static function getTextureById( id:uint ):BitmapTexture {
			if( !_initialized ) initialize();
			if( _assets[ id ] ) return _assets[ id ];
			var assetClass:Class = _rawAssetData[ id ];
			if( !assetClass ) Cc.fatal( "Away3dAssetManager.as - the asset [ " + id + " ] does not exist." );
			var bitmapTexture:BitmapTexture = new BitmapTexture( new assetClass().bitmapData );
			_assets[ id ] = bitmapTexture;
			return bitmapTexture;
		}

		public static function getBitmapDataById( id:uint ):BitmapData {
			if( !_initialized ) initialize();
			if( _assets[ id ] ) return _assets[ id ];
			var assetClass:Class = _rawAssetData[ id ];
			if( !assetClass ) Cc.fatal( "Away3dAssetManager.as - the asset [ " + id + " ] does not exist." );
			var bmd:BitmapData = new assetClass().bitmapData;
			_assets[ id ] = bmd;
			return bmd;
		}
	}
}
