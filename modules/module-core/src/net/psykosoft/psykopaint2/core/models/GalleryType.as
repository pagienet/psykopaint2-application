package net.psykosoft.psykopaint2.core.models
{
	public class GalleryType
	{
		// used for oddball cases, such as the painting shown for network errors for view
		public static const NONE : uint = 0;

		public static const FOLLOWING : uint = 1;
		public static const YOURS : uint = 2;
		public static const MOST_RECENT : uint = 3;
		public static const MOST_LOVED : uint = 4;
		public static const USER : uint = 5;
	}
}
