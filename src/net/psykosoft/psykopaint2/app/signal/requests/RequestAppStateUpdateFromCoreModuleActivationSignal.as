package net.psykosoft.psykopaint2.app.signal.requests
{

	import net.psykosoft.psykopaint2.core.drawing.modules.IModule;

	import org.osflash.signals.Signal;

	public class RequestAppStateUpdateFromCoreModuleActivationSignal extends Signal
	{
		public function RequestAppStateUpdateFromCoreModuleActivationSignal() {
			super( IModule ); // Module just activated.
		}
	}
}
