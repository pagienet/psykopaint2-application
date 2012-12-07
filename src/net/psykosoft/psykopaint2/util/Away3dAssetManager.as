package net.psykosoft.psykopaint2.util
{

	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.OBJParser;
	import away3d.textures.BitmapTexture;

	import com.junkbyte.console.Cc;

	import flash.utils.Dictionary;

	public class Away3dAssetManager
	{
		// Frame model.
		[Embed(source="../../../../../assets/models/frames/frame0/frame0.obj", mimeType="application/octet-stream")]
		private static var FrameModelAsset:Class;

		// Skybox images.
		[Embed(source="../../../../../assets/images/skymaps/gallery.jpg")]
		private static var GallerySkyboxImageAsset:Class;

		// Available assets ( must be reported on the initialize() method ).
		public static const FrameModel:uint = 0;
		public static const GallerySkyboxImage:uint = 1;

		private static function initialize():void {

			_assets = new Dictionary();
			_rawAssetData = new Dictionary();

			// Register individual bitmaps.
			_rawAssetData[ FrameModel ] = FrameModelAsset;
			_rawAssetData[ GallerySkyboxImage ] = GallerySkyboxImageAsset;

			_initialized = true;
		}

		private static var _rawAssetData:Dictionary;
		private static var _assets:Dictionary;
		private static var _initialized:Boolean;

		public function getModelById( id:uint, callback:Function ):void {
			if( !_initialized ) initialize();
			if( _assets[ id ] ) callback( _assets[ id ] );
			var assetClass:Class = _rawAssetData[ id ];
			if( !assetClass ) Cc.fatal( "Away3dAssetManager.as - the asset [ " + id + " ] does not exist." );
			var parser:OBJParser = new OBJParser(); // TODO... must support other formats
			parser.addEventListener( AssetEvent.ASSET_COMPLETE, function( event:AssetEvent ):void {
				if( event.asset.assetType == AssetType.MESH ) {
					var model:Mesh = event.asset as Mesh;
					_assets[ id ] = model;
					callback( model );
				}
			} );
			parser.parseAsync( new assetClass() );
		}

		public function getTextureById( id:uint ):BitmapTexture {
			if( !_initialized ) initialize();
			if( _assets[ id ] ) return _assets[ id ];
			var assetClass:Class = _rawAssetData[ id ];
			if( !assetClass ) Cc.fatal( "Away3dAssetManager.as - the asset [ " + id + " ] does not exist." );
			var bitmapTexture:BitmapTexture = new BitmapTexture(  new assetClass().bitmapData );
			_assets[ id ] = bitmapTexture;
			return bitmapTexture;
		}
	}
}
