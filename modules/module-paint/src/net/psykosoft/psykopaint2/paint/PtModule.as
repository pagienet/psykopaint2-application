package net.psykosoft.psykopaint2.paint
{

	import com.junkbyte.console.Cc;

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.CrModule;

	import org.swiftsuspenders.Injector;

	public class PtModule extends Sprite
	{
		public function PtModule() {
			super();
			trace( ">>>>> PtModule starting..." );
			var coreModule:CrModule = new CrModule();
			coreModule.moduleReadySignal.addOnce( onCoreModuleReady );
			addChild( coreModule );
		}

		private function onCoreModuleReady( coreInjector:Injector ):void {
			Cc.log( this, "core module is ready, injector: " + coreInjector );
		}
	}
}
