package net.psykosoft.psykopaint2.view.starling.navigation
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.config.Settings;

	import net.psykosoft.psykopaint2.model.state.data.States;

	import net.psykosoft.psykopaint2.model.state.vo.StateVO;

	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.homescreen.HomeScreenSubNavigationView;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class NavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:NavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		override public function initialize():void {

			Cc.info( this, "initialized" );

			// View starts disabled.
			view.disable();

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );

			// From view.
			view.backButtonTriggeredSignal.add( onViewBackButtonTriggered );

			// If the splash screen is not being shown,
			// it is this mediator's responsibility to trigger the home state.
			if( !Settings.SHOW_SPLASH_SCREEN ) {
				requestStateChangeSignal.dispatch( new StateVO( States.HOME_SCREEN ) );
			}

		}

		private function onViewBackButtonTriggered():void {
			requestStateChangeSignal.dispatch( new StateVO( States.PREVIOUS_STATE ) );
		}

		private function onApplicationStateChanged( newState:StateVO ):void {
			Cc.info( this, "state changed: " + newState.name );
			if( newState.name != States.SPLASH_SCREEN ) {
				view.enable();
				evaluateSubNavigation( newState );
				evaluateBackButton( newState );
			}
		}

		private function evaluateBackButton( state:StateVO ):void {
			if( state.name == States.HOME_SCREEN ) {
				view.hideBackButton();
			}
			else {
				view.showBackButton();
			}
		}

		private function evaluateSubNavigation( state:StateVO ):void {
			switch( state.name ) {
				case States.HOME_SCREEN:
					view.enableSubNavigationView( new HomeScreenSubNavigationView() );
					break;
				default:
					view.disableSubNavigation();
			}
		}
	}
}
