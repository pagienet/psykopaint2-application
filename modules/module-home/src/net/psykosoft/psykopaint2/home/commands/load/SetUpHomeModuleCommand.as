package net.psykosoft.psykopaint2.home.commands.load
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.core.commands.RetrievePaintingDataCommand;
	import net.psykosoft.psykopaint2.home.commands.*;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;

	public class SetUpHomeModuleCommand extends SequenceMacro
	{
		[Inject]
		public var notifyHomeModuleSetUpSignal:NotifyHomeModuleSetUpSignal;

		override public function prepare():void {

			trace( this, "prepare()" );

			add( LoadHomeBundledAssetsCommand );
			add( InitializeHomeModuleViewsCommand );
			add( RetrievePaintingDataCommand );
			add( UpdateEaselWithLatestPaintingCommand );

			registerCompleteCallback( onMacroComplete );
		}

		private function onMacroComplete( success:Boolean ):void {
			if( success ) notifyHomeModuleSetUpSignal.dispatch();
			else throw new Error( "Error setting up the home module." );
		}
	}
}