package net.psykosoft.psykopaint2.paint.signals
{
	import org.osflash.signals.Signal;

	public class NotifyPickedColorChangedSignal extends Signal
	{
		public function NotifyPickedColorChangedSignal()
		{
			super(uint,int, Boolean );
		}
	}
}
