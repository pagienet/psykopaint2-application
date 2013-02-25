package net.psykosoft.psykopaint2.app.signal.notifications
{

	import net.psykosoft.psykopaint2.app.model.state.vo.StateVO;

	import org.osflash.signals.Signal;

	public class NotifyStateChangedSignal extends Signal
	{
		public function NotifyStateChangedSignal() {
			super( StateVO );
		}
	}
}
