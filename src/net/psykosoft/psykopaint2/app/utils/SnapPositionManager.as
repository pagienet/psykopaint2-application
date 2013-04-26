package net.psykosoft.psykopaint2.app.utils
{

	import flash.display.Sprite;

	import org.osflash.signals.Signal;

	public class SnapPositionManager
	{
		private var _snapPoints:Vector.<Number>;
		private var _position:Number;
		private var _speed:Number;
		private var _lastSnapPoint:Number;
		private var _direction:int = 0;
		private var _motionAmount:Number = 0;
		private var _closestSnapPointIndex:int = -1;

		public var closestSnapPointChangedSignal:Signal;

		// TODO: these should be externally configurable
		private const FRICTION_FACTOR:Number = 0.8;
		private const MINIMUM_THROWING_SPEED:Number = 100;
		private const EDGE_CONTAINMENT_FACTOR:Number = 0.01; // Smaller, softer containment.

		public function SnapPositionManager() {
			_position = 0;
			_speed = 0;
			closestSnapPointChangedSignal = new Signal();
			initializeTracers();
		}

		public function addSnapPoint( value:Number ):void {
			if( !_snapPoints ) _snapPoints = new Vector.<Number>();
			_snapPoints.push( value );
			_lastSnapPoint = value;
			_snapPointTracers.push( addTracer( 0x666666, 10, _lastSnapPoint ) ); // TODO: remove
		}

		public function moveFreelyByAmount( amount:Number ):void {

//			trace( this, "moving freely by: " + amount );

			// Setting the speed to zero kills all dynamic movement.
			_speed = 0;

			_direction = amount > 0 ? 1 : -1;

			_motionAmount = amount;

			// Edge containment.
			var multiplier:Number = 1;
			if( _position < 0 ) {
				multiplier = 1 / ( -EDGE_CONTAINMENT_FACTOR * _position + 1 );
			}
			if( _position > _lastSnapPoint ) {
				multiplier = 1 / ( EDGE_CONTAINMENT_FACTOR * ( _position - _lastSnapPoint ) + 1 );
			}

			// Apply motion.
			_position += amount * multiplier*3;
		}

		public function snap( speed:Number ):void {

			// Avoid wimp throws, still 0 is allowed for returns to last snap.
			if( speed != 0 ) {
				var speedAbs:Number = Math.abs( speed );
				if( speedAbs < MINIMUM_THROWING_SPEED ) {
					speed = ( speed / speedAbs ) * MINIMUM_THROWING_SPEED;
				}
			}

			_direction = speed > 0 ? 1 : -1;

//			trace( this, "snapping at speed: " + speed );

			// Try to precalculate how far this would throw the scroller.
			var precision:Number = 512;
			var integralFriction:Number = ( Math.pow( FRICTION_FACTOR, precision ) - 1 ) / ( FRICTION_FACTOR - 1 );
			var distanceTravelled:Number = speed * integralFriction;
			var calculatedPosition:Number = _position + distanceTravelled;

			// Try to find a snapping point near the destination.
			var targetSnapPoint:Number = evaluateClosestSnapPointPosition( calculatedPosition );

			// If a valid snap point has been found, alter the speed so that
			// the scroller reaches it just right.
			if( targetSnapPoint >= 0 ) {
				_speed = ( targetSnapPoint - _position ) / integralFriction;
			}

			_motionAmount = _speed;
		}

		private function evaluateClosestSnapPointPosition( position:Number ):Number {
			var len:uint = _snapPoints.length;
			var closestDistanceToSnapPoint:Number = Number.MAX_VALUE;
			var targetSnapPoint:Number = -1;
			var targetSnapPointIndex:uint;
			for( var i:uint; i < len; ++i ) {
				var snapPoint:Number = _snapPoints[ i ];
				var distanceToSnapPoint:Number = Math.abs( position - snapPoint );
				if( distanceToSnapPoint < closestDistanceToSnapPoint ) {
					closestDistanceToSnapPoint = distanceToSnapPoint;
					targetSnapPoint = snapPoint;
					targetSnapPointIndex = i;
				}
			}
			// Avoid targeting past the last snap point ( the code above automatically avoids targeting below the first snap point ).
			if( closestDistanceToSnapPoint > _lastSnapPoint ) {
				targetSnapPoint = -1;
			}
			// Notify closest snap point change?
			if( targetSnapPointIndex != _closestSnapPointIndex ) {
				_closestSnapPointIndex = targetSnapPointIndex;
				closestSnapPointChangedSignal.dispatch( _closestSnapPointIndex );
			}
			return targetSnapPoint;
		}

		public function update():void {
			if( _speed != 0 ) {
			 	_position += _speed;
				_speed *= FRICTION_FACTOR;
			}
			_positionTracer.x = _position * TRACER_SCALING;
		}

		public function get position():Number {
			return _position;
		}

		public function snapAtIndex( value:uint ):void {
			_speed = 0;
			_position = _snapPoints[ value ];
			_positionTracer.x = _position * TRACER_SCALING;
		}

		// ---------------------------------------------------------------------
		// TRACE CODE - TODO: remove
		// ---------------------------------------------------------------------

		private var _tracer:Sprite;
		private var _positionTracer:Sprite;
		private var _snapPointTracers:Vector.<Sprite>;

		private const TRACER_SCALING:Number = 0.1;

		private function initializeTracers():void {
			_tracer = new Sprite();
			_positionTracer = addTracer( 0xFF4444, 25 );
			_snapPointTracers = new Vector.<Sprite>();
		}

		private function addTracer( color:uint, size:Number = 15, position:Number = 0 ):Sprite {
			var pTracer:Sprite = new Sprite();
			pTracer.graphics.beginFill( color );
			pTracer.graphics.drawCircle( 0, 0, size );
			pTracer.graphics.endFill();
			pTracer.x = position * TRACER_SCALING;
			_tracer.addChild( pTracer );
			return pTracer;
		}

		public function get tracer():Sprite {
			return _tracer;
		}

		public function get direction():int {
			return _direction;
		}

		public function get motionAmount():Number {
			return _motionAmount;
		}
	}
}
