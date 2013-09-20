package net.psykosoft.psykopaint2.home.views.gallery
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class GallerySubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Back";
		public static const ID_YOURS:String = "Yours";
		public static const ID_FOLLOWING:String = "Following";
		public static const ID_MOST_RECENT:String = "Most recent";
		public static const ID_MOST_LOVED:String = "Most loved";

		public function GallerySubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Gallery" );
			setLeftButton( ID_BACK, ID_BACK );
		}

		override protected function onSetup():void {
			super.onSetup();
			createCenterButton( ID_YOURS, ID_YOURS, ButtonIconType.YOU );
			createCenterButton( ID_FOLLOWING, ID_FOLLOWING, ButtonIconType.GALLERY );
			createCenterButton( ID_MOST_RECENT, ID_MOST_RECENT, ButtonIconType.GALLERY );
			createCenterButton( ID_MOST_LOVED, ID_MOST_LOVED, ButtonIconType.GALLERY );
			validateCenterButtons();
		}
	}
}
