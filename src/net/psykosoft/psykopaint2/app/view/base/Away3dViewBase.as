package net.psykosoft.psykopaint2.app.view.base
{

	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;

	import flash.display.Sprite;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.app.utils.DisplayContextManager;

	import org.osflash.signals.Signal;

	public class Away3dViewBase extends Sprite
	{
		private var _view:View3D;
		private var _scene:ObjectContainer3D;
		private var _enabled:Boolean;

		protected var _camera:Camera3D;

		public var onEnabledSignal:Signal;
		public var onDisabledSignal:Signal;

		public function Away3dViewBase() {
			super();
			_view = DisplayContextManager.away3d;
			_camera = _view.camera;
			_scene = new ObjectContainer3D();
			onEnabledSignal = new Signal();
			onDisabledSignal = new Signal();
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

			_view.scene.addChild( _scene );
			_enabled = true;

			if( !hasEventListener( Event.ENTER_FRAME ) ) {
				addEventListener( Event.ENTER_FRAME, onEnterFrame );
			}

			trace( this, "enabling 3d view." );

			onEnabledSignal.dispatch();
		}

		public function disable():void {

			if( !_enabled ) return;

			onDisabled();

			if( _view.scene.contains( _scene ) ) {
				_view.scene.removeChild( _scene );
			}
			_enabled = false;

			if( hasEventListener( Event.ENTER_FRAME ) ) {
				removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			}

			trace( this, "disabling 3d view." );

			onDisabledSignal.dispatch();
		}

		// -----------------------
		// Protected.
		// -----------------------

		protected function addChild3d( object:ObjectContainer3D ):void {
			_scene.addChild( object );
		}

		protected function removeChild3d( object:ObjectContainer3D ):void {
			if( _scene.contains( object ) ) {
				_scene.removeChild( object );
			}
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

		private function onEnterFrame( event:Event ):void {
			onUpdate();
		}

		// -----------------------
		// Private.
		// -----------------------

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			enable();
		}
	}
}
