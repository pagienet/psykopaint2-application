package net.psykosoft.psykopaint2.core.signals
{

	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestChangeRenderRectSignal extends TracingSignal
	{
		public function RequestChangeRenderRectSignal()
		{
			super(Rectangle);
		}
	}
}
