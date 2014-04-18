package net.psykosoft.psykopaint2.core.managers.accelerometer
{

	import flash.display.Stage;
	import flash.display.StageOrientation;
	import flash.events.MouseEvent;
	import flash.events.StageOrientationEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	import net.psykosoft.gyroscope.GyroscopeExtension;
	import net.psykosoft.gyroscope.events.GyroscopeExtensionEvent;
	import net.psykosoft.psykopaint2.core.signals.NotifyGyroscopeUpdateSignal;

	public class GyroscopeManager
	{
		private var gyroscope : GyroscopeExtension;

		[Inject]
		public var stage : Stage;

		[Inject]
		public var notifyGyroscopeUpdateSignal : NotifyGyroscopeUpdateSignal;

		[Inject]
		public var accelerometer : AccelerometerManager;

		private static var _orientation : String;
		static private var _orientationMatrix : Matrix3D = new Matrix3D();
		static private var _angleAdjustment : Number = 0;
		

		public function GyroscopeManager()
		{
			_orientationMatrix.identity();
		}

		static public function get orientationMatrix():Matrix3D
		{
			return _orientationMatrix;
		}

		public static function get orientation() : String
		{
			return _orientation;
		}
		
		static public function get angleAdjustment():Number
		{
			return _angleAdjustment;
		}
		
		public static function set angleAdjustment( value:Number ) : void
		{
			_angleAdjustment = value;
		}

		public function initialize() : void
		{
			gyroscope = new GyroscopeExtension();
			gyroscope.addEventListener(GyroscopeExtensionEvent.READING, onGyroscopeReading);
			gyroscope.initialize();
			gyroscope.startReadings();

			stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange);

			_orientation = stage.orientation;

			// TEMPORARY, FOR TESTING PURPOSES
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}

		private function onMouseMove(event : MouseEvent) : void
		{
			if (event.altKey && event.shiftKey) {
				var zAxis : Vector3D = new Vector3D(0, 0, 1);
				zAxis.x = -(1 - stage.mouseX / stage.stageWidth * 2);
				zAxis.y = (1 - stage.mouseY / stage.stageHeight * 2);
				zAxis.normalize();
				updateMatrixFromZAxis(zAxis);
			}
		}

		private function onOrientationChange(event : StageOrientationEvent) : void
		{
			_orientation = stage.orientation;
		}

		private function onGyroscopeReading(event : GyroscopeExtensionEvent) : void
		{
			var zAxis : Vector3D = new Vector3D();

			_orientationMatrix.copyFrom(event.rotationMatrix);
			_orientationMatrix.appendRotation( _angleAdjustment / Math.PI * 180,Vector3D.Z_AXIS );
			
			if (_orientation == StageOrientation.ROTATED_RIGHT) {
				_orientationMatrix.transpose();
				_orientationMatrix.appendRotation(180, Vector3D.Z_AXIS);
				_orientationMatrix.transpose();
			}
			else {
				_orientationMatrix.transpose();
				_orientationMatrix.appendRotation(-180, Vector3D.Z_AXIS);
				_orientationMatrix.transpose();
			}
			
			
			_orientationMatrix.copyRowTo(2, zAxis);

			updateMatrixFromZAxis(zAxis);
		}

		private function updateMatrixFromZAxis(zAxis : Vector3D) : void
		{
			if (zAxis.z < 0.01) {
				zAxis.z = 0.01;
				zAxis.normalize();
			}

			_orientationMatrix.identity();

			var xAxis : Vector3D = Vector3D.Y_AXIS.crossProduct(zAxis);
			xAxis.normalize();
			var yAxis : Vector3D = zAxis.crossProduct(xAxis);

			_orientationMatrix.copyRowFrom(0, xAxis);
			_orientationMatrix.copyRowFrom(1, yAxis);
			_orientationMatrix.copyRowFrom(2, zAxis);
			notifyGyroscopeUpdateSignal.dispatch(_orientationMatrix);
		}
	}
}
