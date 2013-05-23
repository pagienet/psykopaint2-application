package net.psykosoft.psykopaint2.paint.signals.requests
{

	import net.psykosoft.psykopaint2.base.robotlegs.BsTracingSignal;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;

	public class PtRequestStateUpdateFromModuleActivationSignal extends BsTracingSignal
	{
		public function PtRequestStateUpdateFromModuleActivationSignal() {
			super( ModuleActivationVO );
		}
	}
}
