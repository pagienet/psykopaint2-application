package net.psykosoft.psykopaint2.app.view.base
{

	import org.osflash.signals.Signal;

	import starling.display.Sprite;
	import starling.events.Event;

	public class StarlingViewBase extends Sprite implements IView
	{
		public var addedToStageSignal:Signal;

		public function StarlingViewBase() {
			super();
			visible = false;
			addedToStageSignal = new Signal();
		}

		// -----------------------
		// Public.
		// -----------------------

		public function enable():void {

			// If stage is not yet available, enable will be called again after it is.
			if( !stage ) {
				trace( this, "trying to enable view but stage is not yet available..." );
				addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
				return;
			}

			if( _enabled ) return;

			onEnabled();

			visible = true;
			_enabled = true;

			if( !hasEventListener( Event.ENTER_FRAME ) ) {
				addEventListener( Event.ENTER_FRAME, onEnterFrame );
			}

			trace( this, "enabling 2d view." );
		}

		public function disable():void {

			if( !_enabled ) return;

			onDisabled();
			visible = false;
			_enabled = false;

			if( hasEventListener( Event.ENTER_FRAME ) ) {
				removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			}

			trace( this, "disabling 2d view." );
		}

		// -----------------------
		// Protected.
		// -----------------------

		protected function onUpdate():void {
			// Override.
		}

		protected function onEnabled():void {
			// Override.
		}

		protected function onDisabled():void {
			// Override.
		}

		// -----------------------
		// Private.
		// -----------------------

		private var _enabled:Boolean;

		private function onEnterFrame( event:Event ):void {
			onUpdate();
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			enable();
			addedToStageSignal.dispatch();
		}
	}
}

