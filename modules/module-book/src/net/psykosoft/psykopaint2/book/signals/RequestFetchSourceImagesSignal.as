package net.psykosoft.psykopaint2.book.signals
{
	import org.osflash.signals.Signal;

	public class RequestFetchSourceImagesSignal extends Signal
	{
		public function RequestFetchSourceImagesSignal()
		{
			// BookImageSource, index for first image, number of images to fetch
			super(String, int, int);
		}
	}
}
