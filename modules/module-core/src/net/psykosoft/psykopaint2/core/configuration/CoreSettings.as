package net.psykosoft.psykopaint2.core.configuration
{
	public class CoreSettings
	{
		// ---------------------------------------------------------------------
		// Constants.
		// ---------------------------------------------------------------------

		// Make sure to tweak these on release
		// TODO: add a "force release" master switch boolean that automatically changes all these
		public static const SHOW_STATS:Boolean = true; /*false on release*/
		public static const SHOW_VERSION:Boolean = true; /*false on release*/
		public static const SHOW_ERRORS:Boolean = true; /*false on release*/
		public static const STAGE_3D_ERROR_CHECKING:Boolean = true; /*false on release*/
		public static const DEBUG_RENDER_SEQUENCE:Boolean = false; /*false on release*/
		public static const USE_DEBUG_KEYS:Boolean = true; /*false on release*/
		public static const SHOW_MEMORY_WARNINGS:Boolean = true; /*false on release*/
		public static const DEBUG_AGAL:Boolean = true; /*false on release*/
		public static const SHOW_PSYKOSOCKET_CONNECTION_UI:Boolean = true; /*false on release*/
		public static const SHOW_HIDDEN_BRUSH_PARAMETERS:Boolean = false; /*false on release*/

		public static const RESOLUTION_DPI_RETINA:uint = 264;
		public static const STAGE_3D_ANTI_ALIAS:uint = 0;

		public static const PAINTING_DATA_FOLDER_NAME:String = "psykopaint2-data-paint";

		// ---------------------------------------------------------------------
		// Variables ( automatically set by framework ).
		// ---------------------------------------------------------------------

		public static var RUNNING_ON_iPAD:Boolean;
		public static var RUNNING_ON_RETINA_DISPLAY:Boolean;
		public static var VERSION:String;
		public static var NAME:String = "";
		public static var GLOBAL_SCALING:Number = 1;
		public static var STAGE_WIDTH:Number = 1024; // Doubled dynamically if on retina iPad.
		public static var STAGE_HEIGHT:Number = 768;
		
	}
}
