package net.psykosoft.psykopaint2.core.commands
{

	import net.psykosoft.psykopaint2.core.managers.misc.KeyDebuggingManager;

	import robotlegs.bender.bundles.mvcs.Command;

	public class InitKeyDebuggingCommand extends Command
	{
		[Inject]
		public var manager:KeyDebuggingManager;

		override public function execute():void {

			trace( this, "execute()" );

			// Just trigger the singleton.
			manager.initialize(  );

		}
	}
}
