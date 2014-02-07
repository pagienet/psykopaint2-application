package net.psykosoft.psykopaint2.core.signals
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestCropSourceImageSignal extends TracingSignal
	{
		public function RequestCropSourceImageSignal()
		{
			super(BitmapData, int );
		}
	}
}
