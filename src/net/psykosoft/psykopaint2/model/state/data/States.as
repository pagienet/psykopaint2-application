package net.psykosoft.psykopaint2.model.state.data
{

	public class States
	{
		public static const IDLE:String = "idle";
		public static const FEATURE_NOT_IMPLEMENTED:String = "feature/not/implemented";
		public static const SPLASH_SCREEN:String = "splash";
		public static const HOME_SCREEN:String = "home";
		public static const SETTINGS:String = "settings";
		public static const SHOP:String = "shop";
		public static const PREVIOUS_STATE:String = "previous";
		public static const FEATURE_NOT_AVAILABLE_ON_THIS_PLATFORM:String = "feature/not/available/on/this/platform";
		
		// -----------------------
		// Painting states
		// -----------------------
		
		public static const PAINTING_NEW:String = "painting/new";
		public static const PAINTING_SELECT_IMAGE:String = "painting/select/image";
		public static const PAINTING_SELECT_COLORS:String = "painting/select/colors";
		public static const PAINTING_SELECT_TEXTURE:String = "painting/select/texture";
		public static const PAINTING_SELECT_BRUSH:String = "painting/select/brush";
		public static const PAINTING_SELECT_STYLE:String = "painting/select/style"; // This is where you paint.
		public static const PAINTING_EDIT_STYLE:String = "painting/edit/style";
	}
}
