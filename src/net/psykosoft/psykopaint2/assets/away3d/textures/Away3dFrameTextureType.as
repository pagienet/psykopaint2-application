package net.psykosoft.psykopaint2.assets.away3d.textures
{

	public class Away3dFrameTextureType
	{
		public static const FRAME_WHITE:String = "whiteFrame";
		public static const FRAME_GOLD:String = "goldFrame";
		public static const FRAME_BLUE:String = "blueFrame";
		public static const FRAME_DANGER:String = "dangerFrame";

		public static function getAvailableTypes():Array {
			return [ FRAME_WHITE, FRAME_GOLD, FRAME_BLUE, FRAME_DANGER ];
		}
	}
}
