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

	use namespace arcane;

	public class ScrollCameraController
	{
		// TODO: try not using tweens at all, to ensure that motion is 100% continuous

		private var _camera:Camera3D;
		private var _speed:Number;
		private var _userInteracting:Boolean;
		private var _stage:Stage;
		private var _snapPoints:Vector.<Number>;
		private var _wall:Mesh;
		private var _perspectiveFactorDirty:Boolean;
		private var _perspectiveFactor:Number;

		private var _onEdgeDeceleration:Boolean;
		private var _onTween:Boolean;
		private var _surpassedEdge:int = 0; // 0 = none, 1 = right, -1 = left
		private var _edgeSurpassDistance:Number;

		private var _mouseX:Number = 0;
		private var _lastMouseX:Number = 0;
		private var _mouseDeltaX:Number = 0;

		private var _cameraPositionStack:Vector.<Number>;

		private var _justSnapped:Boolean = true;
		private var _firstSnapPoint:Number;
		private var _lastSnapPoint:Number;

		private const FRICTION_FACTOR:Number = 0.98;
		private const AVERAGE_SPEED_SAMPLES:uint = 10;
		private const EDGE_STIFFNESS_ON_DRAG:Number = 0.01;
		private const EDGE_CONTAINMENT_FRICTION_FACTOR:Number = 0.5;
		private const SNAPPING_SPEED_LIMIT:Number = 10;
		private const TWEEN_TIME:Number = 1;

		public function ScrollCameraController( camera:Camera3D, wall:Mesh, stage:Stage ) {
			super();

			_camera = camera;

			_wall = wall;

			_lastMouseX = 0;
			_speed = 0;

			_stage = stage;
			_stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			_stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			_stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );

			_cameraPositionStack = new Vector.<Number>();

			_snapPoints = new Vector.<Number>();

			// TODO: must update on screen resize?
			_perspectiveFactorDirty = true;
		}

		/*
		* We want the user's finger to precisely snap to the wall,
		* so we need to precalculate how much a given x-motion on the screen
		* relates to x-motion on the wall.
		* */
		private function evaluatePerspectiveFactor():void {

//			Cc.log( this, "updating perspective factor." );

			var aspectRatio:Number = _camera.lens.aspectRatio;

			// Shoot a ray from the camera to the right edge of the screen.
			var rayPosition:Vector3D = _camera.unproject( aspectRatio, 0, 0 );
			var rayDirection:Vector3D = _camera.unproject( aspectRatio, 0, 1 );
			rayDirection = rayDirection.subtract( rayPosition );
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
//			Cc.log( "collisionPos: " + collisionPos );

			// Compare the right-span of the screen to the right-span on the wall.
			_perspectiveFactor = collisionPos.x / ( _stage.width / 2 );
//			Cc.log( "_perspectiveFactor: " + _perspectiveFactor );

			_perspectiveFactorDirty = false;

		}

		/*
		* Snap points must be passed from smaller to larger
		* */
		public function addSnapPoint( position:Number ):void {
			if( _snapPoints.length == 0 ) _firstSnapPoint = position;
			else _lastSnapPoint = position;
			_snapPoints.push( position );
		}

		// ---------------------------------------------------------------------
		// User interaction.
		// ---------------------------------------------------------------------

		private function onMouseDown( event:MouseEvent ):void {
			_userInteracting = true;
			_mouseX = _lastMouseX = _stage.mouseX - _stage.stageWidth / 2;
			if( _onTween ) {
				stopAllTweens();
			}
		}

		private function onMouseUp( event:MouseEvent ):void {
			_userInteracting = false;
			_cameraPositionStack = new Vector.<Number>();
		}

		private function onMouseMove( event:MouseEvent ):void {
			if( _userInteracting ) {
				_mouseX = _stage.mouseX - _stage.stageWidth / 2;
			}
		}

		// ---------------------------------------------------------------------
		// Update.
		// ---------------------------------------------------------------------

		public function update():void {

			// Check if perspective factor needs to be updated.
			if( _perspectiveFactorDirty ) {
				evaluatePerspectiveFactor();
			}

			if( _userInteracting ) {
				// Update user input.
				_mouseDeltaX = _lastMouseX - _mouseX;
				_lastMouseX = _mouseX;
				// Move the scroller perfectly under the user's finger.
				var edgeStiffnessFactor:Number = EDGE_STIFFNESS_ON_DRAG * _edgeSurpassDistance;
				edgeStiffnessFactor = edgeStiffnessFactor < 1 ? 1 : edgeStiffnessFactor;
//				Cc.log( "edgeStiffnessFactor: " + edgeStiffnessFactor );
				_camera.x += _perspectiveFactor * _mouseDeltaX / edgeStiffnessFactor;
//				Cc.log( "camera x: " + _camera.x );
				// Update speed ( used when the user is not interacting ).
				updateAverageSpeed();
				_justSnapped = false;
			}
			else {
				// Update motion.
				_camera.x += _speed;
			}
			_speed *= _onEdgeDeceleration ? EDGE_CONTAINMENT_FRICTION_FACTOR : FRICTION_FACTOR;
//			trace( "speed: " + _speed );

			// Attempt a snapping.
			if( !_justSnapped && !_onTween && !_userInteracting && Math.abs( _speed ) < SNAPPING_SPEED_LIMIT ) {
            	// Evaluate distance to closest snap point.
				var shortestDistance:Number = Number.MAX_VALUE;
				var shortestDistanceIndex:uint;
				var len:uint = _snapPoints.length;
				for( var i:uint; i < len; ++i ) {
					var distance:Number = Math.abs( _camera.x - _snapPoints[ i ] );
//					trace( "distance - " + i + ": " + distance );
					if( distance < shortestDistance ) {
						shortestDistance = distance;
						shortestDistanceIndex = i;
					}
				}
				// Snap if going slow enough.
//				trace( "shortestDistance - " + i + ": " + shortestDistance );
//				trace( "SNAPPING: " + shortestDistanceIndex );
				_speed = 0;
				tweenTo( _snapPoints[ shortestDistanceIndex ], TWEEN_TIME * shortestDistance / ( Settings.DEVICE_SCREEN_WIDTH / 4 ) );
			}

			// Contain if a range has been set.
			containEdges();
		}

		private function updateAverageSpeed():void {
			_cameraPositionStack.push( _camera.x );
			if( _cameraPositionStack.length > AVERAGE_SPEED_SAMPLES ) {
				_cameraPositionStack.splice( 0, 1 );
			}
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
		* If an edge is surpassed, a stronger friction is applied ( EDGE_CONTAINMENT_FRICTION_FACTOR ),
		* and when the speed reaches a low enough level ( EDGE_CONTAINMENT_SPEED_LIMIT )
		* ( if the user is not interacting )
		* a tween is triggered to return the scroller to the appropriate edge limit.
		* */
		private function containEdges():void {

			if( _onTween ) return;

			if( _camera.x < _firstSnapPoint ) {
//				Cc.log( this, "left edge surpassed." );
				_edgeSurpassDistance = _firstSnapPoint - _camera.x;
				_onEdgeDeceleration = true;
				_surpassedEdge = -1;
			}
			else if( _camera.x > _lastSnapPoint ) {
//				Cc.log( this, "right edge surpassed." );
				_edgeSurpassDistance = _camera.x - _lastSnapPoint;
				_onEdgeDeceleration = true;
				_surpassedEdge = 1;
			}
			else {
				_edgeSurpassDistance = 0;
				_onEdgeDeceleration = false;
				_surpassedEdge = 0;
			}

		}

		// ---------------------------------------------------------------------
		// Tweening.
		// ---------------------------------------------------------------------

		private function tweenTo( position:Number, time:Number ):void {
			Cc.log( this, "starting tween to: " + position );
			stopAllTweens();
			_onTween = true;
			TweenLite.to( _camera, time, {
				x: position,
				ease:Strong.easeOut,
				onComplete: onTweenComplete
				,onUpdate: onTweenUpdate // uncomment to make sure that tweens are properly killed
			} );
		}

		private function onTweenUpdate():void {
			Cc.log( this, "edge tween active..." );
		}

		private function onTweenComplete():void {
			Cc.log( this, "tween completed." );
			_onTween = false;
			if( _surpassedEdge != 0 ) {
				_camera.x = _surpassedEdge == -1 ? _firstSnapPoint : _lastSnapPoint;
			}
			_surpassedEdge = 0;
		}

		private function stopAllTweens():void {
			_onTween = false;
			_justSnapped = true;
			TweenLite.killTweensOf( _camera );
		}
	}
}
