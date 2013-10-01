package net.psykosoft.psykopaint2.home.views.gallery
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class GalleryShareSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK : String = "Back";
		public static const ID_EMAIL : String = "Email";
		public static const ID_INSTAGRAM : String = "Instagram";
		public static const ID_FACEBOOK : String = "Facebook";
		public static const ID_TWITTER : String = "Twitter";
		public static const ID_CAMERA_ROLL : String = "Camera Roll";

		public function GalleryShareSubNavView()
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
			createCenterButton(ID_EMAIL, ID_EMAIL, ButtonIconType.EMAIL);
			createCenterButton(ID_INSTAGRAM, ID_INSTAGRAM, ButtonIconType.INSTAGRAM);
			createCenterButton(ID_FACEBOOK, ID_FACEBOOK, ButtonIconType.FACEBOOK);
			createCenterButton(ID_TWITTER, ID_TWITTER, ButtonIconType.TWITTER);
			createCenterButton(ID_CAMERA_ROLL, ID_CAMERA_ROLL, ButtonIconType.CAMERA_ROLL);
			validateCenterButtons();
		}
	}
}
