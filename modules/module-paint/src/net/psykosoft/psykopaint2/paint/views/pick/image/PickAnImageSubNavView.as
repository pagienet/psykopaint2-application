package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class PickAnImageSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Back";
		public static const LBL_USER:String = "Your files";
		public static const LBL_SAMPLES:String = "Our samples";
		public static const LBL_CAMERA:String = "Your camera";
//		public static const LBL_FACEBOOK:String = "[Facebook]";

		public function PickAnImageSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Pick an Image" );
			setLeftButton( LBL_BACK );
		}

		override protected function onSetup():void {
			super.onSetup();
			createCenterButton( LBL_USER, ButtonIconType.PICTURE );
			createCenterButton( LBL_SAMPLES, ButtonIconType.SAMPLES );
			createCenterButton( LBL_CAMERA, ButtonIconType.CAMERA );
			validateCenterButtons();
		}
	}
}
