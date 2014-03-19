package net.psykosoft.psykopaint2.paint.views.brush
{

	
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.IconButton;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationBg;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class UpgradeSubNavView extends SubNavigationViewBase
	{
		public static const ID_CANCEL:String = "Cancel";
		public static const ID_BUY:String = "Upgrade";
	
		public function UpgradeSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Try or Buy" );
			
			setBgType( NavigationBg.BG_TYPE_WOOD_LOW );
			
			createCenterButton( ID_CANCEL,ID_CANCEL, ButtonIconType.CANCEL_UPGRADE, IconButton, null, true, true, false );
			createCenterButton( ID_BUY,ID_CANCEL, ButtonIconType.BUY_UPGRADE, IconButton, null, true, true, false );
			validateCenterButtons();
		
		}

	
		
	}
}
