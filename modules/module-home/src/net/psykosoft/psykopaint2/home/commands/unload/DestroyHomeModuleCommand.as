package net.psykosoft.psykopaint2.home.commands.unload
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.core.commands.DisposePaintingDataCommand;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleDestroyedSignal;

	public class DestroyHomeModuleCommand extends SequenceMacro
	{
		[Inject]
		public var notifyHomeModuleDestroyedSignal : NotifyHomeModuleDestroyedSignal;

		override public function prepare():void {

			add( DisposePaintingDataCommand 	         );
			add( DisconnectHomeModuleShakeAndBakeCommand );
			add( DestroyBookCommand );
			//add( RemoveHomeModuleDisplayCommand          );

			registerCompleteCallback( onMacroComplete );
		}

		private function onMacroComplete( success:Boolean ):void {
			if( success ) notifyHomeModuleDestroyedSignal.dispatch();
			else {
				throw new Error( "Error destroying the home module." );
			}
		}
	}
}
