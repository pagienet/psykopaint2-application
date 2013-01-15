package net.psykosoft.psykopaint2.model.state.data
{

	public class States
	{
		public static const SPLASH_SCREEN:String = "splash";
		public static const HOME_SCREEN:String = "home";
		public static const PREVIOUS_STATE:String = "previous";

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
