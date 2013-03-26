package net.psykosoft.psykopaint2.app.view.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.materials.TextureMaterial;

	import net.psykosoft.psykopaint2.app.assets.away3d.textures.Away3dTextureManager;
	import net.psykosoft.psykopaint2.app.assets.away3d.textures.ManagedAway3DBitmapTexture;
	import net.psykosoft.psykopaint2.app.assets.away3d.textures.data.Away3dFrameTextureType;
	import net.psykosoft.psykopaint2.app.assets.away3d.textures.data.Away3dTextureType;
	import net.psykosoft.psykopaint2.app.assets.away3d.textures.vo.Away3dFrameAtlasTextureDescriptorVO;
	import net.psykosoft.psykopaint2.app.assets.away3d.textures.vo.Away3dTextureInfoVO;
	import net.psykosoft.psykopaint2.app.view.home.controller.ScrollCameraController;

	public class FrameManager extends ObjectContainer3D
	{
		private var _easel:Easel;
		private var _positioningOffset:uint;
		private var _frameMaterial:TextureMaterial;
		private var _framesAtlasXml:XML;
		private var _framesAtlasTextureInfo:Away3dTextureInfoVO;
		private var _wallFrames:Vector.<PictureFrame>;
		private var _cameraController:ScrollCameraController;
		private var _room:Room;

		private const FRAME_GAP_X:Number = 500;
		private const PAINTINGS_SCALE:Number = 0.9;

		public function FrameManager( cameraController:ScrollCameraController, room:Room ) {
			super();
			_cameraController = cameraController;
			_room = room;
		}

		override public function dispose():void {

			for( var i:uint; i < _wallFrames.length; i++ ) {
				var frame:PictureFrame = _wallFrames[ i ];
				frame.dispose();
			}
			_wallFrames = null;

			_frameMaterial.dispose();

			_easel.dispose();

			super.dispose();
		}

		// ---------------------------------------------------------------------
		// Frames.
		// ---------------------------------------------------------------------

		private function addPictureFrame( pictureFrame:PictureFrame ):void {

			if( !_wallFrames ) _wallFrames = new Vector.<PictureFrame>();

			// Transform frame, store it and add it to the scenegraph.
			if( _wallFrames.length > 0 ) {
				var previousFrame:PictureFrame = _wallFrames[ _wallFrames.length - 1 ];
				_positioningOffset += previousFrame.width / 2 + FRAME_GAP_X + pictureFrame.width / 2;
			}
			pictureFrame.x = _positioningOffset;
			pictureFrame.z = -pictureFrame.depth / 2;
			pictureFrame.scale( PAINTINGS_SCALE );
			_cameraController.addSnapPoint( pictureFrame.x );
			_wallFrames.push( pictureFrame );
			addChild( pictureFrame );

			// Create shadow.
			_room.addShadow( this.x + pictureFrame.x, this.y + pictureFrame.y, pictureFrame.width, pictureFrame.height );
		}

		public function loadDefaultHomeFrames():void {

			if( !_frameMaterial ) initializeFrameMaterial();

			// -----------------------
			// Settings frame.
			// -----------------------

			// Picture.
			var settingsTexture:ManagedAway3DBitmapTexture = Away3dTextureManager.getTextureById( Away3dTextureType.SETTINGS_PAINTING );
			var settingsTextureInfo:Away3dTextureInfoVO = Away3dTextureManager.getTextureInfoById( Away3dTextureType.SETTINGS_PAINTING );
			var settingsPicture:Picture = new Picture( settingsTextureInfo, settingsTexture );
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

			_cameraController.addSnapPoint( _easel.x );

			_positioningOffset += _easel.x;

			addChild( _easel );

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

			if( !_frameMaterial ) initializeFrameMaterial();

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

		private function initializeFrameMaterial():void {
			_frameMaterial = new TextureMaterial( Away3dTextureManager.getTextureById( Away3dTextureType.FRAMES_ATLAS ) );
			_frameMaterial.mipmap = false;
			_frameMaterial.smooth = true;
			_framesAtlasXml = Away3dTextureManager.getAtlasDataById( Away3dTextureType.FRAMES_ATLAS );
			_framesAtlasTextureInfo = Away3dTextureManager.getTextureInfoById( Away3dTextureType.FRAMES_ATLAS );
		}
	}
}
