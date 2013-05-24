package net.psykosoft.psykopaint2.paint.signals.requests
{

	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;
	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestStateUpdateFromModuleActivationSignal extends TracingSignal
	{
		public function RequestStateUpdateFromModuleActivationSignal() {
			super( ModuleActivationVO );
		}
	}
}
