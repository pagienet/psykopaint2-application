package net.psykosoft.psykopaint2.app.config
{

	public class Settings
	{
		// ---------------------------------------------------------------------
		// App version.
		// ---------------------------------------------------------------------

		public static const NAME:String = "Psykopaint2";
		public static const VERSION:String = "v0.0.0";

		// ---------------------------------------------------------------------
		// General options.
		// ---------------------------------------------------------------------

		public static const SHOW_SPLASH_SCREEN:Boolean = true;
		public static const ANTI_ALIAS:uint = 1;
		public static const NAVIGATION_AREA_CONTENT_HEIGHT:Number = 210;

		// ---------------------------------------------------------------------
		// Debugging options.
		// ---------------------------------------------------------------------

		public static const ENABLE_DEBUG_CONSOLE:Boolean = true;
		public static const ENABLE_STAGE3D_ERROR_CHECKING:Boolean = false;
		public static const SHOW_STATS:Boolean = true;
		public static const AWAY3D_DEBUG_MODE:Boolean = false;

		// ---------------------------------------------------------------------
		// 3D performance options.
		// ---------------------------------------------------------------------



		// ---------------------------------------------------------------------
		// Constants.
		// ---------------------------------------------------------------------

		public static const RESOLUTION_X_iPAD:uint = 1024;
		public static const RESOLUTION_Y_iPAD:uint = 768;
		public static const DPI_iPAD:uint = 132;
		public static const RESOLUTION_X_iPAD_RETINA:uint = 2048;
		public static const RESOLUTION_Y_iPAD_RETINA:uint = 1536;
		public static const DPI_iPAD_RETINA:uint = 264;

		// ---------------------------------------------------------------------
		// Vars ( these are not settings actually, do not set ).
		// ---------------------------------------------------------------------

		public static var RUNNING_ON_HD:Boolean = true;
		public static var RUNNING_ON_iPAD:Boolean = true;
		public static var RUNNING_ON_RETINA_DISPLAY:Boolean = true;
	}
}