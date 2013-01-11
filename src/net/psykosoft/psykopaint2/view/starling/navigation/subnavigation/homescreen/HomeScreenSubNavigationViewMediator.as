package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.homescreen
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class HomeScreenSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:HomeScreenSubNavigationView;

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
			Cc.log( this, "button pressed: " + buttonLabel );
			switch( buttonLabel ) {
				case HomeScreenSubNavigationView.BUTTON_LABEL_SETTINGS:
					requestStateChangeSignal.dispatch( new StateVO( States.FEATURE_NOT_IMPLEMENTED ) );
					break;
				case HomeScreenSubNavigationView.BUTTON_LABEL_GALLERY:
					requestStateChangeSignal.dispatch( new StateVO( States.FEATURE_NOT_IMPLEMENTED ) );
					break;
				case HomeScreenSubNavigationView.BUTTON_LABEL_NEW_PAINTING:
					requestStateChangeSignal.dispatch( new StateVO( States.SELECT_IMAGE ) );
					break;
			}
		}
	}
}
