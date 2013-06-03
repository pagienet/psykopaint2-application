package net.psykosoft.psykopaint2.base.ui.base
{

	import flash.display.Sprite;
	import flash.events.Event;

	import org.osflash.signals.Signal;

	public class ViewBase extends Sprite
	{
		protected var _initialized:Boolean;

		public var autoUpdates:Boolean = false;
		public var scalesToRetina:Boolean = true;

		public var addedToStageSignal:Signal;
		public var enabledSignal:Signal;

		public function ViewBase() {
			super();
			trace( this, "constructor" );
			addedToStageSignal = new Signal();
			enabledSignal = new Signal();
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
			onDisposed();
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

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function setup():void {
			trace( this, "setup" );
			onSetup();
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
	}
}
