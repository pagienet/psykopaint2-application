package net.psykosoft.psykopaint2.config
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

		public static const SHOW_SPLASH_SCREEN:Boolean = false;
		public static const DEVICE_DPI:uint = 132;
		public static const DEVICE_SCREEN_WIDTH:uint = 1024;
		public static const DEVICE_SCREEN_HEIGHT:uint = 768;
		public static const CONTENT_SCALE_FACTOR:Number = 1;

		/*
		* Stage3D alias quality both for Starling and Away3D.
		* */
		public static const ANTI_ALIAS:uint = 1;

		// ---------------------------------------------------------------------
		// Debugging options.
		// ---------------------------------------------------------------------

		/*
		* Enables the in app debugging console.
		* If enabled, a button appears on the top left to toggle it.
		* Doesn't affect performance too much on mobile while not visible.
		* */
		public static const ENABLE_DEBUG_CONSOLE:Boolean = true;

		/*
		* Makes it easier to detect GPU errors at runtime.
		* Affects performance.
		* */
		public static const ENABLE_STAGE3D_ERROR_CHECKING:Boolean = false;

		/*
		* Show performance stats on the upper left corner of the app.
		* */
		public static const SHOW_STATS:Boolean = true;

		/*
		* Replaces the app's official skin with a lighter one for testing.
		* */
		public static const USE_DEBUG_THEME:Boolean = true;

		public static const AWAY3D_DEBUG_MODE:Boolean = false;

		// ---------------------------------------------------------------------
		// 3D performance options.
		// ---------------------------------------------------------------------

		/*
		* Enables reflections on frames on the wall scene ( frame glass effect ).
		* Heavy performance const. TODO: Find a better performing solution.
		* */
		public static const USE_REFLECTIONS_ON_FRAMES:Boolean = false;

		/*
		* Enables usage of normal and specular maps on paintings on
		* the wall scene.
		* */
		public static const USE_COMPLEX_ILLUMINATION_ON_PAINTINGS:Boolean = true;

		// ---------------------------------------------------------------------
		// Vars ( these are not settings actually, do not set ).
		// ---------------------------------------------------------------------

		public static var CONTENT_SCALE_MULTIPLIER:Number = 1 / CONTENT_SCALE_FACTOR;
	}
}
