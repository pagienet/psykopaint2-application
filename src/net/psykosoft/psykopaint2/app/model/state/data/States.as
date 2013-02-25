package net.psykosoft.psykopaint2.app.model.state.data
{

	public class States
	{
		// -----------------------
		// General states.
		// -----------------------

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
		
		public static const PAINTING_NEW:String = "painting/new";
		public static const PAINTING_SELECT_IMAGE:String = "painting/select/image";
		public static const PAINTING_SELECT_COLORS:String = "painting/select/colors";
		public static const PAINTING_SELECT_TEXTURE:String = "painting/select/texture";
		public static const PAINTING_SELECT_BRUSH:String = "painting/select/brush";
		public static const PAINTING_SELECT_STYLE:String = "painting/select/style"; // This is where you paint.
		public static const PAINTING_EDIT_STYLE:String = "painting/edit/style";
		public static const PAINTING_CAPTURE_IMAGE:String = "painting/select/image/capture";
		public static const PAINTING_CONFIRM_CAPTURE_IMAGE:String = "painting/select/image/capture/confirm";
	}
}
