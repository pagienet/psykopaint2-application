package net.psykosoft.psykopaint2.view.away3d.wall
{

	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;

	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.assets.away3d.textures.vo.Away3dFrameAtlasTextureDescriptorVO;

	import net.psykosoft.psykopaint2.assets.away3d.textures.data.Away3dFrameTextureType;

	import net.psykosoft.psykopaint2.assets.away3d.textures.Away3dTextureManager;
	import net.psykosoft.psykopaint2.assets.away3d.textures.vo.Away3dTextureInfoVO;
	import net.psykosoft.psykopaint2.assets.away3d.textures.data.Away3dTextureType;
	import net.psykosoft.psykopaint2.view.away3d.base.Away3dViewBase;
	import net.psykosoft.psykopaint2.view.away3d.wall.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.view.away3d.wall.frames.Picture;
	import net.psykosoft.psykopaint2.view.away3d.wall.frames.PictureFrame;

	import org.osflash.signals.Signal;

	public class WallView extends Away3dViewBase implements IWallView
	{
		// TODO: move to asset manager
		// TODO: add ability to change wallpapers

		// -----------------------
		// Wall.
		// -----------------------
		[Embed(source="../../../../../../../assets-embed/textures/wallpapers/metal3.jpg")]
		private var WallAsset:Class;

		// -----------------------
		// Floor.
		// -----------------------
		[Embed(source="../../../../../../../assets-embed/textures/floorpapers/planks.jpg")]
		private var FloorAsset:Class;

		// -----------------------
		// Shadow decal.
		// -----------------------
		[Embed(source="../../../../../../../assets-embed/textures/misc/frame-shadow.png")]
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
		private var _shadows:Dictionary;
		private var _framesAtlasXml:XML;
		private var _framesAtlasTextureInfo:Away3dTextureInfoVO;

		private const FRAME_GAP_X:Number = 1000;

		private const PAINTINGS_Y:Number = 400;
		private const PAINTINGS_SCALE:Number = 0.9;
		private const PAINTING_DISTANCE_FROM_WALL:Number = 2;

		private const WALL_WIDTH:Number = 100000;
		private const WALL_HEIGHT:Number = 2000;
		private const WALL_BASE_Y:Number = -600;
		private const WALL_Z:Number = 400;

		private const FLOOR_DEPTH:Number = 1000;

		private const SHADOW_INFLATION_X:Number = 1.075;
		private const SHADOW_INFLATION_Y:Number = 1.1;
		private const SHADOW_OFFSET_Y:Number = -50;

		public function WallView() {

			super();

//			var tri:Trident = new Trident( 500 );
//			addChild3d( tri );

			_wallFrames = new Vector.<PictureFrame>();
			_wallFrameClickedSignal = new Signal();

			// Light that moves with camera.
			// Affects paintings.
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
			var camControlPerspectiveTracer:Mesh = new Mesh( new SphereGeometry(), new ColorMaterial( 0x00FF00 ) );
			camControlPerspectiveTracer.position = new Vector3D(5441.28818321228, 0.0001220703125, 400.0000305175781);
			addChild3d( camControlPerspectiveTracer );

			super.onStageAvailable();
		}

		override protected function onUpdate():void {
			_cameraController.update();
			_cameraLight.x = _camera.x;
		}

		private function addPictureFrame( pictureFrame:PictureFrame ):void {

			// Transform frame, store it and add it to the scenegraph.
			if( _wallFrames.length > 0 ) {
				var previousFrame:PictureFrame = _wallFrames[ _wallFrames.length - 1 ];
				pictureFrame.x = previousFrame.x + previousFrame.width / 2 + FRAME_GAP_X + pictureFrame.width / 2;
			}
			pictureFrame.y = PAINTINGS_Y;
			pictureFrame.z = WALL_Z - PAINTING_DISTANCE_FROM_WALL - pictureFrame.depth / 2;
			pictureFrame.scale( PAINTINGS_SCALE );
			_cameraController.addSnapPoint( pictureFrame.x );
			_wallFrames.push( pictureFrame );
			addChild3d( pictureFrame );

			// Create shadow.
			var shadow:Mesh = _shadowMesh.clone() as Mesh;
			shadow.x = pictureFrame.x;
			shadow.y = pictureFrame.y + SHADOW_OFFSET_Y;
			shadow.z = WALL_Z - 1;
			shadow.scaleX = SHADOW_INFLATION_X * pictureFrame.width / 512;
			shadow.scaleZ = SHADOW_INFLATION_Y * pictureFrame.height / 512;
			_shadows[ pictureFrame ] = shadow;
			addChild3d( shadow );
		}

		private function initializeFrameShadow():void {
			var shadowMaterial:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( new FrameShadowAsset() ) );
			shadowMaterial.smooth = true;
			shadowMaterial.alpha = 0.9;
			shadowMaterial.alphaBlending = true;
			_shadowMesh = new Mesh( new PlaneGeometry( 512, 512 ), shadowMaterial );
			_shadowMesh.rotationX = -90;
			_shadows = new Dictionary();
		}

		private function initializeFrameMaterial():void {
			_frameMaterial = new TextureMaterial( Away3dTextureManager.getTextureById( Away3dTextureType.FRAMES_ATLAS ) );
			_frameMaterial.smooth = true;
			_framesAtlasXml = Away3dTextureManager.getAtlasDataById( Away3dTextureType.FRAMES_ATLAS );
			_framesAtlasTextureInfo = Away3dTextureManager.getTextureInfoById( Away3dTextureType.FRAMES_ATLAS );
		}

		private function checkInit():void {
			if( !_shadowMesh ) initializeFrameShadow();
			if( !_frameMaterial ) initializeFrameMaterial();
		}

		// ---------------------------------------------------------------------
		// IWallView interface implementation.
		// ---------------------------------------------------------------------

		public function loadDefaultHomeFrames():void {

			checkInit();

			// -----------------------
			// Settings frame.
			// -----------------------

			// Picture.
			var settingsTexture:BitmapTexture = Away3dTextureManager.getTextureById( Away3dTextureType.SETTINGS_PAINTING );
			var settingsTextureInfo:Away3dTextureInfoVO = Away3dTextureManager.getTextureInfoById( Away3dTextureType.SETTINGS_PAINTING );
			var settingsPicture:Picture = new Picture( _sceneLightPicker, settingsTextureInfo, settingsTexture );
			settingsPicture.scalePainting( 2 );

			// Frame.
			var settingsFrameAtlasDescriptor:Away3dFrameAtlasTextureDescriptorVO = new Away3dFrameAtlasTextureDescriptorVO(
					Away3dFrameTextureType.DANGER,
					_framesAtlasXml,
					_framesAtlasTextureInfo.textureWidth, _framesAtlasTextureInfo.textureHeight
			);
			var settingsFrame:PictureFrame = new PictureFrame( settingsPicture, _frameMaterial, settingsFrameAtlasDescriptor );
			addPictureFrame( settingsFrame );

			// -----------------------
			// Psykopaint frame.
			// -----------------------

			// Picture.
			var psykopaintTexture:BitmapTexture = Away3dTextureManager.getTextureById( Away3dTextureType.PSYKOPAINT_PAINTING );
			var psykopaintTextureInfo:Away3dTextureInfoVO = Away3dTextureManager.getTextureInfoById( Away3dTextureType.PSYKOPAINT_PAINTING );
			var psykopaintPicture:Picture = new Picture( _sceneLightPicker, psykopaintTextureInfo, psykopaintTexture );
			psykopaintPicture.scalePainting( 2 );

			// Frame.
			var psykopaintFrameAtlasDescriptor:Away3dFrameAtlasTextureDescriptorVO = new Away3dFrameAtlasTextureDescriptorVO(
					Away3dFrameTextureType.WHITE,
					_framesAtlasXml,
					_framesAtlasTextureInfo.textureWidth, _framesAtlasTextureInfo.textureHeight
			);
			var psykopaintFrame:PictureFrame = new PictureFrame( psykopaintPicture, _frameMaterial, psykopaintFrameAtlasDescriptor );
			addPictureFrame( psykopaintFrame );

			// Starts looking at the psykopaint frame.
			_cameraController.jumpToSnapPoint( 1 );

		}

		public function loadUserFrames():void {

			checkInit();

			// TODO.
			// implementing dummy images for now

			var dummyImageDiffuse:BitmapTexture = Away3dTextureManager.getTextureById( Away3dTextureType.SAMPLE_PAINTING_DIFFUSE );
			var dummyImageNormals:BitmapTexture = Away3dTextureManager.getTextureById( Away3dTextureType.SAMPLE_PAINTING_NORMALS );
			var dummyImageDescription:Away3dTextureInfoVO = Away3dTextureManager.getTextureInfoById( Away3dTextureType.SAMPLE_PAINTING_DIFFUSE );

			// Add a few test frames.
			var frameIds:Array = Away3dFrameTextureType.getAvailableTypes();
			for( var i:uint = 0; i < frameIds.length; i++ ) {

				// Picture.
				var picture:Picture = new Picture( _sceneLightPicker, dummyImageDescription, dummyImageDiffuse, dummyImageNormals );

				var frameId:String = frameIds[ i ];

				// Frame descriptor.
				var atlasData:Away3dFrameAtlasTextureDescriptorVO = new Away3dFrameAtlasTextureDescriptorVO(
						frameId,
						_framesAtlasXml,
						_framesAtlasTextureInfo.textureWidth, _framesAtlasTextureInfo.textureHeight
				);

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
				// TODO: destroy shadows
			}
		}

		public function get wallFrameClickedSignal():Signal {
			return _wallFrameClickedSignal;
		}
	}
}
