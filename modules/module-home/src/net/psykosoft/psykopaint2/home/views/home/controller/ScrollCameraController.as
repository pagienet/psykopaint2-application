package net.psykosoft.psykopaint2.home.views.home.controller
{

	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;

	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Strong;

	import flash.display.Stage;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.base.utils.ScrollInteractionManager;
	import net.psykosoft.psykopaint2.base.utils.SnapPositionManager;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.home.config.HomeSettings;

	import org.osflash.signals.Signal;

	use namespace arcane;

	public class ScrollCameraController extends ObjectContainer3D
	{
		private var _interactionManager:ScrollInteractionManager;
		private var _positionManager:SnapPositionManager;
		private var _camera:Camera3D;
		private var _cameraTarget:Object3D;
		private var _perspectiveFactorDirty:Boolean;
		private var _stageWidth:Number;
		private var _stageHeight:Number;
		private var _isScrollingLimited:Boolean = true;
		private var _zoomedIn:Boolean;
		private var _perspectiveTracer:Mesh;

		public var isActive:Boolean = true;

		private const TARGET_EASE_FACTOR:Number = 0.5;

		public var zoomCompleteSignal:Signal;

		public function ScrollCameraController( camera:Camera3D, target:Object3D, stage:Stage ) {

			super();

			zoomCompleteSignal = new Signal();

			_camera = camera;
			_cameraTarget = target;
			_stageWidth = stage.stageWidth;
			_stageHeight = stage.stageHeight;

			_positionManager = new SnapPositionManager();
			_interactionManager = new ScrollInteractionManager( _positionManager );
			_interactionManager.stage = stage;

			_interactionManager.throwInputMultiplier = 2;
			_interactionManager.useDetailedDelta = false;
			_positionManager.frictionFactor = 0.9;
			_positionManager.minimumThrowingSpeed = 125;
			_positionManager.edgeContainmentFactor = 0.01;

			// Uncomment to visually debug perspective factor.
			// Ensures that the scrolling snaps to finger 100%, if right, the tracer should be placed just at the edge of the screen -
//			_perspectiveTracer = new Mesh( new CubeGeometry(), new ColorMaterial( 0xFF0000 ) );
//			addChild( _perspectiveTracer );
		}

		override public function dispose():void {
			// TODO...
			super.dispose();
		}

		public function offsetY( offY:Number ):void {
			_camera.y += offY;
			_cameraTarget.y = _camera.y;
		}

		public function offsetZ( offZ:Number ):void {
			_camera.z += offZ;
		}

		public function zoomIn( targetY:Number, targetZ:Number ):void {
			_zoomedIn = true;
			TweenLite.killTweensOf( _cameraTarget );
			TweenLite.killTweensOf( _camera );
			TweenLite.to( _cameraTarget, 1, { y: targetY, ease:Strong.easeInOut } );
			TweenLite.to( _camera, 1, { y: targetY, z: targetZ, ease:Strong.easeInOut, onComplete:onZoomComplete } );
		}

		public function zoomOut():void {
			_zoomedIn = false;
			TweenLite.killTweensOf( _cameraTarget );
			TweenLite.killTweensOf( _camera );
			TweenLite.to( _cameraTarget, 1, { y: HomeSettings.CAMERA_ZOOM_OUT_Y, ease:Strong.easeInOut } );
			TweenLite.to( _camera, 1, { y: HomeSettings.CAMERA_ZOOM_OUT_Y, z: HomeSettings.CAMERA_ZOOM_OUT_Z, ease:Strong.easeInOut, onComplete:onZoomComplete } );
		}

		private function onZoomComplete():void {
			_perspectiveFactorDirty = true;
			zoomCompleteSignal.dispatch();
		}

		public function limitInteractionToUpperPartOfTheScreen( value:Boolean ):void {
			_isScrollingLimited = value;
		}

		public function set cameraY( value:Number ):void {
			_camera.y = value;
			_perspectiveFactorDirty = true;
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
			_positionManager.snapAtIndexWithoutEasing( value );
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
				var limit:Number = _stageHeight - 211 * CoreSettings.GLOBAL_SCALING;
				if( _interactionManager.currentY > limit ) return;
			}
			_interactionManager.startInteraction();
		}

		public function endPanInteraction():void {
			if( !isActive ) return;
			_interactionManager.endInteraction();
		}

		private function updatePerspectiveFactor():void {

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
			if( _perspectiveTracer ) {
				_perspectiveTracer.position = collisionPoint;
			}

			// Calculate the perspective factor by comparing the half screen width with how much of the wall is visible.
			var halfSceneWidth:Number = collisionPoint.x - _camera.x;
			var halfViewWidth:Number = _stageWidth / 2;
			var multiplier:Number = halfSceneWidth / halfViewWidth;
			trace( this, ">>>> input multiplier: " + multiplier );
			trace( this, "half scene: " + halfSceneWidth );
			trace( this, "half view: " + halfViewWidth );
			trace( this, "camera x: " + _camera.x );
			trace( this, "collision x: " + collisionPoint.x );
			_interactionManager.scrollInputMultiplier = multiplier/* * ViewCore.globalScaling*/;
		}

		public function get closestSnapPointChangedSignal():Signal {
			return _positionManager.closestSnapPointChangedSignal;
		}

		public function get zoomedIn():Boolean {
			return _zoomedIn;
		}

		public function get positionManager():SnapPositionManager {
			return _positionManager;
		}

		public function get camera():Camera3D {
			return _camera;
		}
	}
}
