package net.psykosoft.psykopaint2.home.views.gallery
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class GalleryPaintingSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK : String = "Back";
		public static const ID_LOVE : String = "Love";
		public static const ID_COMMENT : String = "Comment";
		public static const ID_SHARE : String = "Share";

		public function GalleryPaintingSubNavView()
		{
			super();
		}

		override protected function onEnabled() : void
		{
			setHeader("Gallery");
			setLeftButton(ID_BACK, ID_BACK);
		}

		override protected function onSetup() : void
		{
			super.onSetup();
			createCenterButton(ID_LOVE, ID_LOVE, ButtonIconType.LOVE);
			createCenterButton(ID_COMMENT, ID_COMMENT, ButtonIconType.COMMENT);
			createCenterButton(ID_SHARE, ID_SHARE, ButtonIconType.SHARE);
			validateCenterButtons();
		}
	}
}
