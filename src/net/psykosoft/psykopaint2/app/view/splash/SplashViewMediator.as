package net.psykosoft.psykopaint2.app.view.splash
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SplashViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SplashView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		override public function initialize():void {

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );

			// From view.
			view.splashDiedSignal.add( onViewDied );

		}

		private function onApplicationStateChanged( newState:StateVO ):void {
			trace( this, "onApplicationStateChanged: " + newState.name );
			if( newState.name == ApplicationStateType.SPLASH_SCREEN ) {
				view.enable();
			}
			else {
				removeView();
			}
		}

		// -----------------------
		// From app.
		// -----------------------



		// -----------------------
		// From view.
		// -----------------------

		private function onViewDied():void {
			Cc.log( this, "onViewDied" );
			removeView();
			requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.HOME_SCREEN ) );
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function removeView():void {
			if( !view ) return;
			view.parent.removeChild( view );
			view.disable();
			view = null;
		}
	}
}
