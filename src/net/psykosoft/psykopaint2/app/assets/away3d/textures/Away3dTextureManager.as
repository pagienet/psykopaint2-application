package net.psykosoft.psykopaint2.app.assets.away3d.textures
{

	import away3d.textures.BitmapTexture;

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.app.assets.away3d.textures.data.Away3dTextureType;

	import net.psykosoft.psykopaint2.app.assets.away3d.textures.vo.Away3dTextureInfoVO;
	import net.psykosoft.psykopaint2.app.utils.DisplayContextManager;

	import net.psykosoft.psykopaint2.app.utils.TextureUtil;

	/*
	* Manages general textures used in 3D scenes.
	* */
	public class Away3dTextureManager
	{
		[Embed(source="../../../../../../../../assets-embedded/textures/home/home_painting.jpg")]
		private static var HomePaintingTextureAsset:Class;
		[Embed(source="../../../../../../../../assets-embedded/textures/home/settings_painting.jpg")]
		private static var SettingsPaintingTextureAsset:Class;
		[Embed(source="../../../../../../../../assets-embedded/textures/frames/frames.png")]
		private static var FramesTextureAsset:Class;
		[Embed(source="../../../../../../../../assets-embedded/textures/frames/frames.xml", mimeType="application/octet-stream")]
		private static var FramesTextureAtlasXmlAsset:Class;

		// TODO: Sample paintings ( to be removed from here ).
		[Embed(source="../../../../../../../../assets-embedded/textures/paintings/painting0/painting.jpg")]
		private static var SamplePaintingDiffuseTextureAsset:Class;
		[Embed(source="../../../../../../../../assets-embedded/textures/paintings/painting1/painting.jpg")]
		private static var SamplePainting1DiffuseTextureAsset:Class;
		[Embed(source="../../../../../../../../assets-embedded/textures/paintings/painting2/painting.jpg")]
		private static var SamplePainting2DiffuseTextureAsset:Class;
		[Embed(source="../../../../../../../../assets-embedded/textures/paintings/painting3/painting.jpg")]
		private static var SamplePainting3DiffuseTextureAsset:Class;
		[Embed(source="../../../../../../../../assets-embedded/textures/paintings/painting4/painting.jpg")]
		private static var SamplePainting4DiffuseTextureAsset:Class;
		[Embed(source="../../../../../../../../assets-embedded/textures/paintings/painting5/painting.jpg")]
		private static var SamplePainting5DiffuseTextureAsset:Class;
		[Embed(source="../../../../../../../../assets-embedded/textures/paintings/painting6/painting.jpg")]
		private static var SamplePainting6DiffuseTextureAsset:Class;

		// FloorPapers
		[Embed(source="../../../../../../../../assets-embedded/textures/floorpapers/planks.jpg")]
		private static var FloorpaperPlanksAsset:Class;

		private static var _assets:Dictionary;
		private static var _textures:Dictionary;
		private static var _atlases:Dictionary;
		private static var _textureInfo:Dictionary;
		private static var _initialized:Boolean;

		private static function initialize() : void {

			_assets = new Dictionary();
			_textures = new Dictionary();
			_textureInfo = new Dictionary();
			_atlases = new Dictionary();

			// Asset strings need to be associated with the raw data.
			_assets[ Away3dTextureType.PSYKOPAINT_PAINTING ] = HomePaintingTextureAsset;
			_assets[ Away3dTextureType.SETTINGS_PAINTING ] = SettingsPaintingTextureAsset;
			_assets[ Away3dTextureType.FRAMES_ATLAS ] = FramesTextureAsset;
			_atlases[ Away3dTextureType.FRAMES_ATLAS ] = FramesTextureAtlasXmlAsset;

			// Floorpapers.
			_assets[ Away3dTextureType.FLOORPAPER_PLANKS ] = FloorpaperPlanksAsset;

			// TODO: Sample paintings ( to be removed from here ).
			_assets[ Away3dTextureType.SAMPLE_PAINTING_DIFFUSE ] = SamplePaintingDiffuseTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING1_DIFFUSE ] = SamplePainting1DiffuseTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING2_DIFFUSE ] = SamplePainting2DiffuseTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING3_DIFFUSE ] = SamplePainting3DiffuseTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING4_DIFFUSE ] = SamplePainting4DiffuseTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING5_DIFFUSE ] = SamplePainting5DiffuseTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING6_DIFFUSE ] = SamplePainting6DiffuseTextureAsset;

			_initialized = true;
		}

		public static function getAtlasDataById( id:String ):XML {
			if( !_initialized ) initialize();
			Cc.log( "{Away3dTextureManager.as} - requesting atlas for " + id + "." );
			if( _atlases[ id ] is XML ) return _atlases[ id ];
			var atlasClass:Class = _atlases[ id ];
			if( !atlasClass ) Cc.fatal( "{Away3dTextureManager.as} - The atlas [ " + id + " ] does not exist." );
			_atlases[ id ] = XML( new atlasClass() );
			return _atlases[ id ];
		}

		public static function getTextureById( id:String, useMipMapping:Boolean = false ):ManagedAway3DBitmapTexture {
			if( !_initialized ) initialize();
			Cc.log( "{Away3dTextureManager.as} - requesting texture for " + id + "." );
			if( _textures[ id ] ) return _textures[ id ];
			var assetClass:Class = _assets[ id ];
			if( !assetClass ) Cc.fatal( "{Away3dTextureManager.as} - The asset [ " + id + " ] does not exist." );
			var originalBmd:BitmapData = new assetClass().bitmapData;
			var bitmapTexture:ManagedAway3DBitmapTexture = new ManagedAway3DBitmapTexture( TextureUtil.ensurePowerOf2( originalBmd ), useMipMapping );
			bitmapTexture.name = id;
			bitmapTexture.getTextureForStage3D( DisplayContextManager.stage3dProxy ); // Forces the generation of the texture on demand ( BitmapTextures are lazy )
			_textureInfo[ id ] = new Away3dTextureInfoVO( originalBmd.width, originalBmd.height, bitmapTexture.width, bitmapTexture.height );
			_textures[ id ] = bitmapTexture;
			return bitmapTexture;
		}

		public static function getTextureInfoById( id:String ):Away3dTextureInfoVO {
			if( !_initialized ) initialize();
			if( _textureInfo[ id ] ) return _textureInfo[ id ];
			throw new Error( "{Away3dTextureManager.as} - No info exists for texture [ " + id + " ]." );
		}
	}
}
