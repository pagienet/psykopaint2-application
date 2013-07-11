package net.psykosoft.psykopaint2.home.config
{

	import flash.geom.Vector3D;

	public class HomeSettings
	{
		// Make sure to tweak these on release
		public static const TINT_FREEZES:Boolean = false; /*false on release*/

		public static const DEFAULT_CAMERA_POSITION:Vector3D = new Vector3D( 0, 0, -1750 );

		public static var isStandalone:Boolean;
	}
}
