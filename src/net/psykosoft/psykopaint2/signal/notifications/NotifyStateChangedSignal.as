package net.psykosoft.psykopaint2.signal.notifications
{

	import net.psykosoft.psykopaint2.model.vo.StateVO;

	import org.osflash.signals.Signal;

	public class NotifyStateChangedSignal extends Signal
	{
		public function NotifyStateChangedSignal() {
			super( StateVO );
		}
	}
}
