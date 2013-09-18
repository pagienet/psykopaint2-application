package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifyUserLogInFailedSignal extends Signal
	{
		public function NotifyUserLogInFailedSignal()
		{
			// fail code (see AMFErrorCode)
			super(int);
		}
	}
}
