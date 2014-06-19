package net.psykosoft.psykopaint2.paint.commands.saving.async
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingInfoSavedSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.paint.commands.saving.DisposeCanvasNonEssentialsCommand;
	import net.psykosoft.psykopaint2.paint.commands.saving.sync.SerializePPPCommand;
	import net.psykosoft.psykopaint2.paint.commands.saving.sync.SerializeIPPCommand;

	public class SavePaintingAsyncCommand extends SequenceMacro
	{
		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var notifyPaintingSavedSignal:NotifyPaintingInfoSavedSignal;

		override public function prepare():void {

			ConsoleView.instance.log( this, "prepare()" );

			add( DisposeCanvasNonEssentialsCommand );
			add( SerializePPPCommand );
			add( SerializeIPPCommand );
			add( SaveInfoAndDataCommand );

			registerCompleteCallback( onMacroComplete );
		}

		private function onMacroComplete( success:Boolean ):void {
			trace( this, "macro complete - success: " + success );
		}
	}
}
