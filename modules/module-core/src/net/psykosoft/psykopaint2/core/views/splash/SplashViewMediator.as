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

			// From view.
			view.fadeOutCompleteSignal.add( onFadeOutComplete );
		}

		override public function destroy():void {
			view.fadeOutCompleteSignal.remove( onFadeOutComplete );
			requestHideSplashScreenSignal.remove( onSplashScreenRemovalRequest );
			super.destroy();
		}

		private function onFadeOutComplete():void {
			view.parent.removeChild( view );
		}

		private function onSplashScreenRemovalRequest():void {
			view.removeSplashScreen();
		}
	}
}
