package net.psykosoft.psykopaint2.view.away3d.wall.controller
{

	import away3d.arcane;
	import away3d.bounds.BoundingVolumeBase;
	import away3d.cameras.Camera3D;
	import away3d.entities.Mesh;

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	import com.junkbyte.console.Cc;

	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.config.Settings;

	import org.osflash.signals.Signal;

	import starling.core.Starling;

	use namespace arcane;

	public class ScrollCameraController
	{
		private var _camera:Camera3D;
		private var _speed:Number;
		private var _stage:Stage;
		private var _wall:Mesh;

		private var _perspectiveFactorDirty:Boolean;
		private var _perspectiveFactor:Number;

		private var _onEdgeDeceleration:Boolean;
		private var _onTween:Boolean;
		private var _edgeSurpassed:int = 0; // 0 = none, 1 = right, -1 = left
		private var _edgeSurpassDistance:Number = 0;

		private var _userInteracting:Boolean;
		private var _mouseX:Number = 0;
		private var _lastMouseX:Number = 0;

		private var _cameraPositionStack:Vector.<Number>;

		private var _snapPoints:Vector.<Number>;
		private var _firstSnapPoint:Number;
		private var _lastSnapPoint:Number;
		private var _moving:Boolean;
		private var _closestItemIndex:uint;

		private const FRICTION_FACTOR:Number = 0.9;
		private const AVERAGE_SPEED_SAMPLES:uint = 6;
		private const MINIMUM_THROWING_SPEED:Number = 200;
		private const EDGE_STIFFNESS_ON_DRAG:Number = 0.01;
		private const FRICTION_FACTOR_ON_EDGE_CONTAINMENT:Number = FRICTION_FACTOR * 0.5;
		private const EDGE_CONTAINMENT_SPEED_LIMIT:Number = 0.5;
		private const EDGE_CONTAINMENT_RETURN_TWEEN_TIME:Number = 1;

		public var motionStartedSignal:Signal;
		public var motionEndedSignal:Signal;

		// TODO: delete countless traces

		public function ScrollCameraController( camera:Camera3D, wall:Mesh, stage:Stage ) {

			super();

			motionStartedSignal = new Signal();
			motionEndedSignal = new Signal();

			_camera = camera;

			_wall = wall;

			_lastMouseX = 0;
			_speed = 0;

			_snapPoints = new Vector.<Number>();

			// User input listeners.
			_stage = stage;
			_stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			_stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );

			// See pushPosition().
			_cameraPositionStack = new Vector.<Number>();

			// See evaluatePerspectiveFactor().
			_perspectiveFactorDirty = true;
		}

		/*
		* We want the user's finger to precisely snap to the wall,
		* so we need to precalculate how much a given x-motion on the screen
		* relates to x-motion on the wall.
		* */
		private function evaluatePerspectiveFactor():void {

//			trace( this, "updating perspective factor." );

			var cameraCacheX:Number = _camera.x;
			_camera.x = 0;

			var aspectRatio:Number = _camera.lens.aspectRatio;
//			trace( this, "aspectRatio: " + aspectRatio );

			// Shoot a ray from the camera to the right edge of the screen.
			var rayPosition:Vector3D = _camera.unproject( aspectRatio, 0, 0 );
			var rayDirection:Vector3D = _camera.unproject( aspectRatio, 0, 1 );
			rayDirection = rayDirection.subtract( rayPosition );
			rayDirection.normalize();
//			trace( this, "ray origin: " + rayPosition + ", ray direction: " + rayDirection );
			var invSceneTransform:Matrix3D = _wall.inverseSceneTransform;
			var localRayPosition:Vector3D = invSceneTransform.transformVector( rayPosition );
			var localRayDirection:Vector3D = invSceneTransform.deltaTransformVector( rayDirection );

			// Evaluate ray-wall collision point.
			var bounds:BoundingVolumeBase = _wall.bounds;
			var t:Number = bounds.rayIntersection( localRayPosition, localRayDirection, new Vector3D() );
			var collisionPos:Vector3D = new Vector3D();
			collisionPos.x = localRayPosition.x + t * localRayDirection.x;
			collisionPos.y = localRayPosition.y + t * localRayDirection.y;
			collisionPos.z = localRayPosition.z + t * localRayDirection.z;
			collisionPos = _wall.sceneTransform.transformVector( collisionPos );
			collisionPos.x /= aspectRatio;
//			trace( this, "collisionPos: " + collisionPos );

			// Compare the right-span of the screen to the right-span on the wall.
			_perspectiveFactor = collisionPos.x / ( _stage.width / 2 );
//			trace( this, "_perspectiveFactor: " + _perspectiveFactor );

			_perspectiveFactorDirty = false;

			_camera.x = cameraCacheX;

		}

		/*
		* Snap points must be passed from smaller to larger
		* */
		public function addSnapPoint( position:Number ):void {
			if( _snapPoints.length == 0 ) _firstSnapPoint = position;
			else _lastSnapPoint = position;
			_snapPoints.push( position );
		}

		public function jumpToSnapPoint( index:uint ):void {
			_camera.x = _lastCameraX = _snapPoints[ index ];
		}

		public function jumpToSnapPointAnimated( index:uint ):void {
//			trace( this, "jumping (animated) to snap point: " + index );
			tweenTo( _snapPoints[ index ], 1 );
		}

		public function reset():void {
			_firstSnapPoint = null;
			_lastSnapPoint = null;
			_snapPoints = new Vector.<Number>();
			stopAllTweens();
		}

		// ---------------------------------------------------------------------
		// User interaction.
		// ---------------------------------------------------------------------

		private function onMouseDown( event:MouseEvent ):void {

			// Reject scrolls in the navigation area.
			if( !scrollingAllowed() ) {
				return;
			}

			_userInteracting = true;

			// Refresh average speed calculation stack whenever the user starts
			// interacting with the scroller.
			_cameraPositionStack = new Vector.<Number>();

			// Snapshot initial mouse position.
			_mouseX = _lastMouseX = _stage.mouseX - _stage.stageWidth / 2;

			_lastCameraX = _camera.x;

			stopAllTweens();

			if( !_moving ) {
				_moving = true;
				motionStartedSignal.dispatch();
			}
		}

		private function onMouseUp( event:MouseEvent ):void {

//			trace( "mouse up" );

			_userInteracting = false;

			stopAllTweens();

			// Reject throws in the navigation area.
			if( !scrollingAllowed() ) {
				return;
			}

			throwScroller();
		}

		private function scrollingAllowed():Boolean {
			var limit:Number = _stage.stageHeight - Settings.NAVIGATION_AREA_CONTENT_HEIGHT * Starling.contentScaleFactor;
			return _stage.mouseY < limit;
		}

		// ---------------------------------------------------------------------
		// Update.
		// ---------------------------------------------------------------------

		private var _lastCameraX:Number = 0;

		public function update():void {

			if( _onTween ) {
				return;
			}

			// Check if perspective factor needs to be updated.
			if( _perspectiveFactorDirty ) {
				evaluatePerspectiveFactor();
			}

			// Update motion, either glued or free.
			if( _userInteracting ) { // User's finger is on the screen, scroller snaps to finger.
				// Update user input.
				_mouseX = _stage.mouseX - _stage.stageWidth / 2;
				var mouseDeltaX:Number = _lastMouseX - _mouseX;
				_lastMouseX = _mouseX;
				// Move the scroller perfectly under the user's finger.
				var edgeStiffnessFactor:Number = EDGE_STIFFNESS_ON_DRAG * _edgeSurpassDistance;
				edgeStiffnessFactor = edgeStiffnessFactor < 1 ? 1 : edgeStiffnessFactor;
//				trace( "edgeStiffnessFactor: " + edgeStiffnessFactor );
				_camera.x += _perspectiveFactor * mouseDeltaX / edgeStiffnessFactor;
//				trace( "glued motion - pos: " + _camera.x );
				// Update speed ( used when the user is not interacting ).
				pushPosition();
			}
			else if( _moving ) { // User has released the scroller.
				if( Math.abs( _speed ) > 0.1 ) { // Update motion.
					_camera.x += _speed;
					_speed *= _onEdgeDeceleration ? FRICTION_FACTOR_ON_EDGE_CONTAINMENT : FRICTION_FACTOR;
//					trace( "free motion - pos: " + _camera.x + ", speed: " + _speed );
				}
				else {
//					trace( "stopped free motion - pos: " + _camera.x );
					_moving = false;
					var dx:Number = Math.abs( _camera.x - _lastCameraX );
					if( dx > 0 ) {
						motionEndedSignal.dispatch( evaluateClosestSnapPointIndex( _camera.x ) );
					}
				}
			}

			// Contain.
			if( _userInteracting || _moving ) {
				containEdges();
			}
		}

		// ---------------------------------------------------------------------
		// Throwing.
		// ---------------------------------------------------------------------

		private function throwScroller():void {

//			trace( "throwing scroller --------------------------------" );

			// Calculate the average speed the throw would have.
			calculateAverageSpeed();
//			trace( "average speed: " + _speed );

			// Avoid wimp throws, still 0 is allowed for returns to last snap.
			if( _speed != 0 ) {
				var speedAbs:Number = Math.abs( _speed );
				if( speedAbs < MINIMUM_THROWING_SPEED ) {
					_speed = ( _speed / speedAbs ) * MINIMUM_THROWING_SPEED;
//					trace( "applying minimum speed: " + _speed );
				}
			}

			// Try to precalculate how far this would throw the scroller.
			var precision:Number = 512;
			var friction:Number = _onEdgeDeceleration ? FRICTION_FACTOR_ON_EDGE_CONTAINMENT : FRICTION_FACTOR;
			var integralFriction:Number = ( Math.pow( friction, precision ) - 1 ) / ( friction - 1 );
			var distanceTravelled:Number = _speed * integralFriction;
			var calculatedPosition:Number = _camera.x + distanceTravelled;
//			trace( "calculated position with " + precision + " precision: " + calculatedPosition );

			// Try to find a snapping point near the destination.
			var targetSnapPoint:Number = evaluateClosestSnapPoint( calculatedPosition );

			// If a valid snap point has been found, alter the speed so that
			// the scroller reaches it just right.
			if( targetSnapPoint >= 0 ) {
				_speed = ( targetSnapPoint - _camera.x ) / integralFriction;
			}
//			trace( "altered speed: " + _speed );

		}

		private function evaluateClosestSnapPoint( position:Number ):Number {
			var len:uint = _snapPoints.length;
			var closestDistanceToSnapPoint:Number = Number.MAX_VALUE;
			var targetSnapPoint:Number = -1;
//			trace( "snap points: " + _snapPoints );
			for( var i:uint; i < len; ++i ) {
				var snapPoint:Number = _snapPoints[ i ];
				var distanceToSnapPoint:Number = Math.abs( position - snapPoint );
//				trace( "evaluating snap point at distance: " + distanceToSnapPoint );
				if( distanceToSnapPoint < closestDistanceToSnapPoint ) {
					closestDistanceToSnapPoint = distanceToSnapPoint;
					targetSnapPoint = snapPoint;
				}
			}
			// Discard chosen snap points that are too far.
			var distanceThreshold:Number = _perspectiveFactor * _stage.stageWidth;
//			trace( "discard threshold: " + distanceThreshold );
			if( closestDistanceToSnapPoint > distanceThreshold ) {
				targetSnapPoint = -1;
//				trace( "snap point discarded" );
			}
			return targetSnapPoint;
		}

		private function evaluateClosestSnapPointIndex( position:Number ):uint {
//			trace( "evaluating closest snap point index at position: " + position );
			var len:uint = _snapPoints.length;
			var closestDistanceToSnapPoint:Number = Number.MAX_VALUE;
			var snapPointIndex:int = -1;
//			trace( "snap points: " + _snapPoints );
			for( var i:uint; i < len; ++i ) {
				var snapPoint:Number = _snapPoints[ i ];
				var distanceToSnapPoint:Number = Math.abs( position - snapPoint );
//				trace( "evaluating snap point at distance: " + distanceToSnapPoint );
				if( distanceToSnapPoint < closestDistanceToSnapPoint ) {
					closestDistanceToSnapPoint = distanceToSnapPoint;
					snapPointIndex = i;
				}
			}
//			trace( "found snap point index: " + snapPointIndex );
			return snapPointIndex;
		}

		public function evaluateCurrentClosestSnapPoint():uint {
			return evaluateClosestSnapPoint( _camera.x );
		}

		public function evaluateCurrentClosestSnapPointIndex():uint {
			return evaluateClosestSnapPointIndex( _camera.x );
		}

		/*
		* Registers the camera position in a stack, to be used
		* when an average speed needs to be calculated.
		* See calculateAverageSpeed().
		* */
		private function pushPosition():void {
			_cameraPositionStack.push( _camera.x );
			if( _cameraPositionStack.length > AVERAGE_SPEED_SAMPLES ) {
				_cameraPositionStack.splice( 0, 1 );
			}
//			trace( "position pushed to stack: " + _cameraPositionStack );
		}

		/*
		* Calculates the average speed of the camera based on a set of previous position samples.
		* A stack is needed because a single sample produces poor speed calculations.
		* This calculation is done whenever the uses releases a scrolling and the camera is thrown.
		* */
		private function calculateAverageSpeed():void {
			_speed = 0;
			var len:uint = _cameraPositionStack.length;
			for( var i:uint = 0; i < len; ++i ) {
				if( i > 0 ) {
					_speed += _cameraPositionStack[ i ] - _cameraPositionStack[ i - 1 ];
				}
			}
			_speed /= len;
//			Cc.log( "speed updated: " + _speed );
		}

		// ---------------------------------------------------------------------
		// Edge containment.
		// ---------------------------------------------------------------------

		/*
		* If an edge is surpassed, a stronger friction is applied ( FRICTION_FACTOR_ON_EDGE_CONTAINMENT ),
		* and when the speed reaches a low enough level ( EDGE_CONTAINMENT_SPEED_LIMIT )
		* ( if the user is not interacting )
		* a tween is triggered to return the scroller to the appropriate edge limit.
		* */
		private function containEdges():void {

//			trace( "containing - pos: " + _camera.x + ", speed: " + _speed );

			// Check if an edge has been surpassed.
			if( _camera.x < _firstSnapPoint ) {
//				trace( this, "left edge surpassed." );
				_edgeSurpassDistance = _firstSnapPoint - _camera.x;
				_onEdgeDeceleration = true;
				_edgeSurpassed = -1;
			}
			else if( _camera.x > _lastSnapPoint ) {
//				trace( this, "right edge surpassed." );
				_edgeSurpassDistance = _camera.x - _lastSnapPoint;
				_onEdgeDeceleration = true;
				_edgeSurpassed = 1;
			}
			else {
				_onEdgeDeceleration = false;
				_edgeSurpassed = 0;
			}

			// If previously surpassed and edge and speed is low enough, tween back to edge.
			if( _onEdgeDeceleration && !_userInteracting && Math.abs( _speed ) < EDGE_CONTAINMENT_SPEED_LIMIT ) {
//				trace( "edge motion halted" );
				_onEdgeDeceleration = false;
				triggerEdgeTween();
			}
		}

		// ---------------------------------------------------------------------
		// Tweening.
		// ---------------------------------------------------------------------

		private function triggerEdgeTween():void {
			_speed = 0;
			tweenTo(
				_edgeSurpassed == -1 ? _firstSnapPoint : _lastSnapPoint,
				EDGE_CONTAINMENT_RETURN_TWEEN_TIME
			);
			_edgeSurpassDistance = 0;
		}

		private function tweenTo( position:Number, time:Number ):void {
//			trace( this, "starting tween to: " + position );
			stopAllTweens();
			_onTween = true;
			if( !_moving ) {
				_moving = true;
				motionStartedSignal.dispatch();
			}
			TweenLite.to( _camera, time, {
				x: position,
				ease:Strong.easeOut,
				onComplete: onTweenComplete
				,onUpdate: onTweenUpdate // uncomment to make sure that tweens are properly killed
			} );
		}

		private function onTweenUpdate():void { // TODO: remove if not used
//			trace( this, "edge tween active - pos: " + _camera.x );
		}

		private function onTweenComplete():void {
//			trace( this, "tween completed." );
			// Lock on.
			if( _edgeSurpassed != 0 ) {
				_camera.x = _edgeSurpassed == -1 ? _firstSnapPoint : _lastSnapPoint;
			}
			_edgeSurpassed = 0;
			_speed = 0;
			_onTween = false;
			if( _moving ) {
				_moving = false;
				motionEndedSignal.dispatch( evaluateClosestSnapPointIndex( _camera.x ) );
			}
		}

		private function stopAllTweens():void {
//			trace( "tweens killed" );
			if( _onTween ) {
				_onTween = false;
				TweenLite.killTweensOf( _camera );
			}
		}
	}
}
