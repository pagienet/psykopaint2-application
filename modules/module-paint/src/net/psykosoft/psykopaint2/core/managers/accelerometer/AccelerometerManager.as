package net.psykosoft.psykopaint2.core.managers.accelerometer
{

	import flash.display.Stage;
	import flash.events.AccelerometerEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.sensors.Accelerometer;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalAccelerometerSignal;

	public class AccelerometerManager
	{
		private var avgY : Vector.<Number>;
		private var sumY : Number;
		private var accelerometer : Accelerometer;
		private var bufferSize : uint = 16;
		private var bufferIndex : uint = 0;
		private var lastTrigger : uint = 0;
		private var sampleCount : uint;

		private var _gravityAccumulated : Vector3D = new Vector3D();
		private var _gravityQueue : Vector.<Vector3D> = new Vector.<Vector3D>();
		private var _numGravitySamples : int;

		private const THRESHOLD : Number = 0.25;

		private var _orientationMatrix : Matrix3D = new Matrix3D();

		[Inject]
		public var stage : Stage;

		[Inject]
		public var notifyGlobalAccelerometerSignal : NotifyGlobalAccelerometerSignal;

		private var _accelerationX : Number = 0;
		private var _accelerationY : Number = 0;
		private var _accelerationZ : Number = 0;

		static private var _gravityVector : Vector3D;

		public function AccelerometerManager()
		{
			avgY = new Vector.<Number>(bufferSize, true);

			sumY = 0;
			_accelerationY = 0;
			_gravityVector = new Vector3D();
		}

		static public function get gravityVector() : Vector3D
		{
			return _gravityVector;
		}

		[PostConstruct]
		public function init() : void
		{
			accelerometer = new Accelerometer();
			accelerometer.addEventListener(AccelerometerEvent.UPDATE, onAccelerometerUpdate);
		}

		public function get accelerationX() : Number
		{
			return _accelerationX;
		}

		public function set accelerationX(value : Number) : void
		{
			_accelerationX = value;
		}

		public function get accelerationY() : Number
		{
			return _accelerationY;
		}

		public function set accelerationY(value : Number) : void
		{
			_accelerationY = value;
		}

		public function get accelerationZ() : Number
		{
			return _accelerationZ;
		}

		public function set accelerationZ(value : Number) : void
		{
			_accelerationZ = value;
		}

		private function onAccelerometerUpdate(event : AccelerometerEvent) : void
		{
			_accelerationX = event.accelerationX;
			_accelerationY = event.accelerationY;
			_accelerationZ = event.accelerationZ;

			sumY += _accelerationY - avgY[ bufferIndex ];

			avgY[ bufferIndex ] = _accelerationY;

			bufferIndex = ( bufferIndex + 1 ) % bufferSize;

			var difY : Number = sumY / bufferSize - _accelerationY;

			sampleCount++;

			updateMatrix();
			updateGravity();

			notifyGlobalAccelerometerSignal.dispatch(AccelerationType.MATRIX_UPDATED);

			if (sampleCount < 100) {
				return;
			}

			if (getTimer() - lastTrigger > 800) {
//				trace( this, difY );
				if (difY > THRESHOLD) {
//					trace( "flip forward!" );
					notifyGlobalAccelerometerSignal.dispatch(AccelerationType.SHAKE_FORWARD);
					lastTrigger = getTimer();
				}
				if (difY < -THRESHOLD) {
//					trace( "flip backward!" );
					notifyGlobalAccelerometerSignal.dispatch(AccelerationType.SHAKE_BACKWARD);
					lastTrigger = getTimer();
				}
			}

			if (sampleCount > uint.MAX_VALUE) {
				sampleCount = 0;
			}
		}

		private function updateGravity() : void
		{
			/*var isRandomMovement : Boolean;
			var unitVector : Vector3D = new Vector3D(_accelerationX, _accelerationY, _accelerationZ);
			unitVector.normalize();

			if (_numGravitySamples == 24) {
				isRandomMovement = unitVector.dotProduct(_gravityVector) < .25;	// angle is too different to be gravity, must be some sort of jerkiness
			}

			if (!isRandomMovement) {
				_gravityAccumulated.x += unitVector.x;
				_gravityAccumulated.y += unitVector.y;
				_gravityAccumulated.z += unitVector.z;

				if (_numGravitySamples == 24) {
					var removed : Vector3D = _gravityQueue[0];
					_gravityAccumulated.x -= removed.x;
					_gravityAccumulated.y -= removed.y;
					_gravityAccumulated.z -= removed.z;
					_gravityQueue.splice(0, 1);
				}
				else
					++_numGravitySamples;

				_gravityQueue.push(unitVector);
			}


			_gravityVector.copyFrom(_gravityAccumulated);
			 _gravityVector.normalize();
			*/

			_gravityVector.setTo(_accelerationX, _accelerationY, _accelerationZ);
			_gravityVector.normalize();
		}

		private function updateMatrix() : void
		{
			// accelerometer is the vector pointing in the direction of gravity relative to the device
			// (0, 0, 1) points into the device
			// (1, 0, 0) points left (o_O)
			// (0, 1, 0) points down

			// so let's say (0, 1, 0) is the reference vector
			// when gravity vector = (0, 1, 0) matrix = I

			_orientationMatrix.identity();

			// pretty much pointing straight down, or near enough as makes no matter
			if (_gravityVector.z > .995)
				return;

			var zAxis : Vector3D = _gravityVector;
			var xAxis : Vector3D = Vector3D.Y_AXIS.crossProduct(zAxis);
			var yAxis : Vector3D = xAxis.crossProduct(zAxis);
			yAxis.negate();

			_orientationMatrix.copyColumnFrom(0, xAxis);
			_orientationMatrix.copyColumnFrom(1, yAxis);
			_orientationMatrix.copyColumnFrom(2, zAxis);
			_orientationMatrix.invert();
		}

		public function get orientationMatrix() : Matrix3D
		{
			return _orientationMatrix;
		}

		private function onMouseMove(event : MouseEvent) : void
		{
			if (event.altKey && event.shiftKey) {
				var stage : Stage = Stage(event.currentTarget);
				_accelerationX = -(1 - stage.mouseX / stage.stageWidth * 2);
				_accelerationY = (1 - stage.mouseY / stage.stageHeight * 2);
				var sqrZ : Number = 1 - _accelerationX*_accelerationX - _accelerationY*_accelerationY;
				_accelerationZ = sqrZ < 0? 0 : Math.sqrt(sqrZ);

				updateMatrix();

				notifyGlobalAccelerometerSignal.dispatch(AccelerationType.MATRIX_UPDATED);
			}
		}
	}
}
