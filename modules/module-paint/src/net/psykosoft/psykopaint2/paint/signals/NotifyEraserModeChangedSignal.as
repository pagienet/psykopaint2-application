package net.psykosoft.psykopaint2.paint.signals
{
	import org.osflash.signals.Signal;

	public class NotifyEraserModeChangedSignal extends Signal
	{
		public function NotifyEraserModeChangedSignal()
		{
			super( Boolean );
		}
	}
}
