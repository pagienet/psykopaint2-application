package net.psykosoft.psykopaint2.base.ui.base
{

	import br.com.stimuli.loading.BulkLoader;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.utils.AssetBundleLoader;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;

	import org.osflash.signals.Signal;

	public class ViewBase extends Sprite
	{
		protected var _initialized:Boolean;

		private var _loader:AssetBundleLoader;
		private var _bundleId:String;
		private var _added:Boolean;
		protected var _reported:Boolean;
		private var _requiresLoading:Boolean;

		protected var _assetsLoaded:Boolean;

		public var autoUpdates:Boolean = false;
		public var scalesToRetina:Boolean = true;

		public var addedToStageSignal:Signal;
		public var enabledSignal:Signal;
		public var setupSignal:Signal;
		public var assetsReadySignal:Signal;
		public var viewReadySignal:Signal;

		public function ViewBase() {
			super();
			trace( this, "constructor" );

			addedToStageSignal = new Signal();
			enabledSignal = new Signal();
			setupSignal = new Signal();
			assetsReadySignal = new Signal();
			viewReadySignal = new Signal();

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			visible = false;
		}

		// ---------------------------------------------------------------------
		// Public.
		// ---------------------------------------------------------------------

		public function enable():void {
			if( visible ) return;
			if( !_initialized ) setup();
			trace( this, "enabled" );
			onEnabled();
			visible = true;
			enabledSignal.dispatch();
			if( autoUpdates && !hasEventListener( Event.ENTER_FRAME ) ) {
				addEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
		}

		public function disable():void {
			if( !visible ) return;
			trace( this, "disabled" );
			onDisabled();
			visible = false;
			if( hasEventListener( Event.ENTER_FRAME ) ) {
				removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
		}

		public function dispose():void {
			_initialized = false;
			if( _loader ) {
				_loader.dispose();
				_loader = null;
			}
			onDisposed();
		}

		public function setup():void {
			trace( this, "setup" );
			onSetup();
			if( _requiresLoading ) {
				if( !_assetsLoaded ) {
					trace( this, "load started..." );
					_loader.startLoad();
				}
			}
			else {
				if( _added ) {
					trace( this, "-view ready with no assets-" );
					reportReady();
				}
			}
			setupSignal.dispatch();
			_initialized = true;
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		protected function reportReady():void {
			if( _reported ) return;
			_reported = true;
			viewReadySignal.dispatch();
		}

		// ---------------------------------------------------------------------
		// To be used by extensors...
		// ---------------------------------------------------------------------

		protected function initializeBundledAssets( bundleId:String ):void {
			_bundleId = bundleId;
			_requiresLoading = true;
			_loader = new AssetBundleLoader( bundleId );
			_loader.addEventListener( Event.COMPLETE, onBundledAssetsReady );
		}

		protected function registerBundledAsset( url:String, assetId:String, isBinary:Boolean = false ) {
			if( isBinary ) _loader.registerAsset( url, assetId, BulkLoader.TYPE_BINARY );
			else _loader.registerAsset( url, assetId );
		}

		// ---------------------------------------------------------------------
		// To override...
		// ---------------------------------------------------------------------

		protected function onUpdate():void {
			// Override.
		}

		protected function onSetup():void {
			// Override.
		}

		protected function onEnabled():void {
			// Override.
		}

		protected function onDisabled():void {
			// Override.
		}

		protected function onDisposed():void {
			// Override.
		}

		protected function onAssetsReady():void {
			// Override.
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

			// Retina scaling.
			if( scalesToRetina && !( parent is ViewBase ) ) {
				scaleX = scaleY = CoreSettings.GLOBAL_SCALING;
			}

			addedToStageSignal.dispatch( this );

			_added = true;

			if( !_reported ) {
				if( _requiresLoading ) {
					if( _assetsLoaded ) {
						trace( this, "-view ready from added and assets already loaded-" );
						reportReady();
					}
					else {
						trace( this, "added but assets not loaded yet" );
					}
				}
				else {
					trace( this, "-view ready from added and no need to load assets-" );
					reportReady();
				}
			}
		}

		private function onEnterFrame( event:Event ):void {
			onUpdate();
		}

		private function onBundledAssetsReady( event:Event ):void {
			trace( this, "assets ready" );
			onAssetsReady();
			assetsReadySignal.dispatch();

			if( _added ) {
				trace( this, "-view ready with assets-" );
				reportReady();
			}
			else {
				trace( this, "assets loaded but not yet added" );
			}

			_assetsLoaded = true;
			_loader.removeEventListener( Event.COMPLETE, onBundledAssetsReady );
		}
	}
}
