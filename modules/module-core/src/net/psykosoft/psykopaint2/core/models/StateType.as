package net.psykosoft.psykopaint2.core.models
{
	public class StateType
	{
		public static const IDLE:String = "state/idle";
		public static const PREVIOUS:String = "state/previous";

		public static const HOME:String = "state/home";
		public static const HOME_ON_EMPTY_EASEL:String = "state/home/on_empty_easel";
		public static const HOME_ON_UNFINISHED_PAINTING:String = "state/home/on_unfinished_painting";
		public static const HOME_ON_PAINTING:String = "state/home/on_painting";
		public static const SETTINGS:String = "state/home/settings";

		public static const SETTINGS_WALLPAPER:String = "state/settings/wallpaper";

		public static const COLOR_STYLE:String = "state/color_style";
		public static const CROP:String = "state/crop";
		public static const PICK_IMAGE:String = "state/pick_image";
		public static const PICK_SURFACE:String = "state/pick_surface";

		public static const GOING_TO_PAINT:String = "state/will_paint";
		public static const PAINT:String = "state/paint";
		public static const PAINT_SELECT_BRUSH:String = "state/paint/select_brush";
		public static const PAINT_ADJUST_BRUSH:String = "state/paint/adjust_brush";
	}
}
