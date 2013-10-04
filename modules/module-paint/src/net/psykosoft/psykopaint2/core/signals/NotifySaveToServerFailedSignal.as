package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifySaveToServerFailedSignal extends Signal
	{
		public function NotifySaveToServerFailedSignal()
		{
			// AMFErrorCode, string containing reason as communicated by service
			super(int, String);
		}
	}
}
