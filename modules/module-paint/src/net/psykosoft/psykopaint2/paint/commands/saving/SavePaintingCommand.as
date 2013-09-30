package net.psykosoft.psykopaint2.paint.commands.saving
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.core.models.PaintingModel;
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
		public var paintingModel:PaintingModel;

		[Inject]
		public var saveVo:SavingProcessModel;

		override public function prepare():void {

			ConsoleView.instance.log( this, "prepare()" );

			saveVo.paintingId = paintingModel.activePaintingId;

			// *** PICK ONE ***
			add( SavePaintingAsyncCommand );
//			add( SavePaintingSyncCommand );

			registerCompleteCallback( onMacroComplete );

			notifyPaintingSavingStartedSignal.dispatch();
		}

		private function onMacroComplete( success:Boolean ):void {
			trace( this, "macro complete - success: " + success );
			saveVo.dispose();
		}
	}
}