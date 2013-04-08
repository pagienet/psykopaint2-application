package net.psykosoft.psykopaint2.app.signal.notifications
{

	import org.osflash.signals.Signal;

	public class NotifyLoadImageSourceRequestedSignal extends Signal
	{
		public function NotifyLoadImageSourceRequestedSignal() {
			super( String ); // of type ImageSourceType
		}
	}
}
