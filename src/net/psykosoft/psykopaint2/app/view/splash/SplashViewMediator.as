package net.psykosoft.psykopaint2.app.view.splash
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;

	public class SplashViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var splashView:SplashView;

		override public function initialize():void {

			super.initialize();
			registerView( splashView );
			registerEnablingState( ApplicationStateType.SPLASH_SCREEN );

			// From view.
			splashView.splashDiedSignal.add( onViewDied );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewDied():void {
			Cc.log( this, "onViewDied" );
			removeView();
			requestStateChange( new StateVO( ApplicationStateType.HOME_SCREEN ) );
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function removeView():void {
			if( !splashView ) return;
			splashView.parent.removeChild( splashView );
			splashView.disable();
			splashView = null;
		}
	}
}
