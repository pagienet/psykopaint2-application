package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;

	import org.osflash.signals.Signal;

	public class NotifyModuleActivatedSignal extends Signal
	{
		public function NotifyModuleActivatedSignal() {
			super( ModuleActivationVO );
		}
	}
}
