package net.psykosoft.psykopaint2.core.signals
{

	import flash.utils.ByteArray;

	import org.osflash.signals.Signal;

	public class NotifySurfaceLoadedSignal extends Signal
	{
		public function NotifySurfaceLoadedSignal() {
			super(ByteArray);
		}
	}
}
