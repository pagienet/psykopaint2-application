package net.psykosoft.psykopaint2.core.commands
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.data.RetrievePaintingsDataProcessModel;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;

	public class RetrieveAllPaintingDataCommand extends SequenceMacro
	{
		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var retrieveModel:RetrievePaintingsDataProcessModel;

		private var _time:uint;

		override public function prepare():void {

			trace( this, "prepare()" );
			_time = getTimer();

			add( RetrieveSavedPaintingNamesCommand );
			add( RetrieveAllSavedPaintingInfosCommand );

			registerCompleteCallback( onMacroComplete );
		}

		private function onMacroComplete( success:Boolean ):void {
			trace( this, "macro complete - success: " + success );
			retrieveModel.dispose();
			ConsoleView.instance.log( this, "done - " + String( getTimer() - _time ) );
		}
	}
}
