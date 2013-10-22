package net.psykosoft.psykopaint2.core.managers.misc
{

	import net.psykosoft.notifications.NotificationsExtension;
	import net.psykosoft.notifications.events.NotificationExtensionEvent;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;

	public class MemoryWarningManager
	{
		[Inject]
		public var notifyMemoryWarningSignal:NotifyMemoryWarningSignal;

		public var extension:NotificationsExtension;

		public function MemoryWarningManager() {
		}

		public function initialize():void {
			extension = new NotificationsExtension();
			extension.addEventListener( NotificationExtensionEvent.RECEIVED_MEMORY_WARNING, onMemoryWarning );
			extension.initialize();
		}

		private function onMemoryWarning( event:NotificationExtensionEvent ):void {

			ConsoleView.instance.log( this, "*** WARNING *** - AS3 knows of an iOS memory warning." );
			ConsoleView.instance.logMemory();

			// NOTE: This error can be disabled by setting CoreSettings.THROW_ERRORS_ON_MEMORY_WARNINGS to false.
			// Setting it to true can help stack trace sources of intense or bad memory usage.
			if( CoreSettings.THROW_ERRORS_ON_MEMORY_WARNINGS ) {
				throw new Error( "Memory warning!" );
			}

			notifyMemoryWarningSignal.dispatch();
		}
	}
}
