package net.psykosoft.psykopaint2.core.configuration
{
	public class CoreSettings
	{
		// ---------------------------------------------------------------------
		// Constants.
		// ---------------------------------------------------------------------

		// Make sure to tweak these on release
		// TODO: add a "force release" master switch boolean that automatically changes all these
		public static const SHOW_STATS:Boolean = false; /*false on release*/
		public static const SHOW_VERSION:Boolean = false; /*false on release*/
		public static const SHOW_ERRORS:Boolean = false; /*false on release*/
		public static const STAGE_3D_ERROR_CHECKING:Boolean = false; /*false on release*/
		public static const DEBUG_RENDER_SEQUENCE:Boolean = false; /*false on release*/
		public static const USE_DEBUG_KEYS:Boolean = false; /*false on release*/
		public static const SHOW_MEMORY_WARNINGS:Boolean = false; /*false on release*/
		public static const SHOW_MEMORY_USAGE:Boolean = false; /*false on release - this feature costs about 20 fps */
		public static const DEBUG_AGAL:Boolean = false; /*false on release*/
		public static const ENABLE_PSYKOSOCKET_CONNECTION:Boolean = false; /*false on release*/
		public static const SHOW_HIDDEN_BRUSH_PARAMETERS:Boolean = false; /*false on release*/
		public static const SHOW_INTRO_VIDEO:Boolean = false; /*false on release*/
		public static const TINT_SPLASH_SCREEN:Boolean = false; /*false on release*/
		public static const TRACK_NON_GCED_OBJECTS:Boolean = false; /*false on release*/

		public static const RESOLUTION_DPI_RETINA:uint = 264;
		public static const STAGE_3D_ANTI_ALIAS:uint = 0;

		public static const PAINTING_DATA_FOLDER_NAME:String = "psykopaint2-data-paint";

		// ---------------------------------------------------------------------
		// Variables ( automatically set by framework ).
		// ---------------------------------------------------------------------

		// TODO: these should be lower case
		public static var RUNNING_ON_iPAD:Boolean;
		public static var RUNNING_ON_RETINA_DISPLAY:Boolean;
		public static var VERSION:String;
		public static var NAME:String = "";
		public static var GLOBAL_SCALING:Number = 1;
		public static var STAGE_WIDTH:Number = 1024; // Doubled dynamically if on retina iPad.
		public static var STAGE_HEIGHT:Number = 768;
		
	}
}
