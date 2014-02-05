package net.psykosoft.psykopaint2.paint.commands.saving
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;
	
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataSavedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingInfoSavedSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;

	/*
		Bootstraps the saving process and triggers either the sync or the async saving process.
	 */
	public class DiscardPaintingCommand extends SequenceMacro
	{
		
		[Inject]
		public var notifyPaintingSavedSignal:NotifyPaintingInfoSavedSignal;

		override public function prepare():void {

			ConsoleView.instance.log( this, "prepare()" );
			ConsoleView.instance.logMemory();
			add( DisplayDiscardingPopUpCommand ); // We always show the pop up because it is also used to "hide" the mounting of the home module.
			add( DisposeCanvasNonEssentialsCommand );
			notifyPaintingSavedSignal.dispatch( true );
		}

		
	}
}
