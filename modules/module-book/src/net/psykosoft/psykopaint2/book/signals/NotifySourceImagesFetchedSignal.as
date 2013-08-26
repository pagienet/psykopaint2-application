package net.psykosoft.psykopaint2.book.signals
{
	import net.psykosoft.psykopaint2.book.model.SourceImageCollectionVO;

	import org.osflash.signals.Signal;

	public class NotifySourceImagesFetchedSignal extends Signal
	{
		public function NotifySourceImagesFetchedSignal()
		{
			super(SourceImageCollectionVO);
		}
	}
}
