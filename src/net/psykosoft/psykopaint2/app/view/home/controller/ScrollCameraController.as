package net.psykosoft.psykopaint2.app.view.home.controller
{

	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;

	import flash.display.Sprite;

	import flash.display.Stage;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.app.config.Settings;

	import net.psykosoft.psykopaint2.app.utils.ScrollInteractionManager;
	import net.psykosoft.psykopaint2.app.utils.SnapPositionManager;

	import org.osflash.signals.Signal;

	import starling.core.Starling;

	use namespace arcane;

	public class ScrollCameraController
	{
		private var _interactionManager:ScrollInteractionManager;
		private var _positionManager:SnapPositionManager;
		private var _camera:Camera3D;
		private var _cameraTarget:Mesh; // TODO: change to Object3D or even a Number
		private var _perspectiveFactorDirty:Boolean;
		private var _stageWidth:Number;
		private var _stageHeight:Number;
		private var _perspectiveFactorTracer:Mesh; // TODO: remove!
		private var _isScrollingLimited:Boolean = true;

		public var isActive:Boolean = true;

		private const EASE_FACTOR:Number = 0.75;

		public function ScrollCameraController( camera:Camera3D, target:Mesh, stage:Stage ) {

			super();

			_camera = camera;
			_cameraTarget = target;
			_stageWidth = stage.stageWidth;
			_stageHeight = stage.stageHeight;

			_positionManager = new SnapPositionManager();
			_interactionManager = new ScrollInteractionManager( stage, _positionManager );

			_perspectiveFactorTracer = new Mesh( new CubeGeometry(), new ColorMaterial( 0xFF0000 ) );
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

		public function getPositionTracer():Sprite {
			// TODO: remove
			return _positionManager.tracer;
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
			_camera.x += EASE_FACTOR * ( _cameraTarget.x - _camera.x );
			_camera.lookAt( _cameraTarget.position );
//			_camera.lookAt( new Vector3D() ); // Useful for debugging perspective.
		}

		public function startPanInteraction():void {
			if( !isActive ) return;
			if( _isScrollingLimited ) {
				var limit:Number = _stageHeight - Settings.NAVIGATION_AREA_CONTENT_HEIGHT * Starling.contentScaleFactor;
				if( _interactionManager.currentY > limit ) return;
			}
			_interactionManager.startInteraction();
		}

		public function endPanInteraction():void {
			if( !isActive ) return;
			_interactionManager.endInteraction();
		}

		private function updatePerspectiveFactor():void {

//			trace( this, "updating perspective factor --------------------" );

//			trace( this, "camera position: " + _camera.position );
//			trace( this, "target position: " + _cameraTarget.position );
//			trace( this, "stage width: " + _stageWidth );

			// Momentarily place the camera at x = 0;
			var cameraTransformCache:Matrix3D = _camera.transform.clone();
			_camera.transform = new Matrix3D();
			_camera.z = cameraTransformCache.position.z;

			// Shoot a ray from the camera to the right edge of the screen.
			var aspectRatio:Number = _camera.lens.aspectRatio;
//			trace( this, "aspect ratio: " + aspectRatio );
			var rayPosition:Vector3D = _camera.unproject( 0, 0, 0 );
			var rayDirection:Vector3D = _camera.unproject( 1, 0, 1 );
			rayDirection = rayDirection.subtract( rayPosition );
			rayDirection.normalize();
//			trace( this, "ray: " + rayPosition + ", " + rayDirection );

			// See where this ray hits the wall.
			var t:Number = -( -rayPosition.z + _cameraTarget.z ) / -rayDirection.z; // Typical ray-plane intersection calculation ( simplified because of zero's ).
			var collisionPoint:Vector3D = new Vector3D(
					rayPosition.x + t * rayDirection.x,
					rayPosition.y + t * rayDirection.y,
					rayPosition.z + t * rayDirection.z
			);
//			trace( this, "collision point: " + collisionPoint );
			_perspectiveFactorTracer.position = collisionPoint;

			// Calculate the perspective factor by comparing the half screen width with how much of the wall is visible.
			var perspectiveFactor:Number = collisionPoint.x / ( _stageWidth / 2 );
//			trace( this, "new factor: " + perspectiveFactor );
			_interactionManager.inputMultiplier = perspectiveFactor;

			// Restore camera position.
			_camera.transform = cameraTransformCache;
		}

		public function get perspectiveFactorTracer():Mesh {
			return _perspectiveFactorTracer;
		}

		public function get closestSnapPointChangedSignal():Signal {
			return _positionManager.closestSnapPointChangedSignal;
		}
	}
}
