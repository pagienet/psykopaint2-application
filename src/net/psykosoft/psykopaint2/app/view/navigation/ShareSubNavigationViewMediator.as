package net.psykosoft.psykopaint2.app.view.navigation
{

	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;

	public class ShareSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:ShareSubNavigationView;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {

				case ShareSubNavigationView.BUTTON_LABEL_BACK:
					requestStateChange( new StateVO( ApplicationStateType.PREVIOUS_STATE ) );
					break;

				default:

					// TODO: does nothing at the time...

					break;
			}
		}
	}
}
