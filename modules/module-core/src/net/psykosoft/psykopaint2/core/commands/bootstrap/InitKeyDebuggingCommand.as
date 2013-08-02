package net.psykosoft.psykopaint2.core.commands.bootstrap
{

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.misc.KeyDebuggingManager;

	import robotlegs.bender.bundles.mvcs.Command;

	public class InitKeyDebuggingCommand extends Command
	{
		[Inject]
		public var manager:KeyDebuggingManager;

		override public function execute():void {

			trace( this, "execute()" );

			if( !CoreSettings.USE_DEBUG_KEYS ) return;

			// Just trigger the singleton.
			manager.initialize(  );

		}
	}
}
