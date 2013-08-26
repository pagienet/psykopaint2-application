package net.psykosoft.psykopaint2.book.services
{
	import net.psykosoft.psykopaint2.book.signals.NotifySourceImagesFetchedSignal;

	public class ANECameraRollService implements CameraRollService
	{
		[Inject]
		public var notifySourceImagesFetchedSignal : NotifySourceImagesFetchedSignal;

		public function ANECameraRollService()
		{
		}

		public function fetchImages(index : int, amount : int) : void
		{
		}
	}
}
