package net.psykosoft.psykopaint2.base.utils
{

	import flash.display.Sprite;

	import org.osflash.signals.Signal;

	public class ModuleBase extends Sprite
	{
		public var isStandalone:Boolean = true;

		public var moduleReadySignal:Signal;

		public function ModuleBase() {
			super();
			moduleReadySignal = new Signal();
			
			//does not seem to do harm and fixes the "upper left corner not paintable" error
			mouseEnabled = false;
		}
	}
}
