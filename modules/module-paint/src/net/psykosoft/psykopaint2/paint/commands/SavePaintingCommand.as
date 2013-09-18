package net.psykosoft.psykopaint2.paint.commands
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.commands.HidePopUpCommand;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingSavedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingSavingStartedSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.paint.data.SavePaintingVO;

	public class SavePaintingCommand extends SequenceMacro
	{
		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var canvasHistoryModel:CanvasHistoryModel;

		[Inject]
		public var notifyPaintingSavingStartedSignal:NotifyPaintingSavingStartedSignal;

		[Inject]
		public var notifyPaintingSavedSignal:NotifyPaintingSavedSignal;

		private var _savingVoInstance:SavePaintingVO;
		private var _time:uint;

		override public function prepare():void {

			ConsoleView.instance.log( this, "prepare()" );
			_time = getTimer();


			// Do not save if there is nothing to save.
			if( !canvasHistoryModel.hasHistory ) {
				notifyPaintingSavedSignal.dispatch( true );
				return;
			}

			mapMacroConsistentData();

			add( DisplaySavingPopUpCommand );
			add( ExportCanvasSurfacesCommand );
			add( SerializePaintingCommand );
			if( CoreSettings.RUNNING_ON_iPAD && CoreSettings.USE_IO_ANE_ON_PAINTING_FILES ) add( WritePaintingDataANECommand );
			else add( WritePaintingAS3Command );
			add( HidePopUpCommand );

			registerCompleteCallback( onMacroComplete );

			notifyPaintingSavingStartedSignal.dispatch();
		}

		private function onMacroComplete( success:Boolean ):void {
			trace( this, "macro complete - success: " + success );
			unMapMacroConsistentData();
			if( success ) notifyPaintingSavedSignal.dispatch( true );
			else throw new Error( "Error saving the painting." ); // TODO: should we verify saved data and remove it from disk if invalid?
			ConsoleView.instance.log( this, "done - " + String( getTimer() - _time ) );
		}

		private function mapMacroConsistentData():void {
			trace( this, "mapping..." );
			_savingVoInstance = new SavePaintingVO( paintingModel.activePaintingId );
			injector.map( SavePaintingVO ).toValue( _savingVoInstance );
		}

		private function unMapMacroConsistentData():void {
			trace( this, "un-mapping..." );
			injector.unmap( SavePaintingVO );
			if( _savingVoInstance ) _savingVoInstance.dispose();
		}
	}
}
