package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifySmearStyleChangedSignal extends Signal
	{
		public function NotifySmearStyleChangedSignal()
		{
			// pass style name 
			super(String);
		}
	}
}
