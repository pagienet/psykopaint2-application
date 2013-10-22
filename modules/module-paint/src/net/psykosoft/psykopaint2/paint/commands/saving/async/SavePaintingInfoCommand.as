package net.psykosoft.psykopaint2.paint.commands.saving.async
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingInfoSavedSignal;

	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;

	public class SavePaintingInfoCommand extends SequenceMacro
	{
		[Inject]
		public var notifyPaintingInfoSavedSignal:NotifyPaintingInfoSavedSignal;

		override public function prepare():void {

			ConsoleView.instance.log( this, "execute()" );
			ConsoleView.instance.logMemory();

			// TODO: serialize info part asynchronically here
			if( CoreSettings.RUNNING_ON_iPAD && CoreSettings.USE_IO_ANE_ON_PAINTING_FILES ) add( WritePaintingInfoANECommand );
			else add( WritePaintingInfoAS3Command );

			registerCompleteCallback( onMacroComplete );
		}

		private function onMacroComplete( success:Boolean ):void {
			ConsoleView.instance.log( this, "macro complete - success: " + success );
			ConsoleView.instance.logMemory();
			if( success ) {
				notifyPaintingInfoSavedSignal.dispatch( true );
			}
			else throw new Error( "Error saving the painting." );
		}
	}
}
