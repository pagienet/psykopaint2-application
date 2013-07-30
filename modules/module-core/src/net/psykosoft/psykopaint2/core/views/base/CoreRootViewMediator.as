package net.psykosoft.psykopaint2.core.views.base
{

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestInteractionBlockSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class CoreRootViewMediator extends Mediator
	{
		[Inject]
		public var view:CoreRootView;

		[Inject]
		public var gestureManager:GestureManager;

		[Inject]
		public var notifyMemoryWarningSignal:NotifyMemoryWarningSignal;

		[Inject]
		public var requestInteractionBlockSignal:RequestInteractionBlockSignal;

		[Inject]
		public var requestHideSplashScreenSignal : RequestHideSplashScreenSignal;

		override public function initialize():void {

			// Initialize gestures.
			gestureManager.stage = view.stage;

			// From app.
			notifyMemoryWarningSignal.add( onMemoryWarning );
			requestInteractionBlockSignal.add( onInteractionBlockRequest );
			requestHideSplashScreenSignal.addOnce( onRequestHideSplashScreen );
		}

		private function onRequestHideSplashScreen() : void
		{
			view.removeSplashScreen();
		}

		private function onInteractionBlockRequest( block:Boolean ):void {
			view.showBlocker( block );
		}

		private function onMemoryWarning():void {
			if( CoreSettings.SHOW_MEMORY_WARNINGS ) {
				view.flashMemoryIcon();
			}
		}
	}
}
