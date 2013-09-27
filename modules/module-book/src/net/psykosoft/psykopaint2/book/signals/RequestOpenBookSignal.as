package net.psykosoft.psykopaint2.book.signals
{
	import org.osflash.signals.Signal;

	public class RequestOpenBookSignal extends Signal
	{
		public function RequestOpenBookSignal()
		{
			super(String, uint);
		}
	}
}
