package net.psykosoft.psykopaint2.base.ui.base
{

	import com.junkbyte.console.Cc;

	import flash.display.Sprite;
	import flash.events.Event;

	public class ViewBase extends Sprite
	{
		private var _initialized:Boolean;
		private var _setupPending:Boolean;

		public var autoUpdates:Boolean = false;

		public function ViewBase() {
			super();
			Cc.log( this, "constructor" );
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			scaleX = scaleY = ViewCore.globalScaling;
			visible = false;
		}

		// ---------------------------------------------------------------------
		// Public.
		// ---------------------------------------------------------------------

		public function setup():void {
			/*if( !stage ) {
				_setupPending = true;
				return;
			}*/
			_initialized = true;
			_setupPending = false;
			onSetup();
		}

		public function enable():void {
			if( !_initialized ) setup();
			if( visible ) return;
			Cc.log( this, "enabled" );
			onEnabled();
			visible = true;
			if( autoUpdates && !hasEventListener( Event.ENTER_FRAME ) ) {
				addEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
		}

		public function disable():void {
			if( !visible ) return;
			Cc.log( this, "disabled" );
			onDisabled();
			visible = false;
			if( hasEventListener( Event.ENTER_FRAME ) ) {
				removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
		}

		public function dispose():void {
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

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
//			if( _setupPending ) setup();
			setup();
			// TODO: fix, setup needs to happen when a view is enabled, but delayed if not on stage
			// Framework currently freaks out with this because views are not ready and the app tries to start up right away
		}

		private function onEnterFrame( event:Event ):void {
			onUpdate();
		}
	}
}
