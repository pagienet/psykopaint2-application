package net.psykosoft.psykopaint2.core.views.splash
{

	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class SplashViewMediator extends Mediator
	{
		[Inject]
		public var view:SplashView;

		[Inject]
		public var requestHideSplashScreenSignal:RequestHideSplashScreenSignal;

		override public function initialize():void {

			// From app.
			requestHideSplashScreenSignal.add( onSplashScreenRemovalRequest );
		}

		override public function destroy():void {
			requestHideSplashScreenSignal.remove( onSplashScreenRemovalRequest );
			super.destroy();
		}

		private function onSplashScreenRemovalRequest():void {
			view.dispose();
			view.parent.removeChild( view );
		}
	}
}
