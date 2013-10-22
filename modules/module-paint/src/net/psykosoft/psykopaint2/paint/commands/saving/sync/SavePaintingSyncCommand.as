package net.psykosoft.psykopaint2.paint.commands.saving.sync
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataSavedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingInfoSavedSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.paint.commands.ExportCanvasSurfacesCommand;

	public class SavePaintingSyncCommand extends SequenceMacro
	{
		[Inject]
		public var notifyPaintingInfoSavedSignal:NotifyPaintingInfoSavedSignal;

		[Inject]
		public var notifyPaintingDataSavedSignal:NotifyPaintingDataSavedSignal;

		override public function prepare():void {

			ConsoleView.instance.log( this, "prepare()" );

			add( ExportCanvasSurfacesCommand );
			add( SerializePaintingCommand );
			if( CoreSettings.RUNNING_ON_iPAD && CoreSettings.USE_IO_ANE_ON_PAINTING_FILES ) add( WritePaintingANECommand );
			else add( WritePaintingAS3Command );

			registerCompleteCallback( onMacroComplete );
		}

		private function onMacroComplete( success:Boolean ):void {
			trace( this, "macro complete - success: " + success );
			if( success ) {
				notifyPaintingInfoSavedSignal.dispatch( true );
				notifyPaintingDataSavedSignal.dispatch( true );
			}
			else throw new Error( "Error saving the painting." ); // TODO: should we verify saved data and remove it from disk if invalid?
		}
	}
}
