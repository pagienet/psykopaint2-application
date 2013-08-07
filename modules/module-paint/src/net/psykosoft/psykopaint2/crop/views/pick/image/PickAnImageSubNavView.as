package net.psykosoft.psykopaint2.crop.views.pick.image
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class PickAnImageSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Back";
		public static const ID_USER:String = "Your files";
		public static const ID_SAMPLES:String = "Our samples";
		public static const ID_CAMERA:String = "Your camera";
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
			createCenterButton( ID_USER, ID_USER, ButtonIconType.PICTURE );
			createCenterButton( ID_SAMPLES, ID_SAMPLES, ButtonIconType.SAMPLES );
			createCenterButton( ID_CAMERA, ID_CAMERA, ButtonIconType.CAMERA );
			validateCenterButtons();
		}
	}
}
