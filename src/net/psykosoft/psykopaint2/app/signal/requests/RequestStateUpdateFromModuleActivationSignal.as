package net.psykosoft.psykopaint2.app.signal.requests
{

	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;

	import org.osflash.signals.Signal;

	public class RequestStateUpdateFromModuleActivationSignal extends Signal
	{
		public function RequestStateUpdateFromModuleActivationSignal() {
			super( ModuleActivationVO );
		}
	}
}
