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
		private var _postMatrix : Matrix3D = new Matrix3D();
		private var _targetPosition : Vector3D = new Vector3D();
		private var _interpolation : Number = .99;

		public function OrientationBasedController(target : ObjectContainer3D)
		{
			_target = target;
			_orientationMatrix.identity();
		}

		public function get neutralOffset() : Vector3D
		{
			return _neutralOffset;
		}

		public function set neutralOffset(value : Vector3D) : void
		{
			_neutralOffset = value;
		}

		public function get postMatrix() : Matrix3D
		{
			return _postMatrix;
		}

		public function set postMatrix(value : Matrix3D) : void
		{
			_postMatrix = value;
		}

		public function get orientationMatrix() : Matrix3D
		{
			return _orientationMatrix;
		}

		public function set orientationMatrix(value : Matrix3D) : void
		{
			_orientationMatrix = value;
			_targetPosition = _orientationMatrix.transformVector(_neutralOffset);
			if (_postMatrix)
				_targetPosition = _postMatrix.transformVector(_targetPosition);
		}

		public function update() : void
		{
			var pos : Vector3D = _target.position;
			pos.x += (_targetPosition.x - pos.x) * _interpolation;
			pos.y += (_targetPosition.y - pos.y) * _interpolation;
			pos.z += (_targetPosition.z - pos.z) * _interpolation;
			_target.position = pos;
		}
	}
}
