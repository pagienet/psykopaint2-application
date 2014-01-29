package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class NotifyUserPasswordReminderSentSignal extends Signal
	{
		public function NotifyUserPasswordReminderSentSignal() {
			super( String ); // Email
		}
	}
}
