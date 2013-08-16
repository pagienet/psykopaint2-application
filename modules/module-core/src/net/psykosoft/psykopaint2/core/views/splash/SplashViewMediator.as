package net.psykosoft.psykopaint2.core.views.splash
{

	import net.psykosoft.psykopaint2.core.signals.NotifySplashScreenRemovedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class SplashViewMediator extends Mediator
	{
		[Inject]
		public var view:SplashView;

		[Inject]
		public var requestHideSplashScreenSignal:RequestHideSplashScreenSignal;

		[Inject]
		public var notifySplashScreenRemovedSignal:NotifySplashScreenRemovedSignal;

		override public function initialize():void {

			// From app.
			requestHideSplashScreenSignal.add( onSplashScreenRemovalRequest );

			// From view.
			view.removedSignal.add( onFadeOutComplete );
		}

		override public function destroy():void {
			view.removedSignal.remove( onFadeOutComplete );
			requestHideSplashScreenSignal.remove( onSplashScreenRemovalRequest );
			super.destroy();
		}

		private function onFadeOutComplete():void {
			notifySplashScreenRemovedSignal.dispatch();
			view.parent.removeChild( view );
		}

		private function onSplashScreenRemovalRequest():void {
			view.removeSplashScreen();
		}
	}
}
