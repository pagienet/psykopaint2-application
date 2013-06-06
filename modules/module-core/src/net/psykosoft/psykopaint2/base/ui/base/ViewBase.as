package net.psykosoft.psykopaint2.base.ui.base
{

	import br.com.stimuli.loading.BulkLoader;

	import flash.display.Sprite;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.base.utils.AssetBundleLoader;

	import org.osflash.signals.Signal;

	public class ViewBase extends Sprite
	{
		protected var _initialized:Boolean;

		private var _loader:AssetBundleLoader;
		private var _bundleId:String;
		private var _bundledAssetsLoaded:Boolean;

		public var autoUpdates:Boolean = false;
		public var scalesToRetina:Boolean = true;

		public var addedToStageSignal:Signal;
		public var enabledSignal:Signal;
		public var setupSignal:Signal;

		public function ViewBase() {
			super();
			trace( this, "constructor" );
			addedToStageSignal = new Signal();
			enabledSignal = new Signal();
			setupSignal = new Signal();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			visible = false;
		}

		// ---------------------------------------------------------------------
		// Public.
		// ---------------------------------------------------------------------

		public function enable():void {
			if( visible ) return;
			trace( this, "enabled" );
			if( !_initialized ) setup();
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
			if( _loader ) _loader.dispose();
			onDisposed();
		}

		// ---------------------------------------------------------------------
		// To be used by extensors...
		// ---------------------------------------------------------------------

		protected function initializeBundledAssets( bundleId:String ):void {
			_bundleId = bundleId;
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
		// Private.
		// ---------------------------------------------------------------------

		private function setup():void {
			trace( this, "setup" );
			onSetup();
			if( !_bundledAssetsLoaded && _loader ) _loader.startLoad();
			setupSignal.dispatch();
			_initialized = true;
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

			// Retina scaling.
			if( scalesToRetina && !( parent is ViewBase ) ) {
				scaleX = scaleY = ViewCore.globalScaling;
			}

			addedToStageSignal.dispatch( this );
		}

		private function onEnterFrame( event:Event ):void {
			onUpdate();
		}

		private function onBundledAssetsReady( event:Event ):void {
			onAssetsReady();
			_bundledAssetsLoaded = true;
			_loader.removeEventListener( Event.COMPLETE, onBundledAssetsReady );
		}
	}
}
