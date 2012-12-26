package net.psykosoft.psykopaint2.assets.away3d.textures
{

	import away3d.textures.BitmapTexture;

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.assets.away3d.textures.data.Away3dTextureType;

	import net.psykosoft.psykopaint2.assets.away3d.textures.vo.Away3dTextureInfoVO;

	import net.psykosoft.psykopaint2.util.TextureUtil;

	/*
	* Manages general textures used in 3D scenes.
	* */
	public class Away3dTextureManager
	{
		[Embed(source="../../../../../../../assets-embed/textures/home/home_painting.jpg")]
		private static var HomePaintingTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/home/settings_painting.jpg")]
		private static var SettingsPaintingTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/frames/frames.png")]
		private static var FramesTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/frames/frames.xml", mimeType="application/octet-stream")]
		private static var FramesTextureAtlasXmlAsset:Class;

		// TODO: Sample paintings ( to be removed from here ).
		[Embed(source="../../../../../../../assets-embed/textures/paintings/painting0/painting.jpg")]
		private static var SamplePaintingDiffuseTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/paintings/painting0/painting_normals.png")]
		private static var SamplePaintingNormalsTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/paintings/painting1/painting.jpg")]
		private static var SamplePainting1DiffuseTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/paintings/painting1/painting_normals.png")]
		private static var SamplePainting1NormalsTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/paintings/painting2/painting.jpg")]
		private static var SamplePainting2DiffuseTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/paintings/painting2/painting_normals.png")]
		private static var SamplePainting2NormalsTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/paintings/painting3/painting.jpg")]
		private static var SamplePainting3DiffuseTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/paintings/painting3/painting_normals.png")]
		private static var SamplePainting3NormalsTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/paintings/painting4/painting.jpg")]
		private static var SamplePainting4DiffuseTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/paintings/painting4/painting_normals.png")]
		private static var SamplePainting4NormalsTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/paintings/painting5/painting.jpg")]
		private static var SamplePainting5DiffuseTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/paintings/painting5/painting_normals.png")]
		private static var SamplePainting5NormalsTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/paintings/painting6/painting.jpg")]
		private static var SamplePainting6DiffuseTextureAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/paintings/painting6/painting_normals.png")]
		private static var SamplePainting6NormalsTextureAsset:Class;

		// Wallpapers.
		[Embed(source="../../../../../../../assets-embed/textures/wallpapers/default.jpg")]
		private static var WallpaperDefaultAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/wallpapers/furryBlack.jpg")]
		private static var WallpaperFurryBlackAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/wallpapers/greenGrass.jpg")]
		private static var WallpaperGreenGrassAsset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/wallpapers/metal1.jpg")]
		private static var WallpaperMetal1Asset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/wallpapers/metal2.jpg")]
		private static var WallpaperMetal2Asset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/wallpapers/metal3.jpg")]
		private static var WallpaperMetal3Asset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/wallpapers/paper1.jpg")]
		private static var WallpaperPaper1Asset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/wallpapers/paper2.jpg")]
		private static var WallpaperPaper2Asset:Class;
		[Embed(source="../../../../../../../assets-embed/textures/wallpapers/vintage.jpg")]
		private static var WallpaperVintageAsset:Class;

		// FloorPapers
		[Embed(source="../../../../../../../assets-embed/textures/floorpapers/planks.jpg")]
		private static var FloorpaperPlanksAsset:Class;

		private static var _assets:Dictionary;
		private static var _textures:Dictionary;
		private static var _atlases:Dictionary;
		private static var _textureInfo:Dictionary;
		private static var _initialized:Boolean;

		private static function initialize() {

			_assets = new Dictionary();
			_textures = new Dictionary();
			_textureInfo = new Dictionary();
			_atlases = new Dictionary();

			// Asset strings need to be associated with the raw data.
			_assets[ Away3dTextureType.PSYKOPAINT_PAINTING ] = HomePaintingTextureAsset;
			_assets[ Away3dTextureType.SETTINGS_PAINTING ] = SettingsPaintingTextureAsset;
			_assets[ Away3dTextureType.FRAMES_ATLAS ] = FramesTextureAsset;
			_atlases[ Away3dTextureType.FRAMES_ATLAS ] = FramesTextureAtlasXmlAsset;

			// Wallpapers.
			_assets[ Away3dTextureType.WALLPAPER_DEFAULT ] = WallpaperDefaultAsset;
			_assets[ Away3dTextureType.WALLPAPER_FURRY_BLACK ] = WallpaperFurryBlackAsset;
			_assets[ Away3dTextureType.WALLPAPER_GREEN_GRASS ] = WallpaperGreenGrassAsset;
			_assets[ Away3dTextureType.WALLPAPER_METAL1 ] = WallpaperMetal1Asset;
			_assets[ Away3dTextureType.WALLPAPER_METAL2 ] = WallpaperMetal2Asset;
			_assets[ Away3dTextureType.WALLPAPER_METAL3 ] = WallpaperMetal3Asset;
			_assets[ Away3dTextureType.WALLPAPER_PAPER1 ] = WallpaperPaper1Asset;
			_assets[ Away3dTextureType.WALLPAPER_PAPER2 ] = WallpaperPaper2Asset;
			_assets[ Away3dTextureType.WALLPAPER_VINTAGE ] = WallpaperVintageAsset;

			// Floorpapers.
			_assets[ Away3dTextureType.FLOORPAPER_PLANKS ] = FloorpaperPlanksAsset;

			// TODO: Sample paintings ( to be removed from here ).
			_assets[ Away3dTextureType.SAMPLE_PAINTING_DIFFUSE ] = SamplePaintingDiffuseTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING_NORMALS ] = SamplePaintingNormalsTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING1_DIFFUSE ] = SamplePainting1DiffuseTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING1_NORMALS ] = SamplePainting1NormalsTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING2_DIFFUSE ] = SamplePainting2DiffuseTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING2_NORMALS ] = SamplePainting2NormalsTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING3_DIFFUSE ] = SamplePainting3DiffuseTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING3_NORMALS ] = SamplePainting3NormalsTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING4_DIFFUSE ] = SamplePainting4DiffuseTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING4_NORMALS ] = SamplePainting4NormalsTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING5_DIFFUSE ] = SamplePainting5DiffuseTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING5_NORMALS ] = SamplePainting5NormalsTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING6_DIFFUSE ] = SamplePainting6DiffuseTextureAsset;
			_assets[ Away3dTextureType.SAMPLE_PAINTING6_NORMALS ] = SamplePainting6NormalsTextureAsset;

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

		public static function getTextureById( id:String ):BitmapTexture {
			if( !_initialized ) initialize();
			Cc.log( "{Away3dTextureManager.as} - requesting texture for " + id + "." );
			if( _textures[ id ] ) return _textures[ id ];
			var assetClass:Class = _assets[ id ];
			if( !assetClass ) Cc.fatal( "{Away3dTextureManager.as} - The asset [ " + id + " ] does not exist." );
			var originalBmd:BitmapData = new assetClass().bitmapData;
			var bitmapTexture:BitmapTexture = new BitmapTexture( TextureUtil.ensurePowerOf2( originalBmd ) );
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
