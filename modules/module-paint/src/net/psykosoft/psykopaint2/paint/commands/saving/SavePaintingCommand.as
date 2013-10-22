package net.psykosoft.psykopaint2.paint.commands.saving
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;

	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingInfoSavedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingSavingStartedSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.paint.commands.saving.async.SavePaintingAsyncCommand;
	import net.psykosoft.psykopaint2.paint.commands.saving.sync.SavePaintingSyncCommand;
	import net.psykosoft.psykopaint2.core.models.SavingProcessModel;

	/*
		Bootstraps the saving process and triggers either the sync or the async saving process.
	 */
	public class SavePaintingCommand extends SequenceMacro
	{
		[Inject]
		public var notifyPaintingSavingStartedSignal:NotifyPaintingSavingStartedSignal;

		[Inject]
		public var notifyPaintingInfoSavedSignal:NotifyPaintingInfoSavedSignal;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var saveVo:SavingProcessModel;

		[Inject]
		public var canvasHistoryModel:CanvasHistoryModel;

		override public function prepare():void {

			ConsoleView.instance.log( this, "prepare()" );
			ConsoleView.instance.logMemory();

			saveVo.paintingId = paintingModel.activePaintingId;

			add( DisplaySavingPopUpCommand ); // We always show the pop up because it is also used to "hide" the mounting of the home module.
			if( canvasHistoryModel.hasHistory && CoreSettings.USE_SAVING ) {
				if( CoreSettings.USE_ASYNC_SAVING ) add( SavePaintingAsyncCommand );
				else add( SavePaintingSyncCommand );
			}
			else notifyPaintingInfoSavedSignal.dispatch( true );

			registerCompleteCallback( onMacroComplete );

			notifyPaintingSavingStartedSignal.dispatch();
		}

		private function onMacroComplete( success:Boolean ):void {
			trace( this, "macro complete - success: " + success );
			canvasHistoryModel.clearHistory(); // Saving can occur without dismounting the paint module, this is to avoid unnecessary savings in such cases.
			saveVo.dispose();
		}
	}
}
