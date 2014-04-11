package net.psykosoft.psykopaint2.home.views.home
{
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class HomeSubNavView extends SubNavigationViewBase
	{
		
		public static const ID_GALLERY : String = "Gallery";
		public static const ID_SETTINGS : String = "Settings";
		public static const ID_PAINT : String = "Paint";
		
		public function HomeSubNavView()
		{
			
		}
		
		override protected function onSetup() : void
		{
			super.onSetup();
			
			createCenterButton(ID_SETTINGS, ID_SETTINGS, ButtonIconType.SETTINGS);
			createCenterButton(ID_PAINT, ID_PAINT, ButtonIconType.WATERCOLOR);
			createCenterButton(ID_GALLERY, ID_GALLERY, ButtonIconType.GALLERY);
			validateCenterButtons();
		}
		
	}
}