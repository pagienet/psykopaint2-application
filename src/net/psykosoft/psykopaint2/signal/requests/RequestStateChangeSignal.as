package net.psykosoft.psykopaint2.signal.requests
{

	import net.psykosoft.psykopaint2.model.state.vo.StateVO;

	import org.osflash.signals.Signal;

	public class RequestStateChangeSignal extends Signal
	{
		public function RequestStateChangeSignal() {
			super( StateVO );
		}
	}
}
