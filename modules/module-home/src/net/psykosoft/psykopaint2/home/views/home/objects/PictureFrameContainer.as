package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;

	import br.com.stimuli.loading.BulkLoader;

	import flash.display.BitmapData;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.home.views.home.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.home.views.home.vos.FrameTextureAtlasDescriptorVO;

	public class PictureFrameContainer extends ObjectContainer3D
	{
		private var _easel:Easel;
		private var _positioningOffset:uint;
		private var _frameMaterial:TextureMaterial;
		private var _wallFrames:Vector.<PictureFrame>;
		private var _cameraController:ScrollCameraController;
		private var _room:Room;
		private var _view:View3D;

		private var _framesTexture:BitmapTexture;
		private var _atlasXml:XML;

		private const FRAME_GAP_X:Number = 500;
		private const PAINTINGS_SCALE:Number = 0.9;

		public function PictureFrameContainer( cameraController:ScrollCameraController, room:Room, view:View3D ) {
			super();
			_cameraController = cameraController;
			_room = room;
			_view = view;
		}

		override public function dispose():void {

			trace( "dispose()" );

			for( var i:uint; i < _wallFrames.length; i++ ) {
				var frame:PictureFrame = _wallFrames[ i ];
				frame.dispose();
				frame = null;
			}
			_wallFrames = null;

			if( _atlasXml ) {
				_atlasXml = null;
			}

//			_framesTexture.dispose();
//			_framesTexture = null;
//			_frameMaterial.dispose();
//			_frameMaterial = null;

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
			pictureFrame.x = _positioningOffset + pictureFrame.width / 2;
			pictureFrame.z = -pictureFrame.depth / 2;
			pictureFrame.scale( PAINTINGS_SCALE );
			_positioningOffset = pictureFrame.x + pictureFrame.width / 2 + FRAME_GAP_X;
			_cameraController.addSnapPoint( pictureFrame.x );
			_wallFrames.push( pictureFrame );
			addChild( pictureFrame );

			// Create shadow.
			_room.addShadow( pictureFrame.x, this.y, pictureFrame.width, pictureFrame.height );
		}

		public function loadDefaultHomeFrames():void {

			// Retrieve frames atlas texture.
			var bmd:BitmapData = BulkLoader.getLoader( "homeView" ).getBitmapData( "framesAtlasImage", true );
			_framesTexture = new BitmapTexture( bmd );
			_framesTexture.getTextureForStage3D( _view.stage3DProxy ); // Force generation before bmd disposal.
			bmd.dispose();

			// Retrieve frames atlas descriptor.
			_atlasXml = BulkLoader.getLoader( "homeView" ).getXML( "framesAtlasXml", true );

			// Material.
			_frameMaterial = new TextureMaterial( _framesTexture );
			_frameMaterial.mipmap = false;
			_frameMaterial.smooth = true;

			buildDefaultFrames();
		}

		private function buildDefaultFrames():void {

			// -----------------------
			// Settings frame.
			// -----------------------

			// Picture.
			var settingsPicture:Picture = new Picture( BulkLoader.getLoader( "homeView" ).getBitmapData( "settingsPainting", true ), _view );
			settingsPicture.scalePainting( 2 );

			// Frame.
			var settingsFrameAtlasDescriptor:FrameTextureAtlasDescriptorVO = new FrameTextureAtlasDescriptorVO(
					"dangerFrame",
					_atlasXml,
					_framesTexture.width, _framesTexture.height
			);
			var settingsFrame:PictureFrame = new PictureFrame( settingsPicture, _frameMaterial, settingsFrameAtlasDescriptor );
			addPictureFrame( settingsFrame );

			// -----------------------
			// Easel.
			// -----------------------

			var squeeze:Number = 0.25;

			var initEaselPic:BitmapData = new BitmapData( 1024, 768, false, 0xCCCCCC );
			_easel = new Easel( initEaselPic, _view );

			_easel.x = _positioningOffset + squeeze * _easel.width / 2;
			_easel.y = -300;
			_easel.z = -600;

			_cameraController.addSnapPoint( _easel.x );

			_positioningOffset = _easel.x + squeeze * _easel.width / 2 + FRAME_GAP_X;

			addChild( _easel );

			// -----------------------
			// Psykopaint frame.
			// -----------------------

			// Picture.
			var psykopaintPicture:Picture = new Picture( BulkLoader.getLoader( "homeView" ).getBitmapData( "homePainting", true ), _view );
			psykopaintPicture.scalePainting( 2 );

			// Frame.
			var psykopaintFrameAtlasDescriptor:FrameTextureAtlasDescriptorVO = new FrameTextureAtlasDescriptorVO(
					"whiteFrame",
					_atlasXml,
					_framesTexture.width, _framesTexture.height
			);
			var psykopaintFrame:PictureFrame = new PictureFrame( psykopaintPicture, _frameMaterial, psykopaintFrameAtlasDescriptor );
			addPictureFrame( psykopaintFrame );

			// -----------------------
			// Sample paintings.
			// -----------------------

			var availableFrames:Array = [ "blueFrame", "goldFrame", "whiteFrame", "dangerFrame" ];
			for( var i:uint; i < 7; i++ ) {

				// Picture.
				var picture:Picture = new Picture( BulkLoader.getLoader( "homeView" ).getBitmapData( "samplePainting" + i, true ), _view );

				// Frame.
				var descriptor:FrameTextureAtlasDescriptorVO = new FrameTextureAtlasDescriptorVO(
						availableFrames[ Math.floor( availableFrames.length * Math.random() ) ],
						_atlasXml,
						_framesTexture.width, _framesTexture.height
				);
				var frame:PictureFrame = new PictureFrame( picture, _frameMaterial, descriptor );
				addPictureFrame( frame );
			}

			// Clear.
			_atlasXml = null;

			// Initial frame.
			_cameraController.jumpToSnapPointIndex( 2 );

		}

		public function updateEasel( bmd:BitmapData ):void {
			_easel.updateImage( bmd );
		}
	}
}
