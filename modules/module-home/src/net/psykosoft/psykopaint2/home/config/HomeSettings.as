package net.psykosoft.psykopaint2.home.config
{

	import flash.geom.Vector3D;

	public class HomeSettings
	{
		// Make sure to tweak these on release
		public static const TINT_FREEZES:Boolean = false; /*false on release*/

		public static const CAMERA_ZOOM_OUT_Y:Number = 0;
		public static const CAMERA_ZOOM_OUT_Z:Number = -1750;
		public static const DEFAULT_CAMERA_POSITION:Vector3D = new Vector3D( 0, 400, -800 );

		public static var isStandalone:Boolean;
	}
}
