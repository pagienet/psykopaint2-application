package net.psykosoft.psykopaint2.core.signals
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestEaselUpdateSignal extends TracingSignal
	{
		public function RequestEaselUpdateSignal() {
			super( BitmapData, BitmapData ); //difusse data, normal data
		}
	}
}
