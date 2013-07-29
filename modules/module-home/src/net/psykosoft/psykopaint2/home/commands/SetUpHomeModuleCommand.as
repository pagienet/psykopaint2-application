package net.psykosoft.psykopaint2.home.commands
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;

	public class SetUpHomeModuleCommand extends SequenceMacro
	{
		[Inject]
		public var notifyHomeModuleSetUpSignal:NotifyHomeModuleSetUpSignal;

		override public function prepare():void {
		    add( LoadHomeBundledAssetsCommand );
			registerCompleteCallback( onMacroComplete );
		}

		private function onMacroComplete( success:Boolean ):void {
			notifyHomeModuleSetUpSignal.dispatch();
		}
	}
}
