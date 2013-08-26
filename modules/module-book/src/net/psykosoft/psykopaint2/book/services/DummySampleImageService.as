package net.psykosoft.psykopaint2.book.services
{
	import net.psykosoft.psykopaint2.book.signals.NotifySourceImagesFetchedSignal;

	public class DummySampleImageService implements SampleImageService
	{
		[Inject]
		public var notifySourceImagesFetchedSignal : NotifySourceImagesFetchedSignal;

		public function DummySampleImageService()
		{
		}

		public function fetchImages(index : int, amount : int) : void
		{
		}
	}
}
