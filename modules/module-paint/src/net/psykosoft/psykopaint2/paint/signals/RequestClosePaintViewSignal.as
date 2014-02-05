package net.psykosoft.psykopaint2.paint.signals
{
	import org.osflash.signals.Signal;

	public class RequestClosePaintViewSignal extends Signal
	{
		//true = save image, false = discard image
		public function RequestClosePaintViewSignal()
		{
			super( Boolean );
		}
	}
}
