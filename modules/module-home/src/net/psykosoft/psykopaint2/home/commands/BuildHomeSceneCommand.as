package net.psykosoft.psykopaint2.home.commands
{

	import net.psykosoft.psykopaint2.home.signals.RequestHomeSceneConstructionSignal;

	import robotlegs.bender.bundles.mvcs.Command;

	public class BuildHomeSceneCommand extends Command
	{
		[Inject]
		public var requestHomeSceneConstructionSignal:RequestHomeSceneConstructionSignal;

		override public function execute():void {
			requestHomeSceneConstructionSignal.dispatch();
		}
	}
}
