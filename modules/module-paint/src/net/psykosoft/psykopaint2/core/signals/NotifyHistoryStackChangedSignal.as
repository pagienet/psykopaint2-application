package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifyHistoryStackChangedSignal extends Signal
	{
		public function NotifyHistoryStackChangedSignal()
		{
			// amount of undo items, amount of redo items
			super(int, int);
		}
	}
}
