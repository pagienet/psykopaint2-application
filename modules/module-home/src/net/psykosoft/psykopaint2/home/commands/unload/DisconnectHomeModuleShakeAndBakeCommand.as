package net.psykosoft.psykopaint2.home.commands.unload
{

	import net.psykosoft.psykopaint2.core.managers.assets.ShakeAndBakeManager;

	import robotlegs.bender.bundles.mvcs.Command;

	public class DisconnectHomeModuleShakeAndBakeCommand extends Command
	{
		[Inject]
		public var shaker:ShakeAndBakeManager;

		override public function execute():void {
			trace( this, "execute()" );
			shaker.disconnect( ShakeAndBakeManager.HOME_CONNECTOR_URL );
		}
	}
}
