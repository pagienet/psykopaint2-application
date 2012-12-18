package net.psykosoft.psykopaint2.view.away3d.wall.wallframes.frames
{

	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.util.TextureUtil;

	public class FrameTextureManager
	{
		[Embed(source="../../../../../../../../../assets/images/textures/frames/white.png")]
		private static var WhiteFrameAsset:Class;
		[Embed(source="../../../../../../../../../assets/images/textures/frames/danger.png")]
		private static var DangerFrameAsset:Class;

		private static var _assets:Dictionary;
		private static var _textures:Dictionary;
		private static var _dimensions:Dictionary;
		private static var _contentAreas:Dictionary;
		private static var _initialized:Boolean;

		private static function initialize() {

			_assets = new Dictionary();
			_textures = new Dictionary();
			_dimensions = new Dictionary();
			_contentAreas = new Dictionary();
			_initialized = true;

			// -----------------------
			// Register assets.
			// -----------------------

			_assets[ FrameTextureType.FRAME_WHITE ] = WhiteFrameAsset;
			_dimensions[ FrameTextureType.FRAME_WHITE ] = new Point( 658, 512 );
			_contentAreas[ FrameTextureType.FRAME_WHITE ] = new Rectangle( 59, 56, 514, 377 );

			_assets[ FrameTextureType.FRAME_DANGER ] = DangerFrameAsset;
			// TODO.

		}

		/*
		* id: FrameType.as
		* */
		public static function getFrameTextureById( id:String ):BitmapTexture {
			if( !_initialized ) initialize();
			if( _textures[ id ] ) return _textures[ id ];
			var assetClass:Class = _assets[ id ];
			if( !assetClass ) Cc.fatal( "{FrameTextureManager.as} - The asset [ " + id + " ] does not exist." );
			var originalBmd:BitmapData = new assetClass().bitmapData;
			var bitmapTexture:BitmapTexture = new BitmapTexture( TextureUtil.ensurePowerOf2( originalBmd ) );
			_textures[ id ] = bitmapTexture;
			return bitmapTexture;
		}

		public static function getFrameTextureDimensionsById( id:String ):Point {
			if( !_initialized ) initialize();
			if( _dimensions[ id ] ) return _dimensions[ id ];
			throw new Error( "{FrameTextureManager.as} - No dimensions exist for texture [ " + id + " ]." );
		}

		public static function getFrameContentAreaById( id:String ):Rectangle {
			if( !_initialized ) initialize();
			if( _contentAreas[ id ] ) return _contentAreas[ id ];
			throw new Error( "{FrameTextureManager.as} - No content area exists for texture [ " + id + " ]." );
		}
	}
}
