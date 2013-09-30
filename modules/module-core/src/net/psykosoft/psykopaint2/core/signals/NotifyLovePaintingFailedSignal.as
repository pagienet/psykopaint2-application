package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifyLovePaintingFailedSignal extends Signal
	{
		public function NotifyLovePaintingFailedSignal()
		{
			super(uint);	// status code of AMFErrorCode
		}
	}
}
