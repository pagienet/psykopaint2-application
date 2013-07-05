package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class CaptureImageSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Back";
		public static const LBL_CAPTURE:String = "Capture";
		public static const LBL_FLIP:String = "Flip";

		public function CaptureImageSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			navigation.setHeader( "Capture an image" );
			navigation.setLeftButton( LBL_BACK );
			navigation.setRightButton( LBL_CAPTURE );
			navigation.addCenterButton( LBL_FLIP );
			navigation.layout();
		}
	}
}
