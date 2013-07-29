package net.psykosoft.psykopaint2.home.commands
{

	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;

	public class SetUpHomeModuleCommand extends SequenceMacro
	{
		[Inject]
		public var notifyHomeModuleSetUpSignal:NotifyHomeModuleSetUpSignal;

		private static var _timesRan:uint = 0;

		override public function prepare():void {

			add( LoadHomeBundledAssetsCommand );
			add( BuildHomeSceneCommand );
			if( _timesRan == 0 ) add( HomeIntroAnimationCommand );

			_timesRan++;

			registerCompleteCallback( onMacroComplete );
		}

		private function onMacroComplete( success:Boolean ):void {
			notifyHomeModuleSetUpSignal.dispatch();
		}
	}
}