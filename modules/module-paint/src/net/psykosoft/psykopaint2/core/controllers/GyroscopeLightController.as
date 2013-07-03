package net.psykosoft.psykopaint2.core.controllers
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.core.managers.accelerometer.GyroscopeManager;

	import net.psykosoft.psykopaint2.core.model.LightingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyGyroscopeUpdateSignal;

	public class GyroscopeLightController
	{
		private var _lightDistance : Number = 2;

		[Inject]
		public var gyroscopeManager : GyroscopeManager;

		[Inject]
		public var lightModel : LightingModel;

		[Inject]
		public var notifyGyroscopeUpdateSignal : NotifyGyroscopeUpdateSignal;

		private var _enabled : Boolean;

		private var targetPos : Vector3D = new Vector3D(0, 0, -1);
		private var _lightInterpolation : Number = .99;

		//public static var defaultPos : Vector3D = new Vector3D(0, 0, -1);
		
		public function GyroscopeLightController()
		{
		}

		[PostConstruct]
		public function postConstruct() : void
		{
			enabled = true;
		}

		public function get enabled() : Boolean
		{
			return _enabled;
		}

		public function set enabled(value : Boolean) : void
		{
			if (_enabled == value) return;
			_enabled = value;

			if (value)
				notifyGyroscopeUpdateSignal.add(onGyroscope);
			else
				notifyGyroscopeUpdateSignal.remove(onGyroscope);
		}

		private function onGyroscope(orientationMatrix : Matrix3D) : void
		{
			var pos : Vector3D = lightModel.lightPosition;
			targetPos.x = 0;
			targetPos.y = 0;
			targetPos.z = -_lightDistance;
			
			/*
			defaultPos.normalize();
			targetPos.x = defaultPos.x;
			targetPos.y = defaultPos.y;
			targetPos.z = defaultPos.z;
			*/
			targetPos = orientationMatrix.transformVector(targetPos);
			pos.x += (targetPos.x - pos.x)*_lightInterpolation;
			pos.y += (targetPos.y - pos.y)*_lightInterpolation;
			pos.z += (targetPos.z - pos.z)*_lightInterpolation;
			lightModel.lightPosition = pos;
		}
	}
}
