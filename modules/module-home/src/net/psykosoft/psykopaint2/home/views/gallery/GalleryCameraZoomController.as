package net.psykosoft.psykopaint2.home.views.gallery
{
	import away3d.cameras.Camera3D;

	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import org.gestouch.events.GestureEvent;

	import org.gestouch.gestures.ZoomGesture;

	public class GalleryCameraZoomController
	{
		private var _stage : Stage;
		private var _camera : Camera3D;
		private var _zoomFactor : Number = 0;
		private var _farPosition : Vector3D;
		private var _nearPosition : Vector3D;
		private var _zoomGesture : ZoomGesture;
		private var _zoomReferenceWidth : Number;
		private var _paintingWidth : Number;
		private var _paintingZ : Number;

		public function GalleryCameraZoomController(stage : Stage, camera : Camera3D, paintingWidth : Number, paintingZ : Number, farPosition : Vector3D, nearPosition : Vector3D)
		{
			_stage = stage;
			_camera = camera;
			_farPosition = farPosition;
			_nearPosition = nearPosition;
			_paintingWidth = paintingWidth;
			_paintingZ = paintingZ;
		}

		public function start() : void
		{
			if (_zoomGesture) return;
			_zoomGesture = new ZoomGesture(_stage);
			_zoomGesture.addEventListener(GestureEvent.GESTURE_BEGAN, onGestureStart);

			if (!CoreSettings.RUNNING_ON_iPAD)
				_stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}

		public function stop() : void
		{
			if (!_zoomGesture) return;
			_zoomGesture.removeEventListener(GestureEvent.GESTURE_BEGAN, onGestureStart);
			_zoomGesture.removeEventListener(GestureEvent.GESTURE_CHANGED, onGestureChanged);
			_zoomGesture.removeEventListener(GestureEvent.GESTURE_ENDED, onGestureEnd);
			_zoomGesture.dispose();
			_zoomGesture = null;
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

		private function onGestureStart(event : GestureEvent) : void
		{
			// the size of the canvas on screen when zooming starts
			var matrix : Vector.<Number> = _camera.lens.matrix.rawData;
			_zoomReferenceWidth = _paintingWidth * matrix[0] / (_camera.z - _paintingZ);

			_zoomGesture.addEventListener(GestureEvent.GESTURE_CHANGED, onGestureChanged);
			_zoomGesture.addEventListener(GestureEvent.GESTURE_ENDED, onGestureEnd);
		}

		private function onGestureChanged(event : GestureEvent) : void
		{
			var targetWidth : Number = _zoomReferenceWidth * _zoomGesture.scaleX;
			var matrix : Vector.<Number> = _camera.lens.matrix.rawData;
			var targetZ : Number = matrix[0] * _paintingWidth / targetWidth + _paintingZ;

			_zoomFactor = (targetZ - _farPosition.z)/(_nearPosition.z - _farPosition.z);
			if (_zoomFactor > 1) _zoomFactor = 1;
			else if (_zoomFactor < 0) _zoomFactor = 0;

			updateZoom();
		}

		private function onGestureEnd(event : GestureEvent) : void
		{
			_zoomGesture.removeEventListener(GestureEvent.GESTURE_CHANGED, onGestureChanged);
			_zoomGesture.removeEventListener(GestureEvent.GESTURE_ENDED, onGestureEnd);
		}
	}
}
