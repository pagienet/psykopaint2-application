package net.psykosoft.psykopaint2.home.commands.unload
{

	import net.psykosoft.psykopaint2.home.commands.*;

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.core.commands.DisposePaintingDataCommand;

	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleDestroyedSignal;

	public class DestroyHomeModuleCommand extends SequenceMacro
	{
		[Inject]
		public var notifyHomeModuleDestroyedSignal : NotifyHomeModuleDestroyedSignal;

		override public function prepare():void {
			// TODO: use a command to clean up all bulkloader resources?

			add( DestroyHomeSceneCommand );
			add( DisposePaintingDataCommand );
			add( DumpHomeBundledAssetsCommand );

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
