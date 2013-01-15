package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.newpainting
{

	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

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
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_SELECT_IMAGE ) );
					break;
				case NewPaintingSubNavigationView.BUTTON_LABEL_BACK:
					requestStateChangeSignal.dispatch( new StateVO( States.HOME_SCREEN ) );
					break;
			}
		}
	}
}
