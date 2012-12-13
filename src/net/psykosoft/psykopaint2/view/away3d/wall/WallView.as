package net.psykosoft.psykopaint2.view.away3d.wall
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapCubeTexture;

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.assets.Away3dModelAssetsManager;
	import net.psykosoft.psykopaint2.assets.Away3dTextureAssetsManager;
	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.util.MathUtil;
	import net.psykosoft.psykopaint2.view.away3d.base.Away3dViewBase;
	import net.psykosoft.psykopaint2.view.away3d.wall.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.view.away3d.wall.frames.Frame;
	import net.psykosoft.psykopaint2.view.away3d.wall.frames.Glass;
	import net.psykosoft.psykopaint2.view.away3d.wall.frames.Painting;
	import net.psykosoft.psykopaint2.view.away3d.wall.frames.PaintingInFrame;

	import org.osflash.signals.Signal;

	public class WallView extends Away3dViewBase
	{
		private var _bitmapCubeTexture:BitmapCubeTexture;
		private var _frames:Vector.<PaintingInFrame>;
		private var _cameraController:ScrollCameraController;
		private var _wall:Mesh;

		public var objectClickedSignal:Signal;

		private const FRAME_GAP_X:Number = 500;
		private const PAINTINGS_Y:Number = 100;
		private const WALL_Z:Number = 400;
		private const PAINTING_DISTANCE_FROM_WALL:Number = 50;

		private var _cameraLight:PointLight;

		private var _sceneLightPicker:StaticLightPicker;

		public function WallView() {

			super();

			_frames = new Vector.<PaintingInFrame>();

			objectClickedSignal = new Signal();

			_wall = new Mesh( new PlaneGeometry( 100000, 5000 ), new ColorMaterial( 0x00FF00 ) );
			_wall.rotationX = -90;
			_wall.visible = false;
			_wall.z = WALL_Z;
			addChild3d( _wall );

			_cameraLight = new PointLight();
			_cameraLight.ambient = 1;
			_cameraLight.position = new Vector3D( 0, 500, 0 ); // Light will move in x.
			_sceneLightPicker = new StaticLightPicker( [ _cameraLight ] );
			addChild3d( _cameraLight );

			// Initialize cube texture to be shared by all glass reflections.
			var bmd:BitmapData = Away3dTextureAssetsManager.getBitmapDataById( Away3dTextureAssetsManager.GallerySkyboxImage );
			_bitmapCubeTexture = new BitmapCubeTexture( bmd, bmd, bmd, bmd, bmd, bmd );

			// Get frame model.
			Away3dModelAssetsManager.getModelByIdAsync( Away3dModelAssetsManager.Frame1Model, onFrameModelReady );

		}

		private function onFrameModelReady( model:ObjectContainer3D ):void {

			Cc.log( this, "'" + model.name + "' model ready, creating frames on wall." );

			// Create painting.
			var painting:Painting = new Painting( _sceneLightPicker );
			var paintingWidth:Number = painting.width;
			var paintingHeight:Number = painting.height;

			// TODO: tidy up object creation, instance types, how types are taken in constructors, etc

			// Create frame.
			var frameMaterial:ColorMaterial = new ColorMaterial( 0xFDE910 );
			frameMaterial.gloss = 100;
			frameMaterial.specular = 0.35;
			frameMaterial.ambient = 0.1;
			frameMaterial.lightPicker = _sceneLightPicker;
			var frame:Frame = new Frame( model.clone() as ObjectContainer3D );
			frame.material = frameMaterial;
			frame.fitToPaintingWidth( paintingWidth );

			// Create glass.
			if( Settings.USE_REFLECTIONS_ON_FRAMES ) {
				var glass:Glass = new Glass( _sceneLightPicker, _bitmapCubeTexture );
				Cc.log( this, "Using glass reflections: " + glass )
			}

			// Tests...
			for( var i:uint = 0; i < 15; i++ ) {

				// Create instances.
				var frameInstance:Frame = frame.clone() as Frame;
				var paintingInstance:ObjectContainer3D = painting.clone() as ObjectContainer3D;
				var glassInstance:ObjectContainer3D = Settings.USE_REFLECTIONS_ON_FRAMES ? glass.clone() as ObjectContainer3D : null;
				if( glassInstance ) {
					glassInstance.scaleX = paintingWidth;
					glassInstance.scaleY = paintingHeight;
				}

				// Create paintingInFrame.
				var paintingInFrame:PaintingInFrame = new PaintingInFrame( frameInstance, paintingInstance, glassInstance );
				paintingInFrame.scale( MathUtil.rand( 0.25, 0.5 ) );

				// Position paintingInFrame.
				if( _frames.length > 0 ) {
					var previousFrame:PaintingInFrame = _frames[ _frames.length - 1 ];
					paintingInFrame.x = previousFrame.x + previousFrame.width / 2 + FRAME_GAP_X + paintingInFrame.width / 2;
				}
				paintingInFrame.y = PAINTINGS_Y;
				paintingInFrame.z = WALL_Z - PAINTING_DISTANCE_FROM_WALL;

				// Update scroller range and snapping.
				_cameraController.addSnapPoint( paintingInFrame.x );

				// Store and add to display tree.
				_frames.push( paintingInFrame );
				addChild3d( paintingInFrame );

			}

		}

		override protected function onStageAvailable():void {

			_cameraController = new ScrollCameraController( _camera, _wall, stage );

			super.onStageAvailable();
		}

		override protected function onUpdate():void {

			_cameraController.update();

			var dx:Number = _camera.x - _cameraLight.x;
			_cameraLight.x += 0.075 * dx;

		}
	}
}
