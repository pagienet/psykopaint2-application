package net.psykosoft.psykopaint2.core.commands
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.data.RetrievePaintingsVO;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;

	public class RetrieveAllPaintingDataCommand extends SequenceMacro
	{
		[Inject]
		public var paintingModel:PaintingModel;

		private var _retrieveVoInstance:RetrievePaintingsVO;
		private var _time:uint;

		override public function prepare():void {

			trace( this, "prepare()" );
			_time = getTimer();

			mapMacroConsistentData();

			add( RetrieveSavedPaintingNamesCommand );
			add( RetrieveAllSavedPaintingInfosCommand );

			registerCompleteCallback( onMacroComplete );
		}

		private function onMacroComplete( success:Boolean ):void {
			trace( this, "macro complete - success: " + success );
			unMapMacroConsistentData();
			ConsoleView.instance.log( this, "done - " + String( getTimer() - _time ) );
		}

		private function mapMacroConsistentData():void {
			trace( this, "mapping..." );
			_retrieveVoInstance = new RetrievePaintingsVO();
			injector.map( RetrievePaintingsVO ).toValue( _retrieveVoInstance );
		}

		private function unMapMacroConsistentData():void {
			trace( this, "un-mapping..." );
			injector.unmap( RetrievePaintingsVO );
			if( _retrieveVoInstance ) _retrieveVoInstance.dispose();
		}
	}
}
