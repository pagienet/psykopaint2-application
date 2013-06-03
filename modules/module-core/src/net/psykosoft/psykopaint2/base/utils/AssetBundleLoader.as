package net.psykosoft.psykopaint2.base.utils
{

	import br.com.stimuli.loading.BulkLoader;

	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class AssetBundleLoader extends EventDispatcher
	{
		private var _loader:BulkLoader;
		private var _bundleName:String;
		private var _done:Boolean;

		public function AssetBundleLoader( bundleName:String ) {
			super();
			_bundleName = bundleName;
			_loader = new BulkLoader( bundleName );
		}

		public function registerAsset( url:String, id:String ):void {
			trace( this, "BulkLoader bundle: " + _bundleName + ", registering asset of id: " + id + ", with url: " + url );
			_loader.add( url, { id:id } );
		}

		public function startLoad():void {
			_done = false;
			_loader.addEventListener( BulkLoader.COMPLETE, onAllAssetsLoaded );
			trace( this, "BulkLoader bundle: " + _bundleName + " starting load." );
			_loader.start();
		}

		public function dispose():void {
			_loader.clear();
			if( _loader.hasEventListener( BulkLoader.COMPLETE ) ) {
				_loader.removeEventListener( BulkLoader.COMPLETE, onAllAssetsLoaded );
			}
			_loader = null;
		}

		private function onAllAssetsLoaded( event:Event ):void {
			_done = true;
			trace( this, "BulkLoader bundle: " + _bundleName + " completed load of all assets." );
			_loader.removeEventListener( BulkLoader.COMPLETE, onAllAssetsLoaded );
			dispatchEvent( new Event( Event.COMPLETE ) );
		}

		public function get done():Boolean {
			return _done;
		}
	}
}
