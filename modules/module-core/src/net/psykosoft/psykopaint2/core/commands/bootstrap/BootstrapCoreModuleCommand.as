package net.psykosoft.psykopaint2.core.commands.bootstrap
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.core.signals.NotifyCoreModuleBootstrapCompleteSignal;

	public class BootstrapCoreModuleCommand extends SequenceMacro
	{
		[Inject]
		public var notifyCoreModuleBootstrapCompleteSignal:NotifyCoreModuleBootstrapCompleteSignal;

		override public function prepare():void {

			trace( this, "prepare()" );

			add( InitPlatformCommand       );
			add( InitStageCommand          );
			add( InitExternalDataCommand   );
			add( ConnectCoreModuleShakeAndBakeCommand   );
			add( InitManagersCommand       );
			add( InitDisplayCommand        );
			add( InitStage3dCommand        );
			add( InitAMFCommand            );

			registerCompleteCallback( onMacroComplete );
		}

		private function onMacroComplete( success:Boolean ):void {
			if( success ) notifyCoreModuleBootstrapCompleteSignal.dispatch();
		}
	}
}
