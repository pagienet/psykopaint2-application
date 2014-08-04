package net.psykosoft.psykopaint2.home.views.settings
{
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	
	public class SettingsHelpSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Back"; /* Settings */
		public static const ID_VIDEO:String = "video"; 
		public static const ID_FAQ:String = "faq"; 

		public function SettingsHelpSubNavView()
		{
			super();
		}
		
		override protected function onEnabled():void {
			setHeader( "" );
			
		}
		
		override protected function onSetup():void {
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK );
			
			createCenterButton( ID_VIDEO, "Tutorial", ButtonIconType.VIDEO );
			createCenterButton( ID_FAQ, "F.A.Q", ButtonIconType.FAQ );
			validateCenterButtons();
		}
		
		
		override protected function onDisposed():void {
			
		}
	}
}