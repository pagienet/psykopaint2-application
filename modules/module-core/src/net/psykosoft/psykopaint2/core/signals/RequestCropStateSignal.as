package net.psykosoft.psykopaint2.core.signals
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestCropStateSignal extends TracingSignal
	{
		public function RequestCropStateSignal()
		{
			super(BitmapData);
		}
	}
}
