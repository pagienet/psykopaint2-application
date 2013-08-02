package net.psykosoft.psykopaint2.core.views.debug
{

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class DebugViewMediator extends Mediator
	{
		[Inject]
		public var view:DebugView;

		[Inject]
		public var notifyMemoryWarningSignal:NotifyMemoryWarningSignal;

		override public function initialize():void {

			// From app.
			notifyMemoryWarningSignal.add( onMemoryWarning );

		}

		private function onMemoryWarning():void {
			if( CoreSettings.SHOW_MEMORY_WARNINGS ) {
				view.flashMemoryIcon();
			}
		}
	}
}
