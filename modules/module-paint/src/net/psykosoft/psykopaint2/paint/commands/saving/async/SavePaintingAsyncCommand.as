package net.psykosoft.psykopaint2.paint.commands.saving.async
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingSavedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingSavingStartedSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;

	public class SavePaintingAsyncCommand extends SequenceMacro
	{
		[Inject]
		public var notifyPaintingSavingStartedSignal:NotifyPaintingSavingStartedSignal;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var notifyPaintingSavedSignal:NotifyPaintingSavedSignal;

		override public function prepare():void {

			ConsoleView.instance.log( this, "prepare()" );



			registerCompleteCallback( onMacroComplete );

			notifyPaintingSavingStartedSignal.dispatch();
		}

		private function onMacroComplete( success:Boolean ):void {
			trace( this, "macro complete - success: " + success );
			if( success ) notifyPaintingSavedSignal.dispatch( true );
			else throw new Error( "Error saving the painting." ); // TODO: should we verify saved data and remove it from disk if invalid?
		}
	}
}
