package net.psykosoft.psykopaint2.core.models
{
	public class NavigationStateType
	{
		public static const IDLE:String = "state/idle";
		public static const PREVIOUS:String = "state/previous";

		public static const HOME:String = "state/home";
		public static const HOME_ON_EASEL:String = "state/home/on_empty_easel";
		public static const SETTINGS:String = "state/home/settings";

		public static const SETTINGS_WALLPAPER:String = "state/settings/wallpaper";

		public static const CROP:String = "state/crop";
		public static const CROP_SKIP:String = "state/crop/skip";	// this is used to skip the crop module (but crop state is still responsible for resizing), but still need to show the background
		public static const PICK_IMAGE:String = "state/pick_image";

		public static const PICK_USER_IMAGE_DESKTOP:String = "state/pick_user_image_desktop";
		public static const PICK_USER_IMAGE_IOS:String = "state/pick_user_image_ios";
		public static const PICK_SAMPLE_IMAGE:String = "state/pick_sample_image";
		public static const CAPTURE_IMAGE:String = "state/capture_image";
		public static const HOME_PICK_SURFACE:String = "state/home/pick_surface";
		public static const TRANSITION_TO_PAINT_MODE:String = "state/transition_to_paint";

		public static const GALLERY_BROWSE_FOLLOWING : String = "state/gallery/gallery_browse_following";
		public static const GALLERY_BROWSE_MOST_LOVED : String = "state/gallery/gallery_browse_most_loved";
		public static const GALLERY_BROWSE_MOST_RECENT : String = "state/gallery/gallery_browse_recent";
		public static const GALLERY_BROWSE_YOURS : String = "state/gallery/gallery_browse_yours";
		public static const GALLERY_BROWSE_USER : String = "state/gallery/gallery_browse_user";
		public static const GALLERY_PAINTING : String = "state/gallery/painting";
		public static const GALLERY_SHARE : String = "state/gallery/share";

		public static const PAINT:String = "state/paint";
		public static const PAINT_SELECT_BRUSH:String = "state/paint/select_brush";
		public static const PAINT_ADJUST_COLOR:String = "state/paint/adjust_color";
		public static const PAINT_BUY_UPGRADE:String = "state/paint/buy_upgrade";
	}
}
