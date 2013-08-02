package net.psykosoft.psykopaint2.core.commands.bootstrap
{

	import net.psykosoft.psykopaint2.core.commands.*;

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.core.signals.NotifyCoreModuleBootstrapCompleteSignal;

	public class BootstrapCoreModuleCommand extends SequenceMacro
	{
		[Inject]
		public var notifyCoreModuleBootstrapCompleteSignal:NotifyCoreModuleBootstrapCompleteSignal;

		override public function prepare():void {

			trace( this, "prepare()" );

			add( InitStageCommand );
			add( InitExternalDataCommand );
			add( InitShakeAndBakeCommand );
			add( InitGreensocksCommand );
			add( InitDisplayCommand );
			add( InitMemoryWarningsCommand );
			add( InitPlatformCommand );
			add( InitKeyDebuggingCommand );
			add( InitStage3dCommand );
			add( InitGestureManagerCommand );

			registerCompleteCallback( onMacroComplete );
		}

		private function onMacroComplete( success:Boolean ):void {
			if( success ) notifyCoreModuleBootstrapCompleteSignal.dispatch();
		}
	}
}
