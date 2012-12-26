package net.psykosoft.psykopaint2.assets.away3d.textures.data
{

	public class Away3dTextureType
	{
		public static const PSYKOPAINT_PAINTING:String = "home/painting";
		public static const SETTINGS_PAINTING:String = "settings/painting";
		public static const FRAMES_ATLAS:String = "frames/atlas";

		// Wallpapers.
		public static const WALLPAPER_DEFAULT:String = "wallpaper/default";
		public static const WALLPAPER_FURRY_BLACK:String = "wallpaper/furryBlack";
		public static const WALLPAPER_GREEN_GRASS:String = "wallpaper/greenGrass";
		public static const WALLPAPER_METAL1:String = "wallpaper/metal1";
		public static const WALLPAPER_METAL2:String = "wallpaper/metal2";
		public static const WALLPAPER_METAL3:String = "wallpaper/metal3";
		public static const WALLPAPER_PAPER1:String = "wallpaper/paper1";
		public static const WALLPAPER_PAPER2:String = "wallpaper/paper2";
		public static const WALLPAPER_VINTAGE:String = "wallpaper/vintage";

		// Floorpapers.
		public static const FLOORPAPER_PLANKS:String = "floorpaper/planks";

		// TODO: Sample paintings ( to be removed from here ).
		public static const SAMPLE_PAINTING_DIFFUSE:String = "sample/painting/diffuse";
		public static const SAMPLE_PAINTING_NORMALS:String = "sample/painting/normals";
		public static const SAMPLE_PAINTING1_DIFFUSE:String = "sample/painting1/diffuse";
		public static const SAMPLE_PAINTING1_NORMALS:String = "sample/painting1/normals";
		public static const SAMPLE_PAINTING2_DIFFUSE:String = "sample/painting2/diffuse";
		public static const SAMPLE_PAINTING2_NORMALS:String = "sample/painting2/normals";
		public static const SAMPLE_PAINTING3_DIFFUSE:String = "sample/painting3/diffuse";
		public static const SAMPLE_PAINTING3_NORMALS:String = "sample/painting3/normals";
		public static const SAMPLE_PAINTING4_DIFFUSE:String = "sample/painting4/diffuse";
		public static const SAMPLE_PAINTING4_NORMALS:String = "sample/painting4/normals";
		public static const SAMPLE_PAINTING5_DIFFUSE:String = "sample/painting5/diffuse";
		public static const SAMPLE_PAINTING5_NORMALS:String = "sample/painting5/normals";
		public static const SAMPLE_PAINTING6_DIFFUSE:String = "sample/painting6/diffuse";
		public static const SAMPLE_PAINTING6_NORMALS:String = "sample/painting6/normals";

		public static function getAvailableWallPaperTypes():Array {
			return [
				WALLPAPER_DEFAULT, WALLPAPER_FURRY_BLACK, WALLPAPER_GREEN_GRASS, WALLPAPER_METAL1,
				WALLPAPER_METAL2, WALLPAPER_METAL3, WALLPAPER_PAPER1, WALLPAPER_PAPER2, WALLPAPER_VINTAGE
			];
		}
	}
}
