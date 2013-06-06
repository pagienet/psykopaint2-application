package net.psykosoft.psykopaint2.home.views.home.controller
{

	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.entities.Mesh;

	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;

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

			_positionManager.frictionFactor = 0.9;
			_positionManager.minimumThrowingSpeed = 175;
			_positionManager.edgeContainmentFactor = 0.01;

			// Uncomment to visually debug perspective factor.
			// - ensures that the scrolling snaps to finger 100%, if right, the tracer should be placed just at the edge of the screen -
//			_perspectiveTracer = new Mesh( new CubeGeometry(), new ColorMaterial( 0xFF0000 ) );
//			addChild( _perspectiveTracer );
		}

		override public function dispose():void {
			// TODO...
			super.dispose();
		}

		public function zoomIn():void {
			_zoomedIn = true;
			TweenLite.killTweensOf( _cameraTarget );
			TweenLite.killTweensOf( _camera );
			TweenLite.to( _cameraTarget, 1, { y: HomeSettings.CAMERA_ZOOM_IN_Y, ease:Expo.easeInOut } );
			TweenLite.to( _camera, 1, { y: HomeSettings.CAMERA_ZOOM_IN_Y, z: HomeSettings.CAMERA_ZOOM_IN_Z, ease:Expo.easeInOut, onComplete:onZoomComplete } );
		}

		public function zoomOut():void {
			_zoomedIn = false;
			TweenLite.killTweensOf( _cameraTarget );
			TweenLite.killTweensOf( _camera );
			TweenLite.to( _cameraTarget, 1, { y: HomeSettings.CAMERA_ZOOM_OUT_Y, ease:Expo.easeInOut } );
			TweenLite.to( _camera, 1, { y: HomeSettings.CAMERA_ZOOM_OUT_Y, z: HomeSettings.CAMERA_ZOOM_OUT_Z, ease:Expo.easeInOut, onComplete:onZoomComplete } );
		}

		private function onZoomComplete():void {
			_perspectiveFactorDirty = true;
			zoomCompleteSignal.dispatch();
		}

		public function limitInteractionToUpperPartOfTheScreen( value:Boolean ):void {
//			trace( this, "interaction limited: " + value );
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
				var limit:Number = _stageHeight - 200 * CoreSettings.GLOBAL_SCALING;
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
			_interactionManager.scrollInputMultiplier = ( ( collisionPoint.x - _camera.x ) / ( _stageWidth / 2 ) )/* * ViewCore.globalScaling*/;
		}

		public function get closestSnapPointChangedSignal():Signal {
			return _positionManager.closestSnapPointChangedSignal;
		}

		public function get zoomedIn():Boolean {
			return _zoomedIn;
		}
	}
}
