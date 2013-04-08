package net.psykosoft.psykopaint2.app.view.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.geom.Point;

	import net.psykosoft.psykopaint2.app.utils.loaders.AtlasLoader;

	import net.psykosoft.psykopaint2.app.utils.loaders.BitmapLoader;
	import net.psykosoft.psykopaint2.app.utils.DisplayContextManager;
	import net.psykosoft.psykopaint2.app.utils.loaders.XMLLoader;
	import net.psykosoft.psykopaint2.app.view.home.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.app.view.home.vos.FrameTextureAtlasDescriptorVO;

	public class PictureFrameContainer extends ObjectContainer3D
	{
		private var _easel:Easel;
		private var _positioningOffset:uint;
		private var _frameMaterial:TextureMaterial;
		private var _wallFrames:Vector.<PictureFrame>;
		private var _cameraController:ScrollCameraController;
		private var _room:Room;
		private var _atlasXml:XML;
		private var _framesTexture:BitmapTexture;
		private var _atlasLoader:AtlasLoader;

		private const FRAME_GAP_X:Number = 500;
		private const PAINTINGS_SCALE:Number = 0.9;

		public function PictureFrameContainer( cameraController:ScrollCameraController, room:Room ) {
			super();
			_cameraController = cameraController;
			_room = room;
		}

		override public function dispose():void {

			trace( this, "dispose()" );

			if( _atlasLoader ) {
				_atlasLoader.dispose();
				_atlasLoader = null;
			}

			for( var i:uint; i < _wallFrames.length; i++ ) {
				var frame:PictureFrame = _wallFrames[ i ];
				frame.dispose();
				frame = null;
			}
			_wallFrames = null;

			if( _atlasXml ) {
				_atlasXml = null;
			}

			_framesTexture.dispose();
			_framesTexture = null;
			_frameMaterial.dispose();
			_frameMaterial = null;

			if( _easel ) {
				_easel.dispose();
				_easel = null;
			}

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

			// Initialize loader.
			_atlasLoader = new AtlasLoader();

			// Start by loading the frame's material atlas.
			loadFrameAtlas();
		}

		private function loadFrameAtlas():void {
			_atlasLoader.loadAsset( "/assets-packaged/away3d/frames/frames.png", "/assets-packaged/away3d/frames/frames.xml", onFramesAtlasReady );
		}

		private function onFramesAtlasReady( bmd:BitmapData, descriptor:XML ):void {

			// Texture.
			_framesTexture = new BitmapTexture( bmd );
			_framesTexture.getTextureForStage3D( DisplayContextManager.stage3dProxy );
			_framesTexture.name = "framesTexture";
			bmd.dispose();

			// Material.
			_frameMaterial = new TextureMaterial( _framesTexture );
			_frameMaterial.mipmap = false;
			_frameMaterial.smooth = true;

			// Descriptor.
			_atlasXml = descriptor;

			// Dispose loader.
			_atlasLoader.dispose();
			_atlasLoader = null;

			// Continue.
			buildDefaultFrames();
		}

		private function buildDefaultFrames():void {

			// -----------------------
			// Settings frame.
			// -----------------------

			// Picture.
			var settingsPicture:Picture = new Picture( new BitmapData( 512, 512, false, 0 ), new Point( 512, 512 ), new Point( 512, 512 ) );
			settingsPicture.scalePainting( 2 );

			// Frame.
			var settingsFrameAtlasDescriptor:FrameTextureAtlasDescriptorVO = new FrameTextureAtlasDescriptorVO(
					"dangerFrame",
					_atlasXml,
					_framesTexture.width, _framesTexture.height
			);
			var settingsFrame:PictureFrame = new PictureFrame( settingsPicture, _frameMaterial, settingsFrameAtlasDescriptor );
			addPictureFrame( settingsFrame );

			/*// -----------------------
			// Easel.
			// -----------------------

			_easel = new Easel();

			var previousFrame:PictureFrame = _wallFrames[ _wallFrames.length - 1 ];
			_easel.x = previousFrame.x + previousFrame.width / 2 + FRAME_GAP_X + _easel.width / 2;

			_cameraController.addSnapPoint( _easel.x );

			_positioningOffset += _easel.x;

			addChild( _easel );*/

			// -----------------------
			// Psykopaint frame.
			// -----------------------

			// Picture.
			var psykopaintPicture:Picture = new Picture( new BitmapData( 512, 512, false, 0 ), new Point( 512, 512 ), new Point( 512, 512 ) );
			psykopaintPicture.scalePainting( 2 );

			// Frame.
			var psykopaintFrameAtlasDescriptor:FrameTextureAtlasDescriptorVO = new FrameTextureAtlasDescriptorVO(
					"whiteFrame",
					_atlasXml,
					_framesTexture.width, _framesTexture.height
			);
			var psykopaintFrame:PictureFrame = new PictureFrame( psykopaintPicture, _frameMaterial, psykopaintFrameAtlasDescriptor );
			addPictureFrame( psykopaintFrame );

			_atlasXml = null;

			// Initial frame.
			_cameraController.jumpToSnapPoint( 0 );

		}
	}
}
