package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifyPasswordResetFailedSignal extends Signal
	{
		public function NotifyPasswordResetFailedSignal()
		{
			super(int); // AMFErrorCode
		}
	}
}
