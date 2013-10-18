package net.psykosoft.psykopaint2.core.commands.bootstrap
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.core.managers.assets.ShakeAndBakeManager;

	public class ConnectCoreModuleShakeAndBakeCommand extends AsyncCommand
	{
		[Inject]
		public var shaker:ShakeAndBakeManager;

		override public function execute():void {
			trace( this, "execute()" );
			shaker.connect( ShakeAndBakeManager.CORE_CONNECTOR_URL, onShakeAndBakeConnected );
		}

		private function onShakeAndBakeConnected():void {
			trace( this, "shake and bake connected" );
			dispatchComplete( true );
		}
	}
}
