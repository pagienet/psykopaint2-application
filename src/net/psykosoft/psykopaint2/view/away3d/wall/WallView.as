package net.psykosoft.psykopaint2.view.away3d.wall
{

	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	import away3d.utils.Cast;

	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.view.away3d.base.Away3dViewBase;
	import net.psykosoft.psykopaint2.view.away3d.wall.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.view.away3d.wall.wallframes.Frame;
	import net.psykosoft.psykopaint2.view.away3d.wall.wallframes.Picture;
	import net.psykosoft.psykopaint2.view.away3d.wall.wallframes.WallFrame;
	import net.psykosoft.psykopaint2.view.away3d.wall.wallframes.frames.FrameTextureManager;
	import net.psykosoft.psykopaint2.view.away3d.wall.wallframes.frames.FrameTextureType;

	import org.osflash.signals.Signal;

	public class WallView extends Away3dViewBase implements IWallView
	{
		// TODO: move to asset manager

		// -----------------------
		// Wall.
		// -----------------------
		[Embed(source="../../../../../../../assets/images/textures/wall/cement/cement-baked.jpg")]
		private var WallBakedAsset:Class;

		// -----------------------
		// Floor.
		// -----------------------
		[Embed(source="../../../../../../../assets/images/textures/floor/wood/wood-baked.jpg")]
		private var FloorBakedAsset:Class;

		// -----------------------
		// Shadow decal.
		// -----------------------
		[Embed(source="../../../../../../../assets/images/textures/misc/frame-shadow.png")]
		private var FrameShadowAsset:Class;

		private var _wallFrames:Vector.<WallFrame>;
		private var _cameraController:ScrollCameraController;
		private var _wall:Mesh;
		private var _floor:Mesh;
		private var _wallFrameClickedSignal:Signal;
		private var _cameraLight:PointLight;
		private var _sceneLightPicker:StaticLightPicker;

		private const FRAME_GAP_X:Number = 1000;

		private const PAINTINGS_Y:Number = 500;
		private const PAINTINGS_SCALE:Number = 0.9;
		private const PAINTING_DISTANCE_FROM_WALL:Number = 5;

		private const WALL_WIDTH:Number = 100000;
		private const WALL_HEIGHT:Number = 2000;
		private const WALL_BASE_Y:Number = -600;
		private const WALL_Z:Number = 400;

		private const FLOOR_DEPTH:Number = 1000;

		public function WallView() {

			super();

//			var tri:Trident = new Trident( 500 );
//			addChild3d( tri );

			_wallFrames = new Vector.<WallFrame>();
			_wallFrameClickedSignal = new Signal();

			// Light that moves with camera.
			// Affects paintings and their frames.
			_cameraLight = new PointLight();
			_cameraLight.ambient = 1;
			_cameraLight.diffuse = 0.75;
			_cameraLight.specular = 1;
			_cameraLight.position = new Vector3D( 0, WALL_HEIGHT / 2, WALL_Z - PAINTING_DISTANCE_FROM_WALL - 250 ); // Light will move in x.
			_sceneLightPicker = new StaticLightPicker( [ _cameraLight ] );
			addChild3d( _cameraLight );

			var planeGeometry:PlaneGeometry = new PlaneGeometry( 1024, 1024 );
			planeGeometry.scaleUV( WALL_WIDTH / planeGeometry.width, 1 );

			// Wall.
			var wallMaterial:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( new WallBakedAsset() ) );
			wallMaterial.repeat = true;
			wallMaterial.smooth = true;
			_wall = new Mesh( planeGeometry, wallMaterial );
			_wall.scaleX = WALL_WIDTH / planeGeometry.width;
			_wall.scaleZ = WALL_HEIGHT / planeGeometry.height;
			_wall.rotationX = -90;
			_wall.y = WALL_BASE_Y + WALL_HEIGHT / 2;
			_wall.z = WALL_Z;
			addChild3d( _wall );

			// Floor.
			var floorMaterial:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( new FloorBakedAsset() ) );
			floorMaterial.repeat = true;
			floorMaterial.smooth = true;
			_floor = new Mesh( planeGeometry, floorMaterial );
			_floor.scaleX = WALL_WIDTH / planeGeometry.width;
			_floor.scaleZ = FLOOR_DEPTH / planeGeometry.height;
			_floor.y = _wall.y - WALL_HEIGHT / 2 - 5; // Literal offsets kind of slide the floor under the wall
			_floor.z = WALL_Z - FLOOR_DEPTH / 2 + 190;
			addChild3d( _floor );

		}

		override protected function onStageAvailable():void {

			// Initialize camera controller.
			_camera.z = -2000;
			_cameraController = new ScrollCameraController( _camera, _wall, stage );

			super.onStageAvailable();
		}

		override protected function onUpdate():void {
			_cameraController.update();
			_cameraLight.x = _camera.x;
		}

		private function addWallFrame( wallFrame:WallFrame ):void {
			if( _wallFrames.length > 0 ) {
				var previousFrame:WallFrame = _wallFrames[ _wallFrames.length - 1 ];
				wallFrame.x = previousFrame.x + previousFrame.width / 2 + FRAME_GAP_X + wallFrame.width / 2;
			}
			wallFrame.y = PAINTINGS_Y;
			wallFrame.z = WALL_Z - PAINTING_DISTANCE_FROM_WALL - wallFrame.depth / 2;
			wallFrame.scale( PAINTINGS_SCALE );
			_cameraController.addSnapPoint( wallFrame.x );
			_wallFrames.push( wallFrame );
			addChild3d( wallFrame );
		}

		// ---------------------------------------------------------------------
		// IWallView interface implementation.
		// ---------------------------------------------------------------------

		public function loadDefaultHomeFrames():void {

			var shadowMaterial:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( new FrameShadowAsset() ) );
			shadowMaterial.smooth = true;
			shadowMaterial.alpha = 0.85;
			shadowMaterial.alphaBlending = true;
			var shadow:Mesh = new Mesh( new PlaneGeometry( 512, 512 ), shadowMaterial );
			shadow.rotationX = -90;



			// -----------------------
			// Logo frame.
			// -----------------------

			// Picture.
			var logoPicture:Picture = new Picture( _sceneLightPicker );

			// Frame.
			var logoFrame:Frame = new Frame(
					_sceneLightPicker,
					FrameTextureManager.getFrameTextureById( FrameTextureType.FRAME_WHITE ),
					FrameTextureManager.getFrameTextureDimensionsById( FrameTextureType.FRAME_WHITE ),
					FrameTextureManager.getFrameContentAreaById( FrameTextureType.FRAME_WHITE )
			);

			// Wall frame.
			var logoWallFrame:WallFrame = new WallFrame(
					logoFrame,
					logoPicture,
					shadow.clone() as Mesh,
					PAINTING_DISTANCE_FROM_WALL
			);
			addWallFrame( logoWallFrame );

			// -----------------------
			// Settings frame.
			// -----------------------

			// Picture.
			var settingsPicture:Picture = new Picture( _sceneLightPicker );

			// Frame.
			var settingsFrame:Frame = new Frame(
					_sceneLightPicker,
					FrameTextureManager.getFrameTextureById( FrameTextureType.FRAME_WHITE ),
					FrameTextureManager.getFrameTextureDimensionsById( FrameTextureType.FRAME_WHITE ),
					FrameTextureManager.getFrameContentAreaById( FrameTextureType.FRAME_WHITE )
			);

			// Wall frame.
			var settingsWallFrame:WallFrame = new WallFrame(
					settingsFrame,
					settingsPicture,
					shadow.clone() as Mesh,
					PAINTING_DISTANCE_FROM_WALL
			);
			addWallFrame( settingsWallFrame );

			// -----------------------
			// Dummy frame.
			// -----------------------

			// Picture.
			var dummyPicture:Picture = new Picture( _sceneLightPicker );

			// Frame.
			var dummyFrame:Frame = new Frame(
					_sceneLightPicker,
					FrameTextureManager.getFrameTextureById( FrameTextureType.FRAME_WHITE ),
					FrameTextureManager.getFrameTextureDimensionsById( FrameTextureType.FRAME_WHITE ),
					FrameTextureManager.getFrameContentAreaById( FrameTextureType.FRAME_WHITE )
			);

			// Wall frame.
			var dummyWallFrame:WallFrame = new WallFrame(
					dummyFrame,
					dummyPicture,
					shadow.clone() as Mesh,
					PAINTING_DISTANCE_FROM_WALL
			);
			addWallFrame( dummyWallFrame );

		}

		public function loadDefaultUserFrames():void {
			// TODO
		}

		public function loadUserFrames():void {
			// TODO
		}

		public function clearFrames():void {
			var len:uint = _wallFrames.length;
			for( var i:uint = 0; i < len; ++i ) {
				var wallFrame:WallFrame = _wallFrames[ i ];
				removeChild3d( wallFrame );
				// TODO: add destroy method to wallFrame?
			}
		}

		public function get wallFrameClickedSignal():Signal {
			return _wallFrameClickedSignal;
		}
	}
}
