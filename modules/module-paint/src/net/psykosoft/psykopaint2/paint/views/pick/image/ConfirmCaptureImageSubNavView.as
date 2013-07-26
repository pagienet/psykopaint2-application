package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class ConfirmCaptureImageSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Discard";
		public static const LBL_CONFIRM:String = "Keep";

		public function ConfirmCaptureImageSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Take a picture" );
			setLeftButton( LBL_BACK, ButtonIconType.DISCARD );
			setRightButton( LBL_CONFIRM, ButtonIconType.OK );
		}
	}
}
