package net.psykosoft.psykopaint2.app.signal.requests
{

	import net.psykosoft.psykopaint2.app.data.vos.StateVO;

	import org.osflash.signals.Signal;

	public class RequestStateChangeSignal extends Signal
	{
		public function RequestStateChangeSignal() {
			super( StateVO );
		}
	}
}
