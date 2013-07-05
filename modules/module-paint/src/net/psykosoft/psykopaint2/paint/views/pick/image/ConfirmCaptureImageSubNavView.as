package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class ConfirmCaptureImageSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "No";
		public static const LBL_CONFIRM:String = "Yes";

		public function ConfirmCaptureImageSubNavView() {
		}

		override protected function onEnabled():void {
			navigation.setHeader( "Keep image?" );
			navigation.setLeftButton( LBL_BACK );
			navigation.setRightButton( LBL_CONFIRM );
			navigation.layout();
		}
	}
}
