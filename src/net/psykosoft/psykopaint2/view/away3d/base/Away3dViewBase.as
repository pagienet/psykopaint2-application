package net.psykosoft.psykopaint2.view.away3d.base
{

	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;

	import flash.display.Sprite;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.util.DisplayContextManager;
	import net.psykosoft.psykopaint2.view.base.IView;

	public class Away3dViewBase extends Sprite implements IView
	{
		private var _view:View3D;
		private var _scene:ObjectContainer3D;
		private var _enabled:Boolean = true;

		protected var _camera:Camera3D;

		public function Away3dViewBase() {
			super();
			_view = DisplayContextManager.away3d;
			_camera = _view.camera;
			_scene = new ObjectContainer3D();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onAddedToStage( event:Event ):void {

			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

			stage.addEventListener( Event.RESIZE, onStageResize );
			stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );

			onStageAvailable();

		}

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

		protected function onLayout():void {
			// Override.
		}

		protected function onStageAvailable():void {
			// Override.
		}

		private function onStageResize( event:Event ):void {
			onLayout();
		}

		private function onEnterFrame( event:Event ):void {
			if( _enabled ) {
				onUpdate();
			}
		}

		// ---------------------------------------------------------------------
		// IView interface implementation.
		// ---------------------------------------------------------------------

		public function enable():void {
			if( _enabled ) return;
			_view.scene.addChild( _scene );
			_enabled = true;
		}

		public function disable():void {
			if( !_enabled ) return;
			if( _view.scene.contains( _scene ) ) {
				_view.scene.removeChild( _scene );
			}
			_enabled = false;
		}

		public function destroy():void {
			// TODO
		}
	}
}
