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
		[Embed(source="../../../../../../../../../assets/images/textures/frames/blue.png")]
		private static var BlueFrameAsset:Class;
		[Embed(source="../../../../../../../../../assets/images/textures/frames/gold.png")]
		private static var GoldFrameAsset:Class;

		private static var _assets:Dictionary;
		private static var _textures:Dictionary;
		private static var _textureData:Dictionary;
		private static var _colors:Dictionary;
		private static var _initialized:Boolean;
		private static var _availableFrameTypes:Vector.<String>;

		private static function initialize() {

			_assets = new Dictionary();
			_textures = new Dictionary();
			_textureData = new Dictionary();
			_colors = new Dictionary();
			_availableFrameTypes = new Vector.<String>();
			_initialized = true;

			// -----------------------
			// Register assets.
			// -----------------------

			// White.
			_assets[ FrameTextureType.FRAME_WHITE ] = WhiteFrameAsset;
			_textureData[ FrameTextureType.FRAME_WHITE ] = new FrameTextureDescriptorVO( 630, 490, 59, 55, 514, 377 );
			_availableFrameTypes.push( FrameTextureType.FRAME_WHITE );
			_colors[ FrameTextureType.FRAME_WHITE ] = 0xE8EBEA;

			// Danger.
			_assets[ FrameTextureType.FRAME_DANGER ] = DangerFrameAsset;
			_textureData[ FrameTextureType.FRAME_DANGER ] = new FrameTextureDescriptorVO( 659, 512, 70, 73, 525, 374 );
			_availableFrameTypes.push( FrameTextureType.FRAME_DANGER );
			_colors[ FrameTextureType.FRAME_DANGER ] = 0x07060A;

			// Blue.
			_assets[ FrameTextureType.FRAME_BLUE ] = BlueFrameAsset;
			_textureData[ FrameTextureType.FRAME_BLUE ] = new FrameTextureDescriptorVO( 666, 512, 95, 79, 480, 358 );
			_availableFrameTypes.push( FrameTextureType.FRAME_BLUE );
			_colors[ FrameTextureType.FRAME_BLUE ] = 0x171B23;

			// Gold.
			_assets[ FrameTextureType.FRAME_GOLD ] = GoldFrameAsset;
			_textureData[ FrameTextureType.FRAME_GOLD ] = new FrameTextureDescriptorVO( 638, 512, 61, 61, 522, 394 );
			_availableFrameTypes.push( FrameTextureType.FRAME_GOLD );
			_colors[ FrameTextureType.FRAME_GOLD ] = 0xC99D4B;


		}

		/*
		* id: FrameType.as
		* */
		public static function getFrameTextureById( id:String ):BitmapTexture {
			if( !_initialized ) initialize();
			Cc.log( "{FrameTextureManager.as} - requesting frame texture for " + id + "." );
			if( _textures[ id ] ) return _textures[ id ];
			var assetClass:Class = _assets[ id ];
			if( !assetClass ) Cc.fatal( "{FrameTextureManager.as} - The asset [ " + id + " ] does not exist." );
			var originalBmd:BitmapData = new assetClass().bitmapData;
			var bitmapTexture:BitmapTexture = new BitmapTexture( TextureUtil.ensurePowerOf2( originalBmd ) );
			_textures[ id ] = bitmapTexture;
			_textureData[ id ].textureWidth = bitmapTexture.width;
			_textureData[ id ].textureHeight = bitmapTexture.height;
			return bitmapTexture;
		}

		public static function getFrameDescriptionById( id:String ):FrameTextureDescriptorVO {
			if( !_initialized ) initialize();
			if( _textureData[ id ] ) return _textureData[ id ];
			throw new Error( "{FrameTextureManager.as} - No description exists for texture [ " + id + " ]." );
		}

		public static function get availableFrameTypes():Vector.<String> {
			if( !_initialized ) initialize();
			return _availableFrameTypes;
		}

		public static function getColorForFrameId( id:String ):uint {
			if( !_initialized ) initialize();
			return _colors[ id ];
		}
	}
}
