package net.psykosoft.psykopaint2.app.view.painting.crop
{

	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropConfirmSignal;

	public class CropImageSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:CropImageSubNavigationView;

		[Inject]
		public var notifyCropConfirmSignal:NotifyCropConfirmSignal;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );
		}

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {

				case CropImageSubNavigationView.BUTTON_LABEL_BACK_TO_PICK_AN_IMAGE:
					requestStateChange( new StateVO( ApplicationStateType.PAINTING_SELECT_IMAGE ) );
					break;

				case CropImageSubNavigationView.BUTTON_LABEL_CROP:
					notifyCropConfirmSignal.dispatch();
					break;
			}
		}
	}
}
