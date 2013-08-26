package net.psykosoft.psykopaint2.book.services
{
	import net.psykosoft.psykopaint2.book.signals.NotifySourceImagesFetchedSignal;

	public class DummyCameraRollService implements CameraRollService
	{
		[Inject]
		public var notifySourceImagesFetchedSignal : NotifySourceImagesFetchedSignal;

		public function DummyCameraRollService()
		{
		}

		public function fetchImages(index : int, amount : int) : void
		{
		}
	}
}
