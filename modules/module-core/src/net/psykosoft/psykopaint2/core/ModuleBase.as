package net.psykosoft.psykopaint2.core
{

	import flash.display.Sprite;

	import org.osflash.signals.Signal;

	public class ModuleBase extends Sprite
	{
		public var moduleReadySignal:Signal;

		public function ModuleBase() {
			super();
			moduleReadySignal = new Signal();
		}
	}
}
