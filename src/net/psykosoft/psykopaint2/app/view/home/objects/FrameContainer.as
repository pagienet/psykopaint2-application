package net.psykosoft.psykopaint2.app.view.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.geom.Point;

	import net.psykosoft.psykopaint2.app.utils.BitmapLoader;
	import net.psykosoft.psykopaint2.app.utils.XMLLoader;
	import net.psykosoft.psykopaint2.app.view.home.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.app.view.home.vos.FrameTextureAtlasDescriptorVO;

	public class FrameContainer extends ObjectContainer3D
	{
		private var _easel:Easel;
		private var _positioningOffset:uint;
		private var _frameMaterial:TextureMaterial;
		private var _wallFrames:Vector.<PictureFrame>;
		private var _cameraController:ScrollCameraController;
		private var _room:Room;

		private var _framesTexture:BitmapTexture;
		private var _bitmapLoader:BitmapLoader;
		private var _xmlLoader:XMLLoader;
		private var _framesDescriptor:XML;

		private const FRAME_GAP_X:Number = 500;
		private const PAINTINGS_SCALE:Number = 0.9;

		public function FrameContainer( cameraController:ScrollCameraController, room:Room ) {
			super();
			_cameraController = cameraController;
			_room = room;
		}

		override public function dispose():void {

			trace( this, "dispose()" );

			for( var i:uint; i < _wallFrames.length; i++ ) {
				var frame:PictureFrame = _wallFrames[ i ];
				frame.dispose();
			}
			_wallFrames = null;

			if( _bitmapLoader ) {
				_bitmapLoader.dispose();
				_bitmapLoader = null;
			}

			if( _xmlLoader ) {
				_xmlLoader.dispose();
				_xmlLoader = null;
			}

			if( _framesDescriptor ) {
				_framesDescriptor = null;
			}

			_framesTexture.dispose();
			_framesTexture = null;
			_frameMaterial.dispose();
			_frameMaterial = null;

			_easel.dispose();
			_easel = null;

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

			// Initialize loaders.
			_bitmapLoader = new BitmapLoader();
			_xmlLoader = new XMLLoader();

			// Start by loading the frame's material atlas.
			loadFrameAtlasImage();
		}

		private function loadFrameAtlasImage():void {
			_bitmapLoader.loadAsset( "away3d/frames/frames.png", onFramesAtlasImageReady );
		}

		private function onFramesAtlasImageReady( bmd:BitmapData ):void {

			// Texture.
			_framesTexture = new BitmapTexture( bmd );
			bmd.dispose();

			// Material.
			_frameMaterial = new TextureMaterial( _framesTexture );
			_frameMaterial.mipmap = false;
			_frameMaterial.smooth = true;

			// Dispose bitmap loader.
			_bitmapLoader.dispose();
			_bitmapLoader = null;

			// Continue.
			loadFrameAtlasDescriptor();
		}

		private function loadFrameAtlasDescriptor():void {
			_xmlLoader.loadAsset( "away3d/frames/frames.xml", onFramesAtlasDescriptorReady );
		}

		private function onFramesAtlasDescriptorReady( xml:XML ):void {

			// Dispose xml loader.
			_framesDescriptor = xml;
			_xmlLoader.dispose();

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
					"whiteDanger",
					_framesDescriptor,
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
					"frameWhite",
					_framesDescriptor,
					_framesTexture.width, _framesTexture.height
			);
			var psykopaintFrame:PictureFrame = new PictureFrame( psykopaintPicture, _frameMaterial, psykopaintFrameAtlasDescriptor );
			addPictureFrame( psykopaintFrame );

			_framesDescriptor = null;

			// Starts looking at the psykopaint frame.
			_cameraController.jumpToSnapPoint( 2 );

		}
	}
}
