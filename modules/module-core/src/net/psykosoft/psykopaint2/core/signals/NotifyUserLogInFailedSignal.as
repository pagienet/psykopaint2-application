package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifyUserLogInFailedSignal extends Signal
	{
		public function NotifyUserLogInFailedSignal()
		{
			// AMFErrorCode, reason, firstname of user that introduced incorrect password
			super(int, String, String);
		}
	}
}
