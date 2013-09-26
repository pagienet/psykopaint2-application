package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifyUserRegistrationFailedSignal extends Signal
	{
		function NotifyUserRegistrationFailedSignal()
		{
			// fail code (see AMFErrorCode)
			super(int);
		}
	}
}
