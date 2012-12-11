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

		public static function getModelByIdAsync( id:String, callback:Function ):void {
			if( !_initialized ) initialize();
			if( _assets[ id ] ) callback( _assets[ id ] );
			var assetClass:Class = _rawAssetData[ id ];
			if( !assetClass ) Cc.fatal( "The asset [ " + id + " ] does not exist." );
			var parser:OBJParser = new OBJParser(); // TODO... must support other formats
			parser.addEventListener( AssetEvent.ASSET_COMPLETE, function( event:AssetEvent ):void {
				if( event.asset.assetType == AssetType.MESH ) {
					if( event.asset.name == _targetGeometryNames[ id ] ) {
						Cc.log( this, "loaded a mesh: " + event.asset.name );
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
