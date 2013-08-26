package net.psykosoft.psykopaint2.book.signals
{
	import net.psykosoft.psykopaint2.book.model.SourceImageRequestVO;

	import org.osflash.signals.Signal;

	public class RequestFetchSourceImagesSignal extends Signal
	{
		public function RequestFetchSourceImagesSignal()
		{
			super(SourceImageRequestVO);
		}
	}
}
