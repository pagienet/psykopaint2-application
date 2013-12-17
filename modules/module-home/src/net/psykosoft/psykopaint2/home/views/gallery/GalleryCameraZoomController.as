package net.psykosoft.psykopaint2.home.views.gallery
{
	import away3d.cameras.Camera3D;

	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	public class GalleryCameraZoomController
	{
		private var _stage : Stage;
		private var _camera : Camera3D;
		private var _zoomFactor : Number = 0;
		private var _farPosition : Vector3D;
		private var _nearPosition : Vector3D;

		public function GalleryCameraZoomController(stage : Stage, camera : Camera3D, farPosition : Vector3D, nearPosition : Vector3D)
		{
			_stage = stage;
			_camera = camera;
			_farPosition = farPosition;
			_nearPosition = nearPosition;
		}

		public function start() : void
		{
			if (!CoreSettings.RUNNING_ON_iPAD)
				_stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}

		public function stop() : void
		{
			if (!CoreSettings.RUNNING_ON_iPAD)
				_stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}

		private function onMouseWheel(event : MouseEvent) : void
		{
			_zoomFactor += event.delta / 20;
			if (_zoomFactor > 1) _zoomFactor = 1;
			else if (_zoomFactor < 0) _zoomFactor = 0;

			updateZoom();
		}

		private function updateZoom() : void
		{
			var pos : Vector3D = new Vector3D(
					_farPosition.x + (_nearPosition.x - _farPosition.x) * _zoomFactor,
					_farPosition.y + (_nearPosition.y - _farPosition.y) * _zoomFactor,
					_farPosition.z + (_nearPosition.z - _farPosition.z) * _zoomFactor
			);
			_camera.position = pos;
		}

	}
}
