package net.psykosoft.psykopaint2.app.view.splash
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SplashViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SplashView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		override public function initialize():void {

			// From view.
			view.splashDiedSignal.add( onViewDied );

		}

		private function onViewDied():void {

			Cc.log( this, "onViewDied" );

			view.parent.removeChild( view );
			view.dispose();
			view = null;

			requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.HOME_SCREEN ) );
		}
	}
}
