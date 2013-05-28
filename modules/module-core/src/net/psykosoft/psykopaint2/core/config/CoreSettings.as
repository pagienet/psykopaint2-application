package net.psykosoft.psykopaint2.core.config
{

	public class CoreSettings
	{
		// ---------------------------------------------------------------------
		// Constants.
		// ---------------------------------------------------------------------

		public static const NAME:String = "Psykopaint2 - ";
		public static const VERSION:String = "v0.3.0";
		public static const RESOLUTION_DPI_RETINA:uint = 264;
		public static const STAGE_3D_ANTI_ALIAS:uint = 0;
		public static const STAGE_3D_ERROR_CHECKING:Boolean = true;
		public static const SHOW_STATS:Boolean = true;
		public static const DEBUG_RENDER_SEQUENCE:Boolean = true;

		// ---------------------------------------------------------------------
		// Variables ( automatically set by framework ).
		// ---------------------------------------------------------------------

		public static var RUNNING_ON_iPAD:Boolean;
		public static var RUNNING_ON_RETINA_DISPLAY:Boolean;
	}
}
