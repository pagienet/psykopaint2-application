package net.psykosoft.psykopaint2.home.views.home.controllers
{
	import away3d.containers.ObjectContainer3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class OrientationBasedController
	{
		private var _neutralOffset : Vector3D = new Vector3D();
		private var _orientationMatrix : Matrix3D = new Matrix3D();
		private var _target : ObjectContainer3D;
		private var _centerPosition : Vector3D = new Vector3D();
		private var _targetPosition : Vector3D = new Vector3D();
		private var _interpolation : Number = .99;

		public function OrientationBasedController(target : ObjectContainer3D)
		{
			_target = target;
		}

		public function get neutralOffset() : Vector3D
		{
			return _neutralOffset;
		}

		public function set neutralOffset(value : Vector3D) : void
		{
			_neutralOffset = value;
		}

		public function get centerPosition() : Vector3D
		{
			return _centerPosition;
		}

		public function set centerPosition(value : Vector3D) : void
		{
			_centerPosition = value;
		}

		public function get orientationMatrix() : Matrix3D
		{
			return _orientationMatrix;
		}

		public function set orientationMatrix(value : Matrix3D) : void
		{
			_orientationMatrix = value;
			_targetPosition = _orientationMatrix.transformVector(_neutralOffset);
		}

		public function update() : void
		{
			var pos : Vector3D = _target.position;
			var targetX : Number = _targetPosition.x + _centerPosition.x;
			var targetY : Number = _targetPosition.y + _centerPosition.y;
			var targetZ : Number = _targetPosition.z + _centerPosition.z;
			pos.x += (targetX - pos.x) * _interpolation;
			pos.y += (targetY - pos.y) * _interpolation;
			pos.z += (targetZ - pos.z) * _interpolation;
			_target.position = pos;
		}
	}
}
