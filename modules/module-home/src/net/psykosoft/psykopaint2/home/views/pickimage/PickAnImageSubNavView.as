package net.psykosoft.psykopaint2.home.views.pickimage
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class PickAnImageSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Back";
		public static const ID_USER:String = "Your Photos";
		public static const ID_SAMPLES:String = "Ready-To";
		public static const ID_CAMERA:String = "Take a photo";
		public static const ID_SCRATCH:String = "Regular Painting";
//		public static const ID_FACEBOOK:String = "[Facebook]";

		public function PickAnImageSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Pick an Image" );
			setLeftButton( ID_BACK, ID_BACK );
		}

		override protected function onSetup():void {
			super.onSetup();
			createCenterButton( ID_SCRATCH, ID_SCRATCH, ButtonIconType.BLANK_CANVAS );
			createCenterButton( ID_USER, ID_USER, ButtonIconType.CAMERA_ROLL );
			createCenterButton( ID_SAMPLES, ID_SAMPLES, ButtonIconType.SAMPLES );
			createCenterButton( ID_CAMERA, ID_CAMERA, ButtonIconType.CAMERA );
			validateCenterButtons();
		}
	}
}
