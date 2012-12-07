package net.psykosoft.psykopaint2.config
{

	public class Settings
	{
		// Constants.
		public static const NAME:String = "Psykopaint2";
		public static const VERSION:String = "v0.0.0";
		public static const SHOW_SPLASH_SCREEN:Boolean = false;
		public static const DEVICE_DPI:uint = 140;
		public static const DEVICE_SCREEN_WIDTH:uint = 1024;
		public static const DEVICE_SCREEN_HEIGHT:uint = 768;
		public static const CONTENT_SCALE_FACTOR:Number = 2;

		// Debugging options.
		public static const DEBUG_ENABLE_CONSOLE:Boolean = true;
		public static const DEBUG_STARLING:Boolean = true;
		public static const DEBUG_SHOW_3D_TRIDENTS:Boolean = true;
		public static const USE_DEBUG_THEME:Boolean = true;

		// Vars.
		public static var CONTENT_SCALE_MULTIPLIER:Number = 1 / CONTENT_SCALE_FACTOR;
	}
}
