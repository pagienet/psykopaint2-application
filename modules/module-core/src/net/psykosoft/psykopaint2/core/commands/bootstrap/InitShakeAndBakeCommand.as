package net.psykosoft.psykopaint2.core.commands.bootstrap
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.base.utils.shakenbake.ShakeAndBakeConnector;

	public class InitShakeAndBakeCommand extends AsyncCommand
	{
		override public function execute():void {

			trace( this, "execute()" );

			var shakeAndBakeConnector:ShakeAndBakeConnector = new ShakeAndBakeConnector();
			shakeAndBakeConnector.connectedSignal.addOnce( onShakeAndBakeConnected );
			var swfUrl:String = "core-packaged/swf/core-assets.swf";
			trace( this, "shake and bake url: " + swfUrl );
			shakeAndBakeConnector.connectAssetsAsync( swfUrl );
		}

		private function onShakeAndBakeConnected():void {
			trace( this, "shake and bake connected" );
			dispatchComplete( true );
		}
	}
}
