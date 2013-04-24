package net.psykosoft.psykopaint2.app.model
{

	public class ApplicationStateType
	{
		// -----------------------
		// General states.
		// -----------------------

		public static const IDLE:String = "idle";
		public static const SPLASH_SCREEN:String = "splash";
		public static const PREVIOUS_STATE:String = "previous";

		// -----------------------
		// Wall view states.
		// -----------------------

		public static const HOME_SCREEN:String = "home";
		public static const SETTINGS:String = "settings";
		public static const SETTINGS_WALLPAPER:String = "settings/wallpaper";

		// -----------------------
		// Painting states.
		// -----------------------
		
		public static const PAINTING:String = "painting";
		public static const PAINTING_SELECT_IMAGE:String = "painting/select/image";
		public static const PAINTING_SELECT_IMAGE_CHOOSING:String = "painting/select/image/choosing";
		public static const PAINTING_CAPTURE_IMAGE:String = "painting/select/image/capture";
		public static const PAINTING_CONFIRM_CAPTURE_IMAGE:String = "painting/select/image/capture/confirm";

		// Associated to the drawing core's states - see UpdateAppStateFromActiveCoreModuleCommand.as.
		// i.e. the drawing core can trigger application state changes.
		public static const PAINTING_CROP_IMAGE:String = "painting/crop/image"; // CropModule
		public static const PAINTING_SELECT_COLORS:String = "painting/select/colors"; // ColorStyleModule
		public static const PAINTING_SELECT_TEXTURE:String = "painting/select/texture"; // ?
		public static const PAINTING_SELECT_BRUSH:String = "painting/select/brush"; // PaintModule, this is where you paint...
		public static const PAINTING_SELECT_STYLE:String = "painting/select/style"; //
		public static const PAINTING_EDIT_STYLE:String = "painting/edit/style"; // ?
	}
}
