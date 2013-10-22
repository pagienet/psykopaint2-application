package net.psykosoft.psykopaint2.paint.commands.saving.async
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import flash.system.System;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataSavedSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;

	public class SavePaintingDataCommand extends SequenceMacro
	{
		[Inject]
		public var notifyPaintingDataSavedSignal:NotifyPaintingDataSavedSignal;

		override public function prepare():void {

			ConsoleView.instance.log( this, "execute()" );
			ConsoleView.instance.logMemory();

			// TODO: serialize data part asynchronically here
			if( CoreSettings.RUNNING_ON_iPAD && CoreSettings.USE_IO_ANE_ON_PAINTING_FILES ) add( WritePaintingDataANECommand );
			else add( WritePaintingDataAS3Command );

			registerCompleteCallback( onMacroComplete );
		}

		private function onMacroComplete( success:Boolean ):void {
			System.gc();
			ConsoleView.instance.log( this, "macro complete - success: " + success );
			ConsoleView.instance.logMemory();
			if( success ) {
				notifyPaintingDataSavedSignal.dispatch( true );
			}
			else throw new Error( "Error saving the painting." );
		}
	}
}
