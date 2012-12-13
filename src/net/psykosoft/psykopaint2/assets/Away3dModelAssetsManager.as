package net.psykosoft.psykopaint2.assets
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.ParserEvent;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.AWD2Parser;
	import away3d.loaders.parsers.OBJParser;

	import com.junkbyte.console.Cc;

	import flash.utils.Dictionary;

	public class Away3dModelAssetsManager
	{
		// Frame models.
		[Embed(source="../../../../../assets/models/frames/frame0/frame0.obj", mimeType="application/octet-stream")]
		private static var Frame0ModelAsset:Class;
		[Embed(source="../../../../../assets/models/frames/frame1/frame1.awd", mimeType="application/octet-stream")]
		private static var Frame1ModelAsset:Class;

		// Available assets ( must be reported on the constructor ).
		public static const Frame0Model:String = "frame0.obj";
		public static const Frame1Model:String = "frame1.awd";

		public static function initialize() {

			_assets = new Dictionary();
			_rawAssetData = new Dictionary();

			// Register individual models.
			_rawAssetData[ Frame0Model ] = Frame0ModelAsset;
			_rawAssetData[ Frame1Model ] = Frame1ModelAsset;

			_parser = new AWD2Parser();
			_parser.addEventListener( AssetEvent.ASSET_COMPLETE, onParserAssetComplete );
			_parser.addEventListener( ParserEvent.PARSE_COMPLETE, onParserComplete );
			_parser.addEventListener( ParserEvent.PARSE_ERROR, onParserError );

			_initialized = true;

		}

		private static var _assets:Dictionary;
		private static var _rawAssetData:Dictionary;
		private static var _initialized:Boolean;
		private static var _currentAssetId:String;
		private static var _currentCallback:Function;
		private static var _parser:AWD2Parser;
		private static var _currentModel:ObjectContainer3D;

		/*
		* Returns a model object by id into the call back function of signature function myCallBack( model:ObjectContainer3D ).
		* If the asset hasn't been parsed, it will parse it, if it has, it will return a stored version of it.
		* NOTE: If multiple requests are made before the asset has finished parsing, this will cause
		* multiple parsings to occur. Try to avoid calling this method in a loop or synchronously.
		* */
		public static function getModelByIdAsync( id:String, callback:Function ):void {
			if( !_initialized ) initialize();
			Cc.log( "{Away3dModelAssetsManager}.as - Asset requested: " + id );
			if( _assets[ id ] ) {
				callback( _assets[ id ] );
				Cc.log( "{Away3dModelAssetsManager}.as - Asset previously requested, reusing: " + id );
				return;
			}
			var assetClass:Class = _rawAssetData[ id ];
			if( !assetClass ) {
				Cc.fatal( "{Away3dModelAssetsManager}.as - The asset [ " + id + " ] does not exist. Perhaps you forgot to register the asset in the initialize method?" );
			}
			_currentAssetId = id;
			_currentCallback = callback;
			_currentModel = new ObjectContainer3D();
			_parser.parseAsync( new assetClass() );
		}

		private static function onParserAssetComplete( event:AssetEvent ):void {
			Cc.log( "{Away3dModelAssetsManager}.as - On -" + _currentAssetId + "- found asset of type '" + event.asset.assetType + "', named '" + event.asset.name + "'." );
			if( event.asset.assetType == AssetType.MESH ) {
				Cc.log( "{Away3dModelAssetsManager}.as - MESH IDENTIFIED: " + _currentAssetId );
				var mesh:Mesh = event.asset as Mesh;
				_currentModel.addChild( mesh );
			}
		}

		private static function onParserError( event:ParserEvent ):void {
			Cc.fatal( "{Away3dModelAssetsManager}.as - On -" + _currentAssetId + ", parser error." + event );
		}

		private static function onParserComplete( event:ParserEvent ):void {
			Cc.log( "{Away3dModelAssetsManager}.as - On -" + _currentAssetId + ", parser complete." + event );
			_assets[ _currentAssetId ] = _currentModel;
			_currentCallback( _currentModel );
		}
	}
}
