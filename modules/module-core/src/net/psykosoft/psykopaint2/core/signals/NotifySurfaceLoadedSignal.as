package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedByteArray;

	import org.osflash.signals.Signal;

	public class NotifySurfaceLoadedSignal extends Signal
	{
		public function NotifySurfaceLoadedSignal() {
			super(RefCountedByteArray);
		}
	}
}
