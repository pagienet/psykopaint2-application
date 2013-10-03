package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifyUserLogInFailedSignal extends Signal
	{
		public function NotifyUserLogInFailedSignal()
		{
			// AMFErrorCode, reason
			super(int, String);
		}
	}
}
