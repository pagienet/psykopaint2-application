package net.psykosoft.psykopaint2.core.models
{
	public class NavigationStateType
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
		public static const CROP_SKIP:String = "state/crop/skip";	// this is used to skip the crop module (but crop state is still responsible for resizing), but still need to show the background
		public static const PICK_IMAGE:String = "state/pick_image";

		public static const BOOK_SOURCE_IMAGES:String = "state/book_source_images";
		public static const BOOK_GALLERY:String = "state/book_gallery";
		public static const PICK_USER_IMAGE_DESKTOP:String = "state/pick_user_image_desktop";
		public static const PICK_SAMPLE_IMAGE:String = "state/pick_sample_image"; // TODO: delete
		public static const CAPTURE_IMAGE:String = "state/capture_image";
		public static const HOME_PICK_SURFACE:String = "state/home/pick_surface";
		public static const PREPARE_FOR_PAINT_MODE:String = "state/home/prepare_for_paint";
		public static const PREPARE_FOR_HOME_MODE:String = "state/paint/prepare_for_home";
		public static const TRANSITION_TO_HOME_MODE:String = "state/transition_to_home";
		public static const TRANSITION_TO_PAINT_MODE:String = "state/transition_to_paint";

		public static const PAINT:String = "state/paint";
		public static const PAINT_SELECT_BRUSH:String = "state/paint/select_brush";
		public static const PAINT_ADJUST_BRUSH:String = "state/paint/adjust_brush";

		public static const PAINT_COLOR:String = "state/paint/select_color";
		//public static const PAINT_HIDE_SOURCE:String = "state/paint/hide_source";
		

	}
}
