package net.psykosoft.psykopaint2.home.commands.load
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.core.managers.assets.ShakeAndBakeManager;

	public class ConnectHomeModuleShakeAndBakeCommand extends AsyncCommand
	{
		[Inject]
		public var shaker:ShakeAndBakeManager;

		override public function execute():void {
			trace( this, "execute()" );
			shaker.connect( ShakeAndBakeManager.HOME_CONNECTOR_URL, onShakeAndBakeConnected );
		}

		private function onShakeAndBakeConnected():void {
			trace( this, "shake and bake connected" );
			dispatchComplete( true );
		}
	}
}
