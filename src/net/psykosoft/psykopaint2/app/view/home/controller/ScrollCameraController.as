package net.psykosoft.psykopaint2.app.view.home.controller
{

	import away3d.arcane;
	import away3d.bounds.BoundingVolumeBase;
	import away3d.cameras.Camera3D;
	import away3d.entities.Mesh;

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import flash.display.Stage;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.app.config.Settings;

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

		private var _currentCameraClosestSnapPointIndex:uint;
		private var _previousCameraClosestSnapPointIndex:uint;

		private const FRICTION_FACTOR:Number = 0.9;
		private const AVERAGE_SPEED_SAMPLES:uint = 6;
		private const MINIMUM_THROWING_SPEED:Number = 200;
		private const EDGE_STIFFNESS_ON_DRAG:Number = 0.01;
		private const FRICTION_FACTOR_ON_EDGE_CONTAINMENT:Number = FRICTION_FACTOR * 0.5;
		private const EDGE_CONTAINMENT_SPEED_LIMIT:Number = 0.5;
		private const EDGE_CONTAINMENT_RETURN_TWEEN_TIME:Number = 1;

		private const DEFAULT_CAMERA_Z:Number = -1750;

		public var motionStartedSignal:Signal;
		public var motionEndedSignal:Signal;
		public var cameraClosestSnapPointChangedSignal:Signal;

		public var scrollingLimited:Boolean = true;

		public function ScrollCameraController( camera:Camera3D, wall:Mesh, stage:Stage ) {

			super();

			cameraClosestSnapPointChangedSignal = new Signal();
			motionStartedSignal = new Signal();
			motionEndedSignal = new Signal();

			_camera = camera;
			_camera.x = 0;
			_camera.y = 0;
			_camera.z = DEFAULT_CAMERA_Z;

			_wall = wall;

			_lastMouseX = 0;
			_speed = 0;

			_snapPoints = new Vector.<Number>();

			// User input listeners.
			_stage = stage;

			// See pushPosition().
			_cameraPositionStack = new Vector.<Number>();

			// See evaluatePerspectiveFactor().
			_perspectiveFactorDirty = true;
		}

		public function dispose():void {

			stopAllTweens();

			_cameraPositionStack = null;
			_snapPoints = null;
			_camera = null;
			_stage = null;
			_wall = null;

		}

		/*
		* We want the user's finger to precisely snap to the home,
		* so we need to precalculate how much a given x-motion on the screen
		* relates to x-motion on the home.
		* */
		private function evaluatePerspectiveFactor():void {

			var cameraCacheX:Number = _camera.x;
			_camera.x = 0;

			var aspectRatio:Number = _camera.lens.aspectRatio;

			// Shoot a ray from the camera to the right edge of the screen.
			var rayPosition:Vector3D = _camera.unproject( aspectRatio, 0, 0 );
			var rayDirection:Vector3D = _camera.unproject( aspectRatio, 0, 1 );
			rayDirection = rayDirection.subtract( rayPosition );
			rayDirection.normalize();
			var invSceneTransform:Matrix3D = _wall.inverseSceneTransform;
			var localRayPosition:Vector3D = invSceneTransform.transformVector( rayPosition );
			var localRayDirection:Vector3D = invSceneTransform.deltaTransformVector( rayDirection );

			// Evaluate ray-home collision point.
			var bounds:BoundingVolumeBase = _wall.bounds;
			var t:Number = bounds.rayIntersection( localRayPosition, localRayDirection, new Vector3D() );
			var collisionPos:Vector3D = new Vector3D();
			collisionPos.x = localRayPosition.x + t * localRayDirection.x;
			collisionPos.y = localRayPosition.y + t * localRayDirection.y;
			collisionPos.z = localRayPosition.z + t * localRayDirection.z;
			collisionPos = _wall.sceneTransform.transformVector( collisionPos );
			collisionPos.x /= aspectRatio;

			// Compare the right-span of the screen to the right-span on the home.
			_perspectiveFactor = collisionPos.x / ( _stage.width / 2 );

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

		public function removeLastSnapPoint():void {
			_snapPoints.splice( _snapPoints.length - 1, 1 );
		}

		public function jumpToSnapPoint( index:uint ):void {
			_camera.x = _lastCameraX = _snapPoints[ index ];
		}

		public function jumpToSnapPointAnimated( index:uint ):void {
			tweenTo( _snapPoints[ index ], 1 );
		}

		// ---------------------------------------------------------------------
		// User interaction.
		// ---------------------------------------------------------------------

		public function startPanInteraction():void {

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

		public function endPanInteraction():void {

			_userInteracting = false;

			stopAllTweens();

			// Reject throws in the navigation area.
			if( !scrollingAllowed() ) {
				return;
			}

			throwScroller();
		}

		private function scrollingAllowed():Boolean {
			if( !scrollingLimited ) return true;
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
				_camera.x += _perspectiveFactor * mouseDeltaX / edgeStiffnessFactor;
				// Update speed ( used when the user is not interacting ).
				pushPosition();
			}
			else if( _moving ) { // User has released the scroller.
				if( Math.abs( _speed ) > 0.1 ) { // Update motion.
					_camera.x += _speed;
					_speed *= _onEdgeDeceleration ? FRICTION_FACTOR_ON_EDGE_CONTAINMENT : FRICTION_FACTOR;
				}
				else {
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

			// Calculate the average speed the throw would have.
			calculateAverageSpeed();

			// Avoid wimp throws, still 0 is allowed for returns to last snap.
			if( _speed != 0 ) {
				var speedAbs:Number = Math.abs( _speed );
				if( speedAbs < MINIMUM_THROWING_SPEED ) {
					_speed = ( _speed / speedAbs ) * MINIMUM_THROWING_SPEED;
				}
			}

			// Try to precalculate how far this would throw the scroller.
			var precision:Number = 512;
			var friction:Number = _onEdgeDeceleration ? FRICTION_FACTOR_ON_EDGE_CONTAINMENT : FRICTION_FACTOR;
			var integralFriction:Number = ( Math.pow( friction, precision ) - 1 ) / ( friction - 1 );
			var distanceTravelled:Number = _speed * integralFriction;
			var calculatedPosition:Number = _camera.x + distanceTravelled;

			// Try to find a snapping point near the destination.
			var targetSnapPoint:Number = evaluateClosestSnapPoint( calculatedPosition );

			// If a valid snap point has been found, alter the speed so that
			// the scroller reaches it just right.
			if( targetSnapPoint >= 0 ) {
				_speed = ( targetSnapPoint - _camera.x ) / integralFriction;
			}

		}

		private function evaluateClosestSnapPoint( position:Number ):Number {
			var len:uint = _snapPoints.length;
			var closestDistanceToSnapPoint:Number = Number.MAX_VALUE;
			var targetSnapPoint:Number = -1;
			for( var i:uint; i < len; ++i ) {
				var snapPoint:Number = _snapPoints[ i ];
				var distanceToSnapPoint:Number = Math.abs( position - snapPoint );
				if( distanceToSnapPoint < closestDistanceToSnapPoint ) {
					closestDistanceToSnapPoint = distanceToSnapPoint;
					targetSnapPoint = snapPoint;
				}
			}
			// Discard chosen snap points that are too far.
			var distanceThreshold:Number = _perspectiveFactor * _stage.stageWidth;
			if( closestDistanceToSnapPoint > distanceThreshold ) {
				targetSnapPoint = -1;
			}
			return targetSnapPoint;
		}

		private function evaluateClosestSnapPointIndex( position:Number ):uint {
			var len:uint = _snapPoints.length;
			var closestDistanceToSnapPoint:Number = Number.MAX_VALUE;
			var snapPointIndex:int = -1;
			for( var i:uint; i < len; ++i ) {
				var snapPoint:Number = _snapPoints[ i ];
				var distanceToSnapPoint:Number = Math.abs( position - snapPoint );
				if( distanceToSnapPoint < closestDistanceToSnapPoint ) {
					closestDistanceToSnapPoint = distanceToSnapPoint;
					snapPointIndex = i;
				}
			}
			return snapPointIndex;
		}

		public function evaluateCameraCurrentClosestSnapPointIndex():uint {
			var value:uint = evaluateClosestSnapPointIndex( _camera.x );
			if( value != _currentCameraClosestSnapPointIndex ) {
				_previousCameraClosestSnapPointIndex = _currentCameraClosestSnapPointIndex;
				_currentCameraClosestSnapPointIndex = value;
				cameraClosestSnapPointChangedSignal.dispatch( value );
			}
			return value;
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

			// Check if an edge has been surpassed.
			if( _camera.x < _firstSnapPoint ) {
				_edgeSurpassDistance = _firstSnapPoint - _camera.x;
				_onEdgeDeceleration = true;
				_edgeSurpassed = -1;
			}
			else if( _camera.x > _lastSnapPoint ) {
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
			} );
		}

		private function onTweenComplete():void {
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
			if( _onTween ) {
				_onTween = false;
				TweenLite.killTweensOf( _camera );
			}
		}

		public function zoomIn():void {
			// TODO: could calculate current painting dimensions and dynamically adjust to it
			TweenLite.to( _camera, 0.5, { z: DEFAULT_CAMERA_Z + 1000, y: 0, ease:Strong.easeOut } );
		}

		public function zoomOut():void {
			TweenLite.to( _camera, 0.5, { z: DEFAULT_CAMERA_Z, y: 0, ease:Strong.easeOut } );
		}

		// ---------------------------------------------------------------------
		// Getters.
		// ---------------------------------------------------------------------

		public function getSnapPointCount():uint {
			return _snapPoints.length;
		}

		public function get moving():Boolean {
			return _moving;
		}

		public function get currentCameraClosestSnapPointIndex():uint {
			return _currentCameraClosestSnapPointIndex;
		}

		public function get previousCameraClosestSnapPointIndex():uint {
			return _previousCameraClosestSnapPointIndex;
		}
	}
}
