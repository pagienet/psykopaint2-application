package net.psykosoft.psykopaint2.home.views.home.camera
{

	import away3d.cameras.Camera3D;
	import away3d.core.base.Object3D;

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import org.osflash.signals.Signal;

	public class ZoomCameraController
	{
		private var _camera:Camera3D;
		private var _target:Object3D;

		public var yzChangedSignal:Signal;
		public var zoomCompleteSignal:Signal;

		public function ZoomCameraController() {
			zoomCompleteSignal = new Signal();
			yzChangedSignal = new Signal();
		}

		public function dispose():void {
			TweenLite.killTweensOf( _camera );
		}

		public function setCamera( camera:Camera3D, cameraTarget:Object3D ):void {
			_camera = camera;
			_target = cameraTarget;
		}

		public function setYZ( y:Number, z:Number ):void {
			_camera.y = _target.y = y;
			_camera.z = z;
			yzChangedSignal.dispatch();
		}

		public function animateToYZ( y:Number, z:Number, time:Number = 1, delay:Number = 0 ):void {
			TweenLite.killTweensOf( _camera );
			TweenLite.to( _camera, time, { y: y, z: z, delay: delay, ease: Strong.easeOut, onUpdate: onTweenUpdate, onComplete: onTweenComplete } );
		}

		private function onTweenComplete():void {
			yzChangedSignal.dispatch();
			zoomCompleteSignal.dispatch();
		}

		private function onTweenUpdate():void {
			_target.y = _camera.y;
		}
	}
}
