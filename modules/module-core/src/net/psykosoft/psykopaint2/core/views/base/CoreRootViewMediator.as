package net.psykosoft.psykopaint2.core.views.base
{

	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.signals.notifications.NotifyMemoryWarningSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class CoreRootViewMediator extends Mediator
	{
		[Inject]
		public var view:CoreRootView;

		[Inject]
		public var gestureManager:GestureManager;

		[Inject]
		public var notifyMemoryWarningSignal:NotifyMemoryWarningSignal;

		override public function initialize():void {

			// Initialize gestures.
			gestureManager.stage = view.stage;

			// From app.
			notifyMemoryWarningSignal.add( onMemoryWarning );
		}

		private function onMemoryWarning():void {
			if( CoreSettings.VISUALIZE_MEMORY_WARNINGS ) {
				view.flashMemoryIcon();
			}
		}
	}
}
