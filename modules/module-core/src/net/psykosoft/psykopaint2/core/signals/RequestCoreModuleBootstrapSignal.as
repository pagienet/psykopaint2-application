package net.psykosoft.psykopaint2.core.signals
{

	import flash.display.Stage;

	import org.osflash.signals.Signal;

	public class RequestCoreModuleBootstrapSignal extends Signal
	{
		public function RequestCoreModuleBootstrapSignal() {
			super( Stage );
		}
	}
}
