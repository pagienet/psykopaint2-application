package net.psykosoft.psykopaint2.view.away3d.wall
{

	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;

	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.assets.away3d.textures.Away3dAtlasTextureDescriptorVO;

	import net.psykosoft.psykopaint2.assets.away3d.textures.Away3dFrameTextureType;

	import net.psykosoft.psykopaint2.assets.away3d.textures.Away3dTextureAssetsManager;
	import net.psykosoft.psykopaint2.assets.away3d.textures.Away3dTextureInfoVO;
	import net.psykosoft.psykopaint2.assets.away3d.textures.Away3dTextureType;
	import net.psykosoft.psykopaint2.view.away3d.base.Away3dViewBase;
	import net.psykosoft.psykopaint2.view.away3d.wall.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.view.away3d.wall.frames.Picture;
	import net.psykosoft.psykopaint2.view.away3d.wall.frames.PictureFrame;

	import org.osflash.signals.Signal;

	public class WallView extends Away3dViewBase implements IWallView
	{
		// TODO: move to asset manager

		// -----------------------
		// Wall.
		// -----------------------
		[Embed(source="../../../../../../../assets/images/textures/wallpapers/metal3.jpg")]
		private var WallAsset:Class;

		// -----------------------
		// Floor.
		// -----------------------
		[Embed(source="../../../../../../../assets/images/textures/floorpapers/planks.jpg")]
		private var FloorAsset:Class;

		// -----------------------
		// Shadow decal.
		// -----------------------
		[Embed(source="../../../../../../../assets/images/textures/misc/frame-shadow.png")]
		private var FrameShadowAsset:Class;

		private var _wallFrames:Vector.<PictureFrame>;
		private var _cameraController:ScrollCameraController;
		private var _wall:Mesh;
		private var _floor:Mesh;
		private var _wallFrameClickedSignal:Signal;
		private var _cameraLight:PointLight;
		private var _sceneLightPicker:StaticLightPicker;
		private var _shadowMesh:Mesh;
		private var _frameMaterial:TextureMaterial;

		private const FRAME_GAP_X:Number = 1000;

		private const PAINTINGS_Y:Number = 400;
		private const PAINTINGS_SCALE:Number = 0.9;
		private const PAINTING_DISTANCE_FROM_WALL:Number = 2;

		private const WALL_WIDTH:Number = 100000;
		private const WALL_HEIGHT:Number = 2000;
		private const WALL_BASE_Y:Number = -600;
		private const WALL_Z:Number = 400;

		private const FLOOR_DEPTH:Number = 1000;

		public function WallView() {

			super();

//			var tri:Trident = new Trident( 500 );
//			addChild3d( tri );

			_wallFrames = new Vector.<PictureFrame>();
			_wallFrameClickedSignal = new Signal();

			// Light that moves with camera.
			// Affects paintings and their frames.
			_cameraLight = new PointLight();
			_cameraLight.ambient = 1;
			_cameraLight.diffuse = 1;
			_cameraLight.specular = 1;
			_cameraLight.color = 0xFFFFFF;
			_cameraLight.position = new Vector3D( 0, 1024, WALL_Z - PAINTING_DISTANCE_FROM_WALL - 100 ); // Light will move in x.
			_sceneLightPicker = new StaticLightPicker( [ _cameraLight ] );
			addChild3d( _cameraLight );

			// Wall.
			var wallGeometry:PlaneGeometry = new PlaneGeometry( 1024, 1024 );
			wallGeometry.scaleUV( WALL_WIDTH / wallGeometry.width, 2 );
			var wallMaterial:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( new WallAsset() ) );
			wallMaterial.repeat = true;
			wallMaterial.smooth = true;
			_wall = new Mesh( wallGeometry, wallMaterial );
			_wall.scaleX = WALL_WIDTH / wallGeometry.width;
			_wall.scaleZ = WALL_HEIGHT / wallGeometry.height;
			_wall.rotationX = -90;
			_wall.y = WALL_BASE_Y + WALL_HEIGHT / 2;
			_wall.z = WALL_Z;
			addChild3d( _wall );

			// Floor.
			var floorGeometry:PlaneGeometry = new PlaneGeometry( 1024, 1024 );
			floorGeometry.scaleUV( WALL_WIDTH / floorGeometry.width, 1 );
			var floorMaterial:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( new FloorAsset() ) );
			floorMaterial.repeat = true;
			floorMaterial.smooth = true;
			_floor = new Mesh( floorGeometry, floorMaterial );
			_floor.scaleX = WALL_WIDTH / floorGeometry.width;
			_floor.scaleZ = FLOOR_DEPTH / floorGeometry.height;
			_floor.y = _wall.y - WALL_HEIGHT / 2 - 5; // Literal offsets kind of slide the floor under the wall
			_floor.z = WALL_Z - FLOOR_DEPTH / 2 + 190;
			addChild3d( _floor );

		}

		override protected function onStageAvailable():void {

			// Initialize camera controller.
			_camera.z = -1750;
			_cameraController = new ScrollCameraController( _camera, _wall, stage );

			super.onStageAvailable();
		}

		override protected function onUpdate():void {
			_cameraController.update();
			_cameraLight.x = _camera.x;
		}

		private function addPictureFrame( wallFrame:PictureFrame ):void {
			if( _wallFrames.length > 0 ) {
				var previousFrame:PictureFrame = _wallFrames[ _wallFrames.length - 1 ];
				wallFrame.x = previousFrame.x + previousFrame.width / 2 + FRAME_GAP_X + wallFrame.width / 2;
			}
			wallFrame.y = PAINTINGS_Y;
			wallFrame.z = WALL_Z - PAINTING_DISTANCE_FROM_WALL - wallFrame.depth / 2;
			wallFrame.scale( PAINTINGS_SCALE );
			_cameraController.addSnapPoint( wallFrame.x );
			_wallFrames.push( wallFrame );
			addChild3d( wallFrame );
		}

		private function initializeFrameShadow():void {
			var shadowMaterial:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( new FrameShadowAsset() ) );
			shadowMaterial.smooth = true;
			shadowMaterial.alpha = 0.9;
			shadowMaterial.alphaBlending = true;
			_shadowMesh = new Mesh( new PlaneGeometry( 512, 512 ), shadowMaterial );
			_shadowMesh.rotationX = -90;
		}

		private function initializeFrameMaterial():void {
			_frameMaterial = new TextureMaterial(
					Away3dTextureAssetsManager.getTextureById( Away3dTextureType.TEXTURE_FRAMES )
			);
			_frameMaterial.smooth = true;
		}

		// ---------------------------------------------------------------------
		// IWallView interface implementation.
		// ---------------------------------------------------------------------

		public function loadDefaultHomeFrames():void {

			if( !_shadowMesh ) initializeFrameShadow();
			if( !_frameMaterial ) initializeFrameMaterial();

			// TODO.

		}

		public function loadUserFrames():void {

			if( !_shadowMesh ) initializeFrameShadow();
			if( !_frameMaterial ) initializeFrameMaterial();

			// TODO.
			// implementing dummy images for now

			var dummyImageDiffuse:BitmapTexture = Away3dTextureAssetsManager.getTextureById( Away3dTextureType.TEXTURE_SAMPLE_PAINTING_DIFFUSE );
			var dummyImageNormals:BitmapTexture = Away3dTextureAssetsManager.getTextureById( Away3dTextureType.TEXTURE_SAMPLE_PAINTING_NORMALS );
			var dummyImageDescription:Away3dTextureInfoVO = Away3dTextureAssetsManager.getTextureDescriptionById( Away3dTextureType.TEXTURE_SAMPLE_PAINTING_DIFFUSE );

			var framesAtlas:XML = Away3dTextureAssetsManager.getAtlasById( Away3dTextureType.TEXTURE_FRAMES );
			trace( "atlas: " + framesAtlas );

			// Add a few test frames.
			var frameIds:Array = Away3dFrameTextureType.getAvailableTypes();
			for( var i:uint = 0; i < frameIds.length; i++ ) {

				// Picture.
				var picture:Picture = new Picture( _sceneLightPicker, dummyImageDescription, dummyImageDiffuse, dummyImageNormals );

				var frameId:String = frameIds[ i ];
				trace( "frame id: " + frameId );

				// Frame descriptor.
				var atlasTextureInfo:Away3dTextureInfoVO = Away3dTextureAssetsManager.getTextureDescriptionById( Away3dTextureType.TEXTURE_FRAMES );
				var atlasData:Away3dAtlasTextureDescriptorVO = new Away3dAtlasTextureDescriptorVO(
						frameId,
						framesAtlas,
						atlasTextureInfo.textureWidth, atlasTextureInfo.textureHeight
				);
				trace( "atlas data: " + atlasData );

				// Wall frame.
				var wallFrame:PictureFrame = new PictureFrame(
						picture,
						_frameMaterial,
						atlasData
				);
				addPictureFrame( wallFrame );

			}

		}

		public function clearFrames():void {
			var len:uint = _wallFrames.length;
			for( var i:uint = 0; i < len; ++i ) {
				var wallFrame:PictureFrame = _wallFrames[ i ];
				removeChild3d( wallFrame );
				// TODO: add destroy method to wallFrame?
			}
		}

		public function get wallFrameClickedSignal():Signal {
			return _wallFrameClickedSignal;
		}
	}
}
