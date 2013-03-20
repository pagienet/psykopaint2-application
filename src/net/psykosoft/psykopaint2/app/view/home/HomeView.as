package net.psykosoft.psykopaint2.app.view.home
{

	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.utils.Cast;

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.app.assets.away3d.textures.Away3dTextureManager;
	import net.psykosoft.psykopaint2.app.assets.away3d.textures.ManagedAway3DBitmapTexture;
	import net.psykosoft.psykopaint2.app.assets.away3d.textures.data.Away3dFrameTextureType;
	import net.psykosoft.psykopaint2.app.assets.away3d.textures.data.Away3dTextureType;
	import net.psykosoft.psykopaint2.app.assets.away3d.textures.vo.Away3dFrameAtlasTextureDescriptorVO;
	import net.psykosoft.psykopaint2.app.assets.away3d.textures.vo.Away3dTextureInfoVO;
	import net.psykosoft.psykopaint2.app.view.base.Away3dViewBase;
	import net.psykosoft.psykopaint2.app.view.home.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.app.view.home.objects.Easel;
	import net.psykosoft.psykopaint2.app.view.home.objects.Picture;
	import net.psykosoft.psykopaint2.app.view.home.objects.PictureFrame;

	import org.osflash.signals.Signal;

	public class HomeView extends Away3dViewBase
	{
		// -----------------------
		// Shadow decal.
		// -----------------------
		// TODO: move to asset manager
		[Embed(source="../../../../../../../assets-embedded/textures/misc/frame-shadow.png")]
		private var FrameShadowAsset:Class;

		private var _wallFrames:Vector.<PictureFrame>;
		private var _shadowMesh:Mesh;
		private var _frameMaterial:TextureMaterial;
		private var _shadows:Dictionary;
		private var _framesAtlasXml:XML;
		private var _framesAtlasTextureInfo:Away3dTextureInfoVO;
		private var _cameraAwake:Boolean;
		private var _closestPaintingIndex:uint;

		private const FRAME_GAP_X:Number = 500;

		private const PAINTINGS_Y:Number = 400;
		private const PAINTINGS_SCALE:Number = 0.9;
		private const PAINTING_DISTANCE_FROM_WALL:Number = 2;

		private const WALL_WIDTH:Number = 100000;
		private const WALL_HEIGHT:Number = 2000;
		private const WALL_BASE_Y:Number = -500;
		private const WALL_Z:Number = 400;

		private const FLOOR_DEPTH:Number = 1500;

		private const SHADOW_INFLATION_X:Number = 1.075;
		private const SHADOW_INFLATION_Y:Number = 1.1;
		private const SHADOW_OFFSET_Y:Number = -50;

		private const DEFAULT_CAMERA_Z:Number = -1750;

		public function HomeView() {

			super();

			snappedAtPaintingSignal = new Signal();
			closestPaintingChangedSignal = new Signal();
			motionStartedSignal = new Signal();

//			var tri:Trident = new Trident( 500 );
//			addChild3d( tri );

			_wallFrames = new Vector.<PictureFrame>();

			// Wall.
			var wallGeometry:PlaneGeometry = new PlaneGeometry( 1024, 1024 );
			wallGeometry.scaleUV( WALL_WIDTH / wallGeometry.width, 2 );
			_wall = new Mesh( wallGeometry, new ColorMaterial() );
			_wall.scaleX = WALL_WIDTH / wallGeometry.width;
			_wall.scaleZ = WALL_HEIGHT / wallGeometry.height;
			_wall.rotationX = -90;
			_wall.y = WALL_BASE_Y + WALL_HEIGHT / 2;
			_wall.z = WALL_Z;
			addChild3d( _wall );

			// Floor.
			var floorGeometry:PlaneGeometry = new PlaneGeometry( 1024, 1024 );
			floorGeometry.scaleUV( WALL_WIDTH / floorGeometry.width, 1 );
			var floorMaterial:TextureMaterial = new TextureMaterial( Away3dTextureManager.getTextureById( Away3dTextureType.FLOORPAPER_PLANKS, true ) );
			floorMaterial.repeat = true;
			floorMaterial.smooth = true;
			floorMaterial.mipmap = true; // Mipmapping is disabled for textures coming from Away3dTextureManager - see ManagedAway3DBitmapTexture.
			_floor = new Mesh( floorGeometry, floorMaterial );
			_floor.scaleX = WALL_WIDTH / floorGeometry.width;
			_floor.scaleZ = FLOOR_DEPTH / floorGeometry.height;
			_floor.y = _wall.y - WALL_HEIGHT / 2 - 5; // Literal offsets kind of slide the floor under the home
			_floor.z = WALL_Z - FLOOR_DEPTH / 2 + 190;
			addChild3d( _floor );

		}

		override protected function onStageAvailable():void {

			// Initialize camera controller.
			_camera.x = 0;
			_camera.y = 0;
			_camera.z = DEFAULT_CAMERA_Z;
			_cameraController = new ScrollCameraController( _camera, _wall, stage );
			_cameraController.motionStartedSignal.add( onCameraMotionStarted );
			_cameraController.motionEndedSignal.add( onCameraMotionEnded );

			super.onStageAvailable();
		}

		public function reset():void {

			// Remove frames.
			var len:uint = _wallFrames.length;
			for( var i:uint = 0; i < len; ++i ) {
				var wallFrame:PictureFrame = _wallFrames[ i ];
				removeChild3d( wallFrame );
				// TODO: add destroy method to wallFrame?
			}

			// Remove frame shadows.
			for each( var mesh:Mesh in _shadows ) {
				removeChild3d( mesh );
				mesh.dispose();
				mesh = null;
			}

			_cameraController.reset();
		}

		// ---------------------------------------------------------------------
		// Frames.
		// ---------------------------------------------------------------------

		private var _easel:Easel;
		private var _positioningOffset:uint;

		private function addPictureFrame( pictureFrame:PictureFrame ):void {

			// Transform frame, store it and add it to the scenegraph.
			if( _wallFrames.length > 0 ) {
				var previousFrame:PictureFrame = _wallFrames[ _wallFrames.length - 1 ];
				_positioningOffset += previousFrame.width / 2 + FRAME_GAP_X + pictureFrame.width / 2;
			}
			pictureFrame.x = _positioningOffset;
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

		public function loadDefaultHomeFrames():void {

			checkInit();

			// -----------------------
			// Settings frame.
			// -----------------------

			// Picture.
			var settingsTexture:ManagedAway3DBitmapTexture = Away3dTextureManager.getTextureById( Away3dTextureType.SETTINGS_PAINTING );
			var settingsTextureInfo:Away3dTextureInfoVO = Away3dTextureManager.getTextureInfoById( Away3dTextureType.SETTINGS_PAINTING );
			var settingsPicture:Picture = new Picture( settingsTextureInfo, settingsTexture );
			// TODO: 3d mouse picking not working... do we need it anyway?
			settingsPicture.mouseEnabled = settingsPicture.mouseChildren = true;
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
			// Easel.
			// -----------------------

			_easel = new Easel();

			var previousFrame:PictureFrame = _wallFrames[ _wallFrames.length - 1 ];
			_easel.x = previousFrame.x + previousFrame.width / 2 + FRAME_GAP_X + _easel.width / 2;
			_easel.y = PAINTINGS_Y;
			_easel.z = 0;

			_cameraController.addSnapPoint( _easel.x );

			_positioningOffset += _easel.x;

			addChild3d( _easel );

			// -----------------------
			// Psykopaint frame.
			// -----------------------

			// Picture.
			var psykopaintTexture:ManagedAway3DBitmapTexture = Away3dTextureManager.getTextureById( Away3dTextureType.PSYKOPAINT_PAINTING );
			var psykopaintTextureInfo:Away3dTextureInfoVO = Away3dTextureManager.getTextureInfoById( Away3dTextureType.PSYKOPAINT_PAINTING );
			var psykopaintPicture:Picture = new Picture( psykopaintTextureInfo, psykopaintTexture );
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
			_cameraController.jumpToSnapPoint( 2 );

		}

		public function loadUserFrames():void {

			checkInit();

			// TODO: implementing dummy images for now

			// Add a few test frames.
			var frameIds:Array = Away3dFrameTextureType.getAvailableTypes();
			var samplePaintingIds:Array = [
				"SAMPLE_PAINTING",
				"SAMPLE_PAINTING1",
				"SAMPLE_PAINTING2",
				"SAMPLE_PAINTING3",
				"SAMPLE_PAINTING4",
				"SAMPLE_PAINTING5",
				"SAMPLE_PAINTING6"
			];
			var samplePaintingScales:Array = [ 1, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5 ];
			for( var i:uint = 0; i < samplePaintingIds.length; i++ ) {

				// Picture.
				var dummyImageDiffuseId:String = Away3dTextureType[ samplePaintingIds[ i ] + "_DIFFUSE" ];
				var dummyImageDiffuse:ManagedAway3DBitmapTexture = Away3dTextureManager.getTextureById( dummyImageDiffuseId );
				var dummyImageDescription:Away3dTextureInfoVO = Away3dTextureManager.getTextureInfoById( dummyImageDiffuseId );
				var picture:Picture = new Picture( dummyImageDescription, dummyImageDiffuse );
				picture.scalePainting( samplePaintingScales[ i ] );

				var frameId:String = frameIds[ Math.floor( frameIds.length * Math.random() ) ];

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

		private function initializeFrameShadow():void {
			var shadowMaterial:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( new FrameShadowAsset() ) );
			shadowMaterial.smooth = true;
			shadowMaterial.mipmap = false;
			shadowMaterial.alpha = 0.9;
			shadowMaterial.alphaBlending = true;
			_shadowMesh = new Mesh( new PlaneGeometry( 512, 512 ), shadowMaterial );
			_shadowMesh.rotationX = -90;
			_shadows = new Dictionary();
		}

		private function initializeFrameMaterial():void {
			_frameMaterial = new TextureMaterial( Away3dTextureManager.getTextureById( Away3dTextureType.FRAMES_ATLAS ) );
			_frameMaterial.mipmap = false;
			_frameMaterial.smooth = true;
			_framesAtlasXml = Away3dTextureManager.getAtlasDataById( Away3dTextureType.FRAMES_ATLAS );
			_framesAtlasTextureInfo = Away3dTextureManager.getTextureInfoById( Away3dTextureType.FRAMES_ATLAS );
		}

		private function checkInit():void {
			if( !_shadowMesh ) initializeFrameShadow();
			if( !_frameMaterial ) initializeFrameMaterial();
		}

		// ---------------------------------------------------------------------
		// Updates.
		// ---------------------------------------------------------------------

		override protected function onUpdate():void {

			_cameraController.update();

			// Notify when the closest painting has changed.
			var closest:uint = _cameraController.evaluateCurrentClosestSnapPointIndex();
			if( closest != _closestPaintingIndex ) {
				_closestPaintingIndex = closest;
				closestPaintingChangedSignal.dispatch( closest );
			}
		}

		// ---------------------------------------------------------------------
		// Wall and floor.
		// ---------------------------------------------------------------------

		private var _wall:Mesh;
		private var _floor:Mesh;

		public function changeWallpaper( bmd:BitmapData ):void {
			var wallMaterial:TextureMaterial = new TextureMaterial( new ManagedAway3DBitmapTexture( bmd ) );
			wallMaterial.mipmap = false;
			wallMaterial.smooth = true;
			wallMaterial.repeat = true;
			_wall.material = wallMaterial;
		}

		// ---------------------------------------------------------------------
		// Camera controller wrapper methods.
		// ---------------------------------------------------------------------

		private var _cameraController:ScrollCameraController;

		public var snappedAtPaintingSignal:Signal;
		public var closestPaintingChangedSignal:Signal;
		public var motionStartedSignal:Signal;

		private function onCameraMotionEnded( snapPoint:uint ):void {
//			trace( this, "motion ended at " + snapPoint );
			_cameraAwake = false;
			snappedAtPaintingSignal.dispatch( snapPoint );
		}

		private function onCameraMotionStarted():void {
//			trace( this, "motion started." );
			_cameraAwake = true;
			motionStartedSignal.dispatch();
		}

		public function get currentPainting():uint {
			return _cameraController.evaluateCurrentClosestSnapPoint();
		}

		/*
		* Limits scrolling to everything BUT the lower area of the screen.
		* If false, scrolling can occur on the entire screen.
		* */
		public function set limitScrolling( value:Boolean ):void {
			_cameraController.scrollingLimited = value;
		}

		public function animateToPainting( index:int ):void {
			_cameraController.jumpToSnapPointAnimated( index );
		}

		public function get cameraAwake():Boolean {
			return _cameraAwake;
		}

		public function startPanInteraction():void {
			_cameraController.startPanInteraction();
		}

		public function stopPanInteraction():void {
			_cameraController.endPanInteraction();
		}

		public function zoomIn():void {
			// TODO: could calculate current painting dimensions and dynamically adjust to it
			TweenLite.to( _camera, 0.5, { z: DEFAULT_CAMERA_Z + 1000, y: PAINTINGS_Y, ease:Strong.easeOut } );
		}

		public function zoomOut():void {
			TweenLite.to( _camera, 0.5, { z: DEFAULT_CAMERA_Z, y: 0, ease:Strong.easeOut } );
		}

		public function getSnapPointCount():uint {
			return _cameraController.getSnapPointCount();
		}
	}
}
