package net.psykosoft.psykopaint2.app.view.starling.painting.crop
{

	import net.psykosoft.psykopaint2.app.data.types.StateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropConfirmSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class CropImageSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:CropImageSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var notifyCropConfirmSignal:NotifyCropConfirmSignal;

		override public function initialize():void {

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

			super.initialize();
		}

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {

				case CropImageSubNavigationView.BUTTON_LABEL_BACK_TO_PICK_AN_IMAGE:
					requestStateChangeSignal.dispatch( new StateVO( StateType.PAINTING_SELECT_IMAGE ) );
					break;

				case CropImageSubNavigationView.BUTTON_LABEL_CROP:
					notifyCropConfirmSignal.dispatch();
					break;
			}
		}
	}
}
