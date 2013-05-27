package net.psykosoft.psykopaint2.home.views.home.controller
{

	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.Object3D;

	import flash.display.Stage;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.base.ui.base.ViewCore;

	import net.psykosoft.psykopaint2.base.utils.ScrollInteractionManager;
	import net.psykosoft.psykopaint2.base.utils.SnapPositionManager;

	import org.osflash.signals.Signal;

	use namespace arcane;

	public class ScrollCameraController
	{
		private var _interactionManager:ScrollInteractionManager;
		private var _positionManager:SnapPositionManager;
		private var _camera:Camera3D;
		private var _cameraTarget:Object3D;
		private var _perspectiveFactorDirty:Boolean;
		private var _stageWidth:Number;
		private var _stageHeight:Number;
		private var _isScrollingLimited:Boolean = true;

		public var isActive:Boolean = true;

		private const TARGET_EASE_FACTOR:Number = 0.5;

		public function ScrollCameraController( camera:Camera3D, target:Object3D, stage:Stage ) {

			super();

			_camera = camera;
			_cameraTarget = target;
			_stageWidth = stage.stageWidth;
			_stageHeight = stage.stageHeight;

			_positionManager = new SnapPositionManager();
			_interactionManager = new ScrollInteractionManager( stage, _positionManager );

			_interactionManager.throwInputMultiplier = 3;

			_positionManager.frictionFactor = 0.9;
			_positionManager.minimumThrowingSpeed = 175;
			_positionManager.edgeContainmentFactor = 0.01;
		}

		public function dispose():void {
			// TODO...
		}

		public function zoomIn():void {
			// TODO...
		}

		public function zoomOut():void {
			// TODO...
		}

		public function limitInteractionToUpperPartOfTheScreen( value:Boolean ):void {
//			trace( this, "interaction limited: " + value );
			_isScrollingLimited = value;
		}

		public function set cameraZ( value:Number ):void {
			_camera.z = value;
			_perspectiveFactorDirty = true;
		}

		public function set interactionSurfaceZ( value:Number ):void {
			_cameraTarget.z = value;
			_perspectiveFactorDirty = true;
		}

		public function addSnapPoint( value:Number ):void {
			_positionManager.addSnapPoint( value );
		}

		public function jumpToSnapPointIndex( value:uint ):void {
			_positionManager.snapAtIndex( value );
			_camera.x = _cameraTarget.x = _positionManager.position;
		}

		public function update():void {

			if( _perspectiveFactorDirty ) {
				updatePerspectiveFactor();
				_perspectiveFactorDirty = false;
			}

			_interactionManager.update();
			_positionManager.update();

			// Update camera and camera target positions.
			_cameraTarget.x = _positionManager.position;
			_camera.x += TARGET_EASE_FACTOR * ( _cameraTarget.x - _camera.x );
			_camera.lookAt( _cameraTarget.position );
//			_camera.lookAt( new Vector3D() ); // Useful for debugging perspective.
		}

		public function startPanInteraction():void {
			if( !isActive ) return;
			if( _isScrollingLimited ) {
				var limit:Number = _stageHeight - 200 * ViewCore.globalScaling;
				if( _interactionManager.currentY > limit ) return;
			}
			_interactionManager.startInteraction();
		}

		public function endPanInteraction():void {
			if( !isActive ) return;
			_interactionManager.endInteraction();
		}

		private function updatePerspectiveFactor():void {

			// Momentarily place the camera at x = 0;
			var cameraTransformCache:Matrix3D = _camera.transform.clone();
			_camera.transform = new Matrix3D();
			_camera.z = cameraTransformCache.position.z;

			// Shoot a ray from the camera to the right edge of the screen.
			var rayPosition:Vector3D = _camera.unproject( 0, 0, 0 );
			var rayDirection:Vector3D = _camera.unproject( 1, 0, 1 );
			rayDirection = rayDirection.subtract( rayPosition );
			rayDirection.normalize();

			// See where this ray hits the wall.
			var t:Number = -( -rayPosition.z + _cameraTarget.z ) / -rayDirection.z; // Typical ray-plane intersection calculation ( simplified because of zero's ).
			var collisionPoint:Vector3D = new Vector3D(
					rayPosition.x + t * rayDirection.x,
					rayPosition.y + t * rayDirection.y,
					rayPosition.z + t * rayDirection.z
			);

			// Calculate the perspective factor by comparing the half screen width with how much of the wall is visible.
			_interactionManager.scrollInputMultiplier = collisionPoint.x / ( _stageWidth / 2 );

			// Restore camera position.
			_camera.transform = cameraTransformCache;
		}

		public function get closestSnapPointChangedSignal():Signal {
			return _positionManager.closestSnapPointChangedSignal;
		}
	}
}
