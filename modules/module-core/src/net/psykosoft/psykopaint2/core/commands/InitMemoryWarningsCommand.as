package net.psykosoft.psykopaint2.core.commands
{

	import net.psykosoft.psykopaint2.core.managers.misc.MemoryWarningManager;

	import robotlegs.bender.bundles.mvcs.Command;

	public class InitMemoryWarningsCommand extends Command
	{
		[Inject]
		public var manager:MemoryWarningManager;

		override public function execute():void {

			trace( this, "execute()" );

			// Just trigger the singleton.
			manager.initialize();

		}
	}
}
