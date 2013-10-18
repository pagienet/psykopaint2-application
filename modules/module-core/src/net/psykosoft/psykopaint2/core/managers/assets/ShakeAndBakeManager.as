package net.psykosoft.psykopaint2.core.managers.assets
{

	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.base.utils.shakenbake.ShakeAndBakeConnector;

	public class ShakeAndBakeManager
	{
		public static const CORE_CONNECTOR_URL:String = "core-packaged/swf/core-assets.swf";
		public static const HOME_CONNECTOR_URL:String = "home-packaged/swf/home-assets.swf";
		public static const PAINT_CONNECTOR_URL:String = "paint-packaged/swf/paint-assets.swf";

		private var _connectors:Dictionary;

		public function ShakeAndBakeManager() {
			super();
			_connectors = new Dictionary();
		}

		public function connect( connectorUrl:String, onComplete:Function ):void {

			// Make sure we don't connect twice.
			if( _connectors[ connectorUrl ] ) throw new Error( "Already connected: " + connectorUrl );

			trace( this, "--- CONNECTING SHAKE AND BAKE: " + connectorUrl + " ---" );

			// Perform the connection.
			var connector:ShakeAndBakeConnector = new ShakeAndBakeConnector();
			connector.connectedSignal.addOnce( onComplete );
			connector.connectAssetsAsync( connectorUrl );
			_connectors[ connectorUrl ] = connector;
		}

		public function disconnect( connectorUrl:String ):void {

			// Was it connected?
			if( !_connectors[ connectorUrl ] ) throw new Error( "No connection found: " + connectorUrl );

			trace( this, "--- DISCONNECTING SHAKE AND BAKE: " + connectorUrl + " ---" );

			// Disconnect.
			var connector:ShakeAndBakeConnector = _connectors[ connectorUrl ];
			connector.cleanUp();
			_connectors[ connectorUrl ] = null;
			connector = null;
		}
	}
}
