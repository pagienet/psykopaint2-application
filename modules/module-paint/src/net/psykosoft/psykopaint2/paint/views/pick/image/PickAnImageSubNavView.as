package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class PickAnImageSubNavView extends SubNavigationViewBase
	{
		public static const LBL_USER:String = "Your files";
		public static const LBL_SAMPLES:String = "Our samples";
		public static const LBL_CAMERA:String = "[Your camera]";
		public static const LBL_FACEBOOK:String = "[Facebook]";

		public function PickAnImageSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			navigation.setHeader( "Pick an Image" );

			navigation.addCenterButton( LBL_USER );
			navigation.addCenterButton( LBL_SAMPLES );
			navigation.addCenterButton( LBL_CAMERA );
			navigation.addCenterButton( LBL_FACEBOOK );

			navigation.layout();
		}
	}
}
