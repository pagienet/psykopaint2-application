package net.psykosoft.psykopaint2.core.managers.misc
{

	import net.psykosoft.notifications.NotificationsExtension;
	import net.psykosoft.notifications.events.NotificationExtensionEvent;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;

	public class MemoryWarningManager
	{
		[Inject]
		public var notifyMemoryWarningSignal:NotifyMemoryWarningSignal;

		public function MemoryWarningManager() {
		}

		public function initialize():void {
			var notificationsExtension:NotificationsExtension = new NotificationsExtension();
			notificationsExtension.addEventListener( NotificationExtensionEvent.RECEIVED_MEMORY_WARNING, onMemoryWarning );
			notificationsExtension.initialize();
		}

		private function onMemoryWarning( event:NotificationExtensionEvent ):void {
			trace( this, "*** WARNING *** - AS3 knows of an iOS memory warning." );
			notifyMemoryWarningSignal.dispatch();
		}
	}
}
