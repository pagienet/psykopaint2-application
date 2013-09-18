package net.psykosoft.psykopaint2.base.ui.base
{

	import flash.display.Sprite;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import org.osflash.signals.Signal;

	public class ViewBase extends Sprite
	{
		private var _added:Boolean;

		protected var _setupHasRan:Boolean;
		protected var _viewIsReady:Boolean;
		protected var _isEnabled:Boolean;

		public var autoUpdates:Boolean = false;
		public var scalesToRetina:Boolean = true;

		public var addedToStageSignal:Signal;
		public var enabledSignal:Signal;
		public var disabledSignal:Signal;
		public var setupSignal:Signal;
		public var assetsReadySignal:Signal;

		/*
		* Triggered when the view has loaded its assets ( if any )
		* and it is added to stage.
		* */
		public var readySignal:Signal;

		public function ViewBase() {
			super();
			trace( this, "constructor" );

			addedToStageSignal = new Signal();
			enabledSignal = new Signal();
			disabledSignal = new Signal();
			setupSignal = new Signal();
			assetsReadySignal = new Signal();
			readySignal = new Signal();

			addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			visible = false;
		}

		// ---------------------------------------------------------------------
		// Public.
		// ---------------------------------------------------------------------

		public function enable():void {
			if( visible || _isEnabled ) return;
			if( !_setupHasRan ) setup();
			trace( this, "enabled" );
			onEnabled();
			_isEnabled = visible = true;
			enabledSignal.dispatch();
			if( autoUpdates && !hasEventListener( Event.ENTER_FRAME ) ) {
				addEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
		}

		public function disable():void {
			if( !visible ) return;
			trace( this, "disabled" );
			_isEnabled = visible = false;
			onDisabled();
			disabledSignal.dispatch();
			if( hasEventListener( Event.ENTER_FRAME ) ) {
				removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
		}

		public function dispose():void {
			disable();
			_isEnabled = false;
			_setupHasRan = false;
		}

		public function setup():void {
			trace( this, "setup" );
			onSetup();
			if( _added ) {
				trace( this, "-view ready with no assets-" );
				reportReady();
			}
			setupSignal.dispatch();
			_setupHasRan = true;
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		protected function reportReady():void {
			if( _viewIsReady ) return;
			_viewIsReady = true;
			onReady();
			readySignal.dispatch();
		}

		// ---------------------------------------------------------------------
		// To override...
		// ---------------------------------------------------------------------

		protected function onReady():void {
			// Override.
		}

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

		protected function onAddedToStage():void {
			// Override.
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function addedToStageHandler( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );

			onAddedToStage();

			// Retina scaling.
			if( scalesToRetina && !( parent is ViewBase ) ) {
				scaleX = scaleY = CoreSettings.GLOBAL_SCALING;
			}

			addedToStageSignal.dispatch( this );

			_added = true;

			if( !_viewIsReady ) {
				trace( this, "-view ready from added and no need to load assets-" );
				reportReady();
			}
		}

		private function onEnterFrame( event:Event ):void {
			onUpdate();
		}

		// ---------------------------------------------------------------------
		// Getters.
		// ---------------------------------------------------------------------

		public function get viewIsReady():Boolean {
			return _viewIsReady;
		}

		public function get isEnabled():Boolean {
			return _isEnabled;
		}
	}
}
