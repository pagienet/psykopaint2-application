package net.psykosoft.psykopaint2.app.view.painting.newpainting
{

	import net.psykosoft.psykopaint2.app.data.types.StateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class NewPaintingSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:NewPaintingSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		override public function initialize():void {

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {
				case NewPaintingSubNavigationView.BUTTON_LABEL_SELECT_IMAGE:
					requestStateChangeSignal.dispatch( new StateVO( StateType.PAINTING_SELECT_IMAGE ) );
					break;
				case NewPaintingSubNavigationView.BUTTON_LABEL_BACK:
					requestStateChangeSignal.dispatch( new StateVO( StateType.HOME_SCREEN ) );
					break;
			}
		}
	}
}
