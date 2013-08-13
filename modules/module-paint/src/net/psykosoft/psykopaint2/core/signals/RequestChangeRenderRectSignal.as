package net.psykosoft.psykopaint2.core.signals
{

	import flash.geom.Rectangle;

	import org.osflash.signals.Signal;

	public class RequestChangeRenderRectSignal extends Signal
	{
		public function RequestChangeRenderRectSignal()
		{
			super(Rectangle);
		}
	}
}
