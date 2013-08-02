package net.psykosoft.psykopaint2.core.views.base
{

	import flash.display.DisplayObjectContainer;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestInteractionBlockSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSplashScreenRemovalSignal;

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

		[Inject]
		public var requestAddViewToMainLayerSignal:RequestAddViewToMainLayerSignal;

		[Inject]
		public var requestSplashScreenRemovalSignal:RequestSplashScreenRemovalSignal;

		override public function initialize():void {

			// Initialize gestures.
			gestureManager.stage = view.stage;

			// From app.
			notifyMemoryWarningSignal.add( onMemoryWarning );
			requestInteractionBlockSignal.add( onInteractionBlockRequest );
			requestHideSplashScreenSignal.addOnce( onRequestHideSplashScreen );
			requestAddViewToMainLayerSignal.add( onRequestToAddViewToMainLayer );
			requestSplashScreenRemovalSignal.add( onSplashScreenRemovalRequest );
		}

		private function onSplashScreenRemovalRequest():void {
			view.removeSplashScreen();
		}

		private function onRequestToAddViewToMainLayer( child:DisplayObjectContainer ):void {
			view.addToMainLayer( child );
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
