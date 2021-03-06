package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.bounds.AxisAlignedBoundingBox;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.SphereGeometry;

	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	public class HomeViewUtils
	{
		public static function calculatePlaneScreenRect( plane:Mesh, view:View3D ):Rectangle {
			var bounds:AxisAlignedBoundingBox = plane.bounds as AxisAlignedBoundingBox;
			var tlCorner:Vector3D = objectSpaceToScreenSpace( plane, new Vector3D( -bounds.halfExtentsX, bounds.halfExtentsY, 0 ), view );
			var brCorner:Vector3D = objectSpaceToScreenSpace( plane, new Vector3D( bounds.halfExtentsX, -bounds.halfExtentsY, 0 ), view );
			var rect:Rectangle = new Rectangle(
					tlCorner.x / CoreSettings.GLOBAL_SCALING,
					tlCorner.y / CoreSettings.GLOBAL_SCALING,
					( brCorner.x - tlCorner.x ) / CoreSettings.GLOBAL_SCALING,
					( brCorner.y - tlCorner.y ) / CoreSettings.GLOBAL_SCALING
			);
			return rect;
		}

		public static function ensurePlaneFitsViewport( plane:Mesh, view:View3D ):void {

//			trace( "HomeViewUtils - fitting plane to viewport..." );

			// Use a ray to determine the target width of the plane.
			var rayPosition:Vector3D = view.camera.unproject( 0, 0, 0 );
			var rayDirection:Vector3D = view.camera.unproject( 1, 0, 1 );
			rayDirection = rayDirection.subtract( rayPosition );
			rayDirection.normalize();
			// Typical ray-plane intersection calculation.
			var planeNormal:Vector3D = new Vector3D( 0, 0, -1 );
			var ns:Number = planeNormal.dotProduct( rayPosition );
			var planePosition:Vector3D = plane.position;
			var d:Number = -planeNormal.dotProduct( planePosition );
			var nv:Number = planeNormal.dotProduct( rayDirection );
			var t:Number = -( ns + d ) / nv;
			// Half width of collision is target half width of the plane.
			var targetPlaneHalfWidth:Number = rayPosition.x + t * rayDirection.x - view.camera.x;
//			trace( "targetPlaneHalfWidth: " + targetPlaneHalfWidth );

			// Scale the plane so that it fits.
			var bounds:AxisAlignedBoundingBox = plane.bounds as AxisAlignedBoundingBox;
//			trace( "actual width: " + bounds.halfExtentsX );
			var sc:Number = targetPlaneHalfWidth / bounds.halfExtentsX;
//			trace( "scale: " + sc );
			plane.scaleX = plane.scaleY = sc;
		}

		public static function calculateCameraYZToFitPlaneOnViewport( plane:Mesh, view:View3D ):Vector3D {

			var zoom:Vector3D = new Vector3D();

			// Camera y must match world space y.
			var planeWorldSpace:Vector3D = HomeViewUtils.objectSpaceToWorldSpace( plane, new Vector3D() );
			zoom.y = planeWorldSpace.y;

			// Evaluate the portion of the screen the easel would take when aligned with the target in y,
			// and use this info to calculate the target camera z position.
			var cameraTransformCache:Matrix3D = view.camera.transform.clone();
			view.camera.y = planeWorldSpace.y;
			view.camera.lookAt( planeWorldSpace );
			var screenRect:Rectangle = calculatePlaneScreenRect( plane, view );
			var widthRatio:Number = screenRect.width / 1024;
			var distanceToCamera:Number = Math.abs( view.camera.z - planeWorldSpace.z );
			var targetDistance:Number = distanceToCamera * widthRatio;
			zoom.z = planeWorldSpace.z - targetDistance;
			view.camera.transform = cameraTransformCache;

			return zoom;
		}

		public static function objectSpaceToWorldSpace( plane:Mesh, objSpacePosition:Vector3D):Vector3D {
			return plane.sceneTransform.transformVector( objSpacePosition );
		}

		public static function objectSpaceToScreenSpace( plane:Mesh, objSpacePosition:Vector3D, view:View3D ):Vector3D {

//			trace( this, "objectSpaceToScreenSpace --------------------" );

			// Scene space.
			var worldSpacePosition:Vector3D = objectSpaceToWorldSpace( plane, objSpacePosition );

			// View space.
			var screenPosition:Vector3D = view.camera.project( worldSpacePosition );
			screenPosition.x = 0.5 * CoreSettings.STAGE_WIDTH * ( 1 + screenPosition.x );
			screenPosition.y = 0.5 * CoreSettings.STAGE_HEIGHT * ( 1 + screenPosition.y );

			// Uncomment to visualize 2d point.
			/*var tracer2d:Sprite = new Sprite();
			tracer2d.graphics.beginFill( 0xFF0000, 1 );
			tracer2d.graphics.drawCircle( screenPosition.x, screenPosition.y, 10 );
			tracer2d.graphics.endFill();
			view.addChild( tracer2d );*/

//			trace( "screen position: " + screenPosition );
			return screenPosition;
		}
	}
}
