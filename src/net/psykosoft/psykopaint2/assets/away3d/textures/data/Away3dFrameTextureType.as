package net.psykosoft.psykopaint2.assets.away3d.textures.data
{

	public class Away3dFrameTextureType
	{
		public static const WHITE:String = "whiteFrame";
		public static const GOLD:String = "goldFrame";
		public static const BLUE:String = "blueFrame";
		public static const DANGER:String = "dangerFrame";

		public static function getAvailableTypes():Array {
			return [ WHITE, GOLD, BLUE, DANGER ];
		}
	}
}
