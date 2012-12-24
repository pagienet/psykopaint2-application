package net.psykosoft.psykopaint2.assets.away3d.textures
{

	import away3d.textures.BitmapTexture;

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.util.TextureUtil;

	/*
	* Manages general textures used in 3D scenes.
	* */
	public class Away3dTextureAssetsManager
	{
		[Embed(source="../../../../../../../assets/images/textures/home/home_painting.jpg")]
		private static var HomePaintingTextureAsset:Class;
		[Embed(source="../../../../../../../assets/images/textures/home/settings_painting.jpg")]
		private static var SettingsPaintingTextureAsset:Class;
		[Embed(source="../../../../../../../assets/images/paintings/painting0/painting0.jpg")]
		private static var SamplePaintingDiffuseTextureAsset:Class;
		[Embed(source="../../../../../../../assets/images/paintings/painting0/painting0_normals.png")]
		private static var SamplePaintingNormalsTextureAsset:Class;
		[Embed(source="../../../../../../../assets/images/frames/frames.png")]
		private static var FramesTextureAsset:Class;
		[Embed(source="../../../../../../../assets/images/frames/frames.xml", mimeType="application/octet-stream")]
		private static var FramesTextureAtlasXmlAsset:Class;

		private static var _assets:Dictionary;
		private static var _textures:Dictionary;
		private static var _atlasses:Dictionary;
		private static var _textureData:Dictionary;
		private static var _initialized:Boolean;

		private static function initialize() {

			_assets = new Dictionary();
			_textures = new Dictionary();
			_textureData = new Dictionary();
			_atlasses = new Dictionary();

			// Asset strings need to be associated with the raw data.
			_assets[ Away3dTextureType.TEXTURE_HOME_PAINTING ] = HomePaintingTextureAsset;
			_assets[ Away3dTextureType.TEXTURE_SETTINGS_PAINTING ] = SettingsPaintingTextureAsset;
			_assets[ Away3dTextureType.TEXTURE_SAMPLE_PAINTING_DIFFUSE ] = SamplePaintingDiffuseTextureAsset;
			_assets[ Away3dTextureType.TEXTURE_SAMPLE_PAINTING_NORMALS ] = SamplePaintingNormalsTextureAsset;
			_assets[ Away3dTextureType.TEXTURE_FRAMES ] = FramesTextureAsset;

			_atlasses[ Away3dTextureType.TEXTURE_FRAMES ] = FramesTextureAtlasXmlAsset;

			_initialized = true;
		}

		public static function getAtlasById( id:String ):XML {
			if( !_initialized ) initialize();
			Cc.log( "{Away3dTextureManager.as} - requesting atlas for " + id + "." );
			if( _atlasses[ id ] is XML ) return _atlasses[ id ];
			var atlasClass:Class = _atlasses[ id ];
			if( !atlasClass ) Cc.fatal( "{Away3dTextureManager.as} - The atlas [ " + id + " ] does not exist." );
			_atlasses[ id ] = XML( new atlasClass() );
			return _atlasses[ id ];
		}

		public static function getTextureById( id:String ):BitmapTexture {
			if( !_initialized ) initialize();
			Cc.log( "{Away3dTextureManager.as} - requesting texture for " + id + "." );
			if( _textures[ id ] ) return _textures[ id ];
			var assetClass:Class = _assets[ id ];
			if( !assetClass ) Cc.fatal( "{Away3dTextureManager.as} - The asset [ " + id + " ] does not exist." );
			var originalBmd:BitmapData = new assetClass().bitmapData;
			var bitmapTexture:BitmapTexture = new BitmapTexture( TextureUtil.ensurePowerOf2( originalBmd ) );
			_textureData[ id ] = new Away3dTextureInfoVO( originalBmd.width, originalBmd.height, bitmapTexture.width, bitmapTexture.height );
			_textures[ id ] = bitmapTexture;
			return bitmapTexture;
		}

		public static function getTextureDescriptionById( id:String ):Away3dTextureInfoVO {
			if( !_initialized ) initialize();
			if( _textureData[ id ] ) return _textureData[ id ];
			throw new Error( "{Away3dTextureManager.as} - No description exists for texture [ " + id + " ]." );
		}
	}
}
