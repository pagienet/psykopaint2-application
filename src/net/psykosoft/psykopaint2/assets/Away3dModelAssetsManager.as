package net.psykosoft.psykopaint2.assets
{

	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.OBJParser;

	import com.junkbyte.console.Cc;

	import flash.utils.Dictionary;

	public class Away3dModelAssetsManager
	{
		// Frame model.
		[Embed(source="../../../../../assets/models/frames/frame0/frame0.obj", mimeType="application/octet-stream")]
		private static var Frame0ModelAsset:Class;

		// Available assets ( must be reported on the constructor ).
		public static const Frame0Model:String = "frame0.obj";

		public static function initialize() {

			_assets = new Dictionary();
			_rawAssetData = new Dictionary();
			_targetGeometryNames = new Dictionary();

			// Register individual models.
			_rawAssetData[ Frame0Model ] = Frame0ModelAsset;

			// Associate geometry names with assets.
			// TODO: in the future will probably have to standardize these names from 3D design itself
			_targetGeometryNames[ Frame0Model ] = "frame";

			_initialized = true;

		}

		private static var _assets:Dictionary;
		private static var _rawAssetData:Dictionary;
		private static var _targetGeometryNames:Dictionary;
		private static var _initialized:Boolean;

		/*
		* Returns a model object by id into the call back function of signature function myCallBack( model:Mesh ).
		* If the asset hasn't been parsed, it will parse it, if it has, it will return a stored version of it.
		* NOTE: If multiple requests are made before the asset has finished parsing, this will cause
		* multiple parsings to occur. Try to avoid calling this method in a loop or synchronously.
		* */
		public static function getModelByIdAsync( id:String, callback:Function ):void {
			if( !_initialized ) initialize();
			Cc.log( "{Away3dModelAssetsManager}.as - Asset requested: " + id );
			if( _assets[ id ] ) {
				callback( _assets[ id ] );
				Cc.log( "{Away3dModelAssetsManager}.as - Reusing asset: " + id );
				return;
			}
			var assetClass:Class = _rawAssetData[ id ];
			if( !assetClass ) Cc.fatal( "{Away3dModelAssetsManager}.as - The asset [ " + id + " ] does not exist." );
			var parser:OBJParser = new OBJParser(); // TODO... must support other formats
			parser.addEventListener( AssetEvent.ASSET_COMPLETE, function( event:AssetEvent ):void {
				if( event.asset.assetType == AssetType.MESH ) {
					if( event.asset.name == _targetGeometryNames[ id ] ) {
						Cc.log( "{Away3dModelAssetsManager}.as - Parsed a mesh: " + id );
						var model:Mesh = event.asset as Mesh;
						_assets[ id ] = model;
						callback( model );
					}
				}
			} );
			parser.parseAsync( new assetClass() );
		}
	}
}
