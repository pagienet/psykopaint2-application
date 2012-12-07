package net.psykosoft.psykopaint2.view.starling.splash
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.config.Settings;

	import net.psykosoft.psykopaint2.model.data.States;
	import net.psykosoft.psykopaint2.model.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SplashViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SplashView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		override public function initialize():void {

			Cc.info( this, "initialized" );

			// From view.
			view.splashDiedSignal.add( onViewDied );

		}

		private function onViewDied():void {

			Cc.info( this, "onViewDied" );

			view.parent.removeChild( view );
			view.dispose();
			view = null;

			requestStateChangeSignal.dispatch( new StateVO( States.HOME_SCREEN ) );
		}
	}
}
