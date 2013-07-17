package net.psykosoft.psykopaint2.core.models
{
	public class StateType
	{
		public static const IDLE:String = "state/idle";
		public static const PREVIOUS:String = "state/previous";

		public static const HOME:String = "state/home";
		public static const HOME_ON_EASEL:String = "state/home/on_empty_easel";
		public static const HOME_ON_FINISHED_PAINTING:String = "state/home/on_painting";
		public static const SETTINGS:String = "state/home/settings";

		public static const SETTINGS_WALLPAPER:String = "state/settings/wallpaper";

		public static const COLOR_STYLE:String = "state/color_style";
		public static const CROP:String = "state/crop";
		public static const PICK_IMAGE:String = "state/pick_image";

		public static const BOOK_PICK_SAMPLE_IMAGE:String = "state/book/pick_sample_image";
		public static const BOOK_STANDALONE:String = "state/book/test";
		public static const PICK_USER_IMAGE_DESKTOP:String = "state/pick_user_image_desktop";
		public static const BOOK_PICK_USER_IMAGE_IOS:String = "state/book/pick_user_image_ios";
		public static const PICK_SAMPLE_IMAGE:String = "state/pick_sample_image"; // TODO: delete
		public static const CAPTURE_IMAGE:String = "state/capture_image";
		public static const CONFIRM_CAPTURE_IMAGE:String = "state/confirm_capture_image";
		public static const HOME_PICK_SURFACE:String = "state/home/pick_surface";
		public static const TRANSITION_TO_PAINT_MODE:String = "state/home/transition_to_paint";
		public static const TRANSITION_TO_HOME_MODE:String = "state/paint/transition_to_home";

		public static const PAINT:String = "state/paint";
		public static const PAINT_SELECT_BRUSH:String = "state/paint/select_brush";
		public static const PAINT_ADJUST_BRUSH:String = "state/paint/adjust_brush";
		public static const PAINT_TRANSFORM:String = "state/paint/transform";
		public static const PAINT_COLOR:String = "state/paint/select_color";
	}
}
