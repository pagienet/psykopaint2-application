package net.psykosoft.psykopaint2.home.commands.load
{

	import net.psykosoft.psykopaint2.home.signals.RequestHomeIntroSignal;

	import robotlegs.bender.bundles.mvcs.Command;

	public class HomeIntroAnimationCommand extends Command
	{
		[Inject]
		public var requestHomeIntroSignal:RequestHomeIntroSignal;

		override public function execute():void {
			requestHomeIntroSignal.dispatch();
		}
	}
}
