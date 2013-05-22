package net.psykosoft.psykopaint2.base.utils
{
	import org.osflash.signals.Signal;

	public class BsSnapPositionManager
	{
		private var _snapPoints:Vector.<Number>;
		private var _position:Number;
		private var _snapMotionSpeed:Number;
		private var _direction:int;
		private var _positionChange:Number;
		private var _closestSnapPointIndex:int;
		private var _onSnapMotion:Boolean;
		private var _targetSnapPoint:Number = 0;

		public var closestSnapPointChangedSignal:Signal;
		public var motionEndedSignal:Signal;

		private var _frictionFactor:Number = 0.9;
		private var _minimumThrowingSpeed:Number = 100;
		private var _edgeContainmentFactor:Number = 0.1; // Smaller, softer containment.

		public function SnapPositionManager() {
			closestSnapPointChangedSignal = new Signal();
			motionEndedSignal = new Signal();
			reset();
		}

		public function reset():void {
			_position = 0;
			_snapPoints = new Vector.<Number>();
			_closestSnapPointIndex = -1;
			_direction = 0;
			_positionChange = 0;
		}

		public function addSnapPoint( value:Number ):void {
			_snapPoints.push( value );
		}

		public function updateSnapPointAt( index:uint, value:Number ):void {
			_snapPoints[ index ] = value;
		}

		public function getSnapPointAt( index:uint ):Number {
			return _snapPoints[ index ];
		}

		public function removeSnapPoint( value:Number ):void {
			_snapPoints.splice( _snapPoints.indexOf( value ), 1 );
		}

		public function moveFreelyByAmount( amount:Number ):void {

			_direction = amount > 0 ? 1 : -1;

			_positionChange = amount;

			// Edge containment.
			var firstSnapPoint:Number = _snapPoints[ 0 ];
			var lastSnapPoint:Number = _snapPoints[ _snapPoints.length - 1 ]; // TODO: optimize?
			var multiplier:Number = 1;
			if( _position < firstSnapPoint ) {
				multiplier = 1 / ( _edgeContainmentFactor * ( firstSnapPoint - _position ) + 1 );
			}
			if( _position > lastSnapPoint ) {
				multiplier = 1 / ( _edgeContainmentFactor * ( _position - lastSnapPoint ) + 1 );
			}

			// Apply motion.
			_position += amount * multiplier;
		}

		public function snap( speed:Number ):void {

			_snapMotionSpeed = 0;

			// Avoid wimp throws, still 0 is allowed for returns to last snap.
			if( speed != 0 ) {
				var speedAbs:Number = Math.abs( speed );
				if( speedAbs < _minimumThrowingSpeed ) {
					speed = ( speed / speedAbs ) * _minimumThrowingSpeed;
				}
			}

			// Try to guess direction of motion.
			_direction = speed > 0 ? 1 : -1;

			// Try to precalculate how far this would throw the scroller.
			var precision:Number = 512;
			var integralFriction:Number = ( Math.pow( _frictionFactor, precision ) - 1 ) / ( _frictionFactor - 1 );
			var distanceTravelled:Number = speed * integralFriction;
			var calculatedPosition:Number = _position + distanceTravelled;

			// Try to find a snapping point near the destination.
			evaluateClosestSnapPointPosition( calculatedPosition );

			// Evaluate throw speed to reach target.
			_snapMotionSpeed = ( _targetSnapPoint - _position ) / integralFriction;

			_positionChange = _snapMotionSpeed;

			_onSnapMotion = true;
		}

		public function snapAtIndex( value:uint ):void {
			_position = _snapPoints[ value ];
		}

		public function update():void {
			if( _onSnapMotion ) {

				// Update speed and position.
				_position += _snapMotionSpeed;
				_snapMotionSpeed *= _frictionFactor;

				// Evaluate if motion has stopped.
				var distanceToTarget:Number = Math.abs( _targetSnapPoint - _position );
				var absSpeed:Number = Math.abs( _snapMotionSpeed );
				if( absSpeed < 0.1 && distanceToTarget < 1 ) {
					_position = _targetSnapPoint;
					_onSnapMotion = false;
					motionEndedSignal.dispatch();
				}
			}
		}

		// ---------------------------------------------------------------------
		// Utils.
		// ---------------------------------------------------------------------

		private function evaluateClosestSnapPointPosition( position:Number ):void {
			// Find closest snap point.
			var len:uint = _snapPoints.length;
			var closestDistanceToSnapPoint:Number = Number.MAX_VALUE;
			_targetSnapPoint = _position;
			var targetSnapPointIndex:uint;
			for( var i:uint; i < len; ++i ) {
				var snapPoint:Number = _snapPoints[ i ];
				var distanceToSnapPoint:Number = Math.abs( position - snapPoint );
				if( distanceToSnapPoint < closestDistanceToSnapPoint ) {
					closestDistanceToSnapPoint = distanceToSnapPoint;
					_targetSnapPoint = snapPoint;
					targetSnapPointIndex = i;
				}
			}

			// Notify closest snap point change?
			if( targetSnapPointIndex != _closestSnapPointIndex ) {
				_closestSnapPointIndex = targetSnapPointIndex;
				closestSnapPointChangedSignal.dispatch( _closestSnapPointIndex );
			}
		}

		// ---------------------------------------------------------------------
		// Getters and setters.
		// ---------------------------------------------------------------------

		public function get numSnapPoints():uint {
			return _snapPoints.length;
		}

		public function get position():Number {
			return _position;
		}

		public function set frictionFactor( value:Number ):void {
			_frictionFactor = value;
		}

		public function set minimumThrowingSpeed( value:Number ):void {
			_minimumThrowingSpeed = value;
		}

		public function set edgeContainmentFactor( value:Number ):void {
			_edgeContainmentFactor = value;
		}
	}
}
