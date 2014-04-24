package net.psykosoft.psykopaint2.home.views.gallery
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class GalleryUserSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Back";
		public static const ID_FOLLOW:String = "Follow";

		public function GalleryUserSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "" );
			setLeftButton( ID_BACK, ID_BACK );
		}

		override protected function onSetup():void {
			super.onSetup();
			createCenterButton( ID_FOLLOW, ID_FOLLOW, ButtonIconType.FRIENDS );
			validateCenterButtons();
		}
	}
}
