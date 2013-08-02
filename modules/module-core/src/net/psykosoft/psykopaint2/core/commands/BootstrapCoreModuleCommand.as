package net.psykosoft.psykopaint2.core.commands
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.signals.NotifyCoreModuleBootstrapCompleteSignal;

	public class BootstrapCoreModuleCommand extends SequenceMacro
	{
		[Inject]
		public var notifyCoreModuleBootstrapCompleteSignal:NotifyCoreModuleBootstrapCompleteSignal;

		override public function prepare():void {

			trace( this, "prepare()" );

			add( InitShakeAndBakeCommand );
			add( InitMemoryWarningsCommand );
			add( InitPlatformCommand );
			add( InitStageCommand );
			if( CoreSettings.USE_DEBUG_KEYS ) add( InitKeyDebuggingCommand );
			add( InitStage3dCommand );

			registerCompleteCallback( onMacroComplete );
		}

		private function onMacroComplete( success:Boolean ):void {
			if( success ) notifyCoreModuleBootstrapCompleteSignal.dispatch();
		}
	}
}
