package net.psykosoft.psykopaint2.core.commands.bootstrap
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.base.utils.io.XMLLoader;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	public class InitExternalDataCommand extends AsyncCommand
	{
		private var _xmLoader:XMLLoader;

		override public function execute():void {

			trace( this, "execute()" );

			_xmLoader = new XMLLoader();
			var date:Date = new Date();
			_xmLoader.loadAsset( "common-packaged/app-data.xml?t=" + String( date.getTime() ) + Math.round( 1000 * Math.random() ), onDataRetrieved );
		}

		private function onDataRetrieved( data:XML ):void {

			CoreSettings.VERSION = data.version;
			trace( this, "VERSION: " + CoreSettings.VERSION );

			_xmLoader.dispose();
			_xmLoader = null;

			// TODO: feed this to CoreRootView refresh version

			dispatchComplete( true );
		}
	}
}
