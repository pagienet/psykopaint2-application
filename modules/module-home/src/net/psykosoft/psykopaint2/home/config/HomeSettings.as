package net.psykosoft.psykopaint2.home.config
{

	import flash.geom.Vector3D;

	public class HomeSettings
	{
		public static var isStandalone:Boolean;
		public static const CAMERA_ZOOM_OUT_Y:Number = 0;
		public static const CAMERA_ZOOM_OUT_Z:Number = -1750;
		public static const DEFAULT_CAMERA_POSITION:Vector3D = new Vector3D( 0, 400, -800 );
		public static const TINT_FREEZES:Boolean = true;
	}
}
