package net.psykosoft.psykopaint2.app.view.base
{

	import org.osflash.signals.Signal;

	import starling.display.Sprite;
	import starling.events.Event;

	public class StarlingViewBase extends Sprite implements IApplicationView
	{
		private var _enabled:Boolean;
		private var _created:Boolean;

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

			if( !_created ) create();

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

		public function get enabled():Boolean {
			return _enabled;
		}

		public function create():void {
			if( _created ) return;
			onCreate();
			_created = true;
			trace( this, "creating 2d view." );
		}

		override public function dispose():void {
			if( !_created ) return;
			onDispose();
			_created = false;
			trace( this, "disposing 2d view." );
			super.dispose();
		}

		// -----------------------
		// Protected.
		// -----------------------

		protected function onCreate():void {
			// Override.
		}

		protected function onDispose():void {
			throw new Error( this + "All views must implement the onDispose method. Come on don't be lazy!" );
		}

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

