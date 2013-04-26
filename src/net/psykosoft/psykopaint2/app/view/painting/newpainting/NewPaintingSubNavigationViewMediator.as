package net.psykosoft.psykopaint2.app.view.painting.newpainting
{

	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;

	public class NewPaintingSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:NewPaintingSubNavigationView;

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

				case NewPaintingSubNavigationView.BUTTON_LABEL_SELECT_IMAGE:
					requestStateChange( new StateVO( ApplicationStateType.PAINTING_SELECT_IMAGE ) );
					break;
			}
		}
	}
}
