package net.psykosoft.psykopaint2.home.commands.unload
{

	import net.psykosoft.psykopaint2.home.signals.RequestHomeSceneDestructionSignal;

	import robotlegs.bender.bundles.mvcs.Command;

	public class DestroyHomeSceneCommand extends Command
	{
		[Inject]
		public var requestHomeSceneDestructionSignal:RequestHomeSceneDestructionSignal;

		override public function execute():void {
			requestHomeSceneDestructionSignal.dispatch();
		}
	}
}
