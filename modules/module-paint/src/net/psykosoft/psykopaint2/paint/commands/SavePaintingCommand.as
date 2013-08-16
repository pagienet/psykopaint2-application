package net.psykosoft.psykopaint2.paint.commands
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.core.commands.HidePopUpCommand;

	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.UserModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingSavedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingSavingStartedSignal;
	import net.psykosoft.psykopaint2.paint.data.SavePaintingVO;

	public class SavePaintingCommand extends SequenceMacro
	{
		[Inject]
		public var userModel:UserModel;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var canvasHistoryModel:CanvasHistoryModel;

		[Inject]
		public var notifyPaintingSavingStartedSignal:NotifyPaintingSavingStartedSignal;

		[Inject]
		public var notifyPaintingSavedSignal:NotifyPaintingSavedSignal;

		override public function prepare():void {

			trace( this, "prepare()" );

			// Do not save if there is nothing to save.
			if( !canvasHistoryModel.hasHistory ) {
				notifyPaintingSavedSignal.dispatch( true );
				return;
			}

			mapMacroConsistentData();

			add( DisplaySavingPopUpCommand );
			add( ExportCanvasSurfacesCommand );
			add( SerializePaintingCommand );
			add( WritePaintingCommand );
			add( HidePopUpCommand );

			registerCompleteCallback( onMacroComplete );

			notifyPaintingSavingStartedSignal.dispatch();
		}

		private function onMacroComplete( success:Boolean ):void {
			trace( this, "macro complete - success: " + success );
			unMapMacroConsistentData();
			if( success ) notifyPaintingSavedSignal.dispatch( true );
			else throw new Error( "Error saving the painting." ); // TODO: should we verify saved data and remove it from disk if invalid?
		}

		private function mapMacroConsistentData():void {
			injector.map( SavePaintingVO ).toValue( new SavePaintingVO( paintingModel.activePaintingId, userModel.uniqueUserId ) );
		}

		private function unMapMacroConsistentData():void {
			injector.getInstance(SavePaintingVO).dispose();
			injector.unmap( SavePaintingVO );
		}
	}
}
