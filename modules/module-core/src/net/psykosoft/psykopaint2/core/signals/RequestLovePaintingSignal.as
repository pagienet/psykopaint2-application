package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class RequestLovePaintingSignal extends Signal
	{
		public function RequestLovePaintingSignal()
		{
			// painting ID
			super(int);
		}
	}
}
