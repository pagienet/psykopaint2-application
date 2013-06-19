package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifyHistoryStackChangedSignal extends Signal
	{
		public function NotifyHistoryStackChangedSignal()
		{
			// whether or not undo is available
			super(Boolean);
		}
	}
}
