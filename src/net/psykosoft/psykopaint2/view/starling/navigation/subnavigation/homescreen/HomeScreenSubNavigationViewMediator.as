package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.homescreen
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.data.States;
	import net.psykosoft.psykopaint2.model.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class HomeScreenSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:HomeScreenSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		override public function initialize():void {

			Cc.info( this, "initialized" );

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			Cc.info( this, "button pressed: " + buttonLabel );
			switch( buttonLabel ) {
				case HomeScreenSubNavigationView.BUTTON_LABEL_0:
					requestStateChangeSignal.dispatch( new StateVO( States.TEST_SCREEN_1 ) );
					break;
				case HomeScreenSubNavigationView.BUTTON_LABEL_1:
					requestStateChangeSignal.dispatch( new StateVO( States.TEST_SCREEN_2 ) );
					break;
				case HomeScreenSubNavigationView.BUTTON_LABEL_2:
					requestStateChangeSignal.dispatch( new StateVO( States.TEST_SCREEN_3 ) );
					break;
			}
		}
	}
}
