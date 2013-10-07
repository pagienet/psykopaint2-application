package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class NotifyUserPasswordReminderFailedSignal extends Signal
	{
		public function NotifyUserPasswordReminderFailedSignal() {
			// AMFErrorCode
			super( int );
		}
	}
}
