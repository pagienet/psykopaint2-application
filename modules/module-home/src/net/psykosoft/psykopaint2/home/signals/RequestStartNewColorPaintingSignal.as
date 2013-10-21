package net.psykosoft.psykopaint2.home.signals
{
	import org.osflash.signals.Signal;

	public class RequestStartNewColorPaintingSignal extends Signal
	{
		public function RequestStartNewColorPaintingSignal()
		{
			// the surface id with which to create a surface
			super(uint);
		}
	}
}
