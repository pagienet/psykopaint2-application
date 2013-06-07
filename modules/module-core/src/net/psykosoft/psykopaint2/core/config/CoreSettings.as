package net.psykosoft.psykopaint2.core.config
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
		public static const VISUALIZE_MEMORY_WARNINGS:Boolean = true; /*false on release*/
		public static const DEBUG_AGAL:Boolean = false; /*false on release*/
		public static const SHOW_PSYKOSOCKET_CONNECTION_UI:Boolean = true; /*false on release*/
		public static const SHOW_HIDDEN_BRUSH_PARAMETERS:Boolean = false; /*false on release*/

		public static const RESOLUTION_DPI_RETINA:uint = 264;
		public static const STAGE_3D_ANTI_ALIAS:uint = 0;

		// ---------------------------------------------------------------------
		// Variables ( automatically set by framework ).
		// ---------------------------------------------------------------------

		public static var RUNNING_ON_iPAD:Boolean;
		public static var RUNNING_ON_RETINA_DISPLAY:Boolean;
		public static var VERSION:String;
		public static var NAME:String = "";
		public static var GLOBAL_SCALING:Number = 1;
	}
}
