package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;

	import br.com.stimuli.loading.BulkLoader;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.home.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.home.views.home.data.FrameType;
	import net.psykosoft.psykopaint2.home.views.home.vos.FrameTextureAtlasDescriptorVO;

	public class PaintingManager extends ObjectContainer3D
	{
		private var _frameMaterial:TextureMaterial;
		private var _paintings:Vector.<FramedPainting>;
		private var _cameraController:ScrollCameraController;
		private var _room:WallRoom;
		private var _view:View3D;
		private var _snapPointForPainting:Dictionary;
		private var _shadowForPainting:Dictionary;
		private var _homePaintingIndex:int = 2;

		private var _atlasXml:XML;

		private const FRAME_GAP:Number = 300;

		public function PaintingManager( cameraController:ScrollCameraController, room:WallRoom, view:View3D ) {
			super();
			_cameraController = cameraController;
			_room = room;
			_view = view;
			_paintings = new Vector.<FramedPainting>();
			_snapPointForPainting = new Dictionary();
			_shadowForPainting = new Dictionary();
		}

		override public function dispose():void {

			trace( "dispose()" );

			for( var i:uint; i < _paintings.length; i++ ) {
				var frame:FramedPainting = _paintings[ i ];
				frame.dispose();
				frame = null;
			}
			_paintings = null;

			if( _atlasXml ) {
				_atlasXml = null;
			}

//			_framesTexture.dispose();
//			_framesTexture = null;
//			_frameMaterial.dispose();
//			_frameMaterial = null;

			super.dispose();
		}

		// ---------------------------------------------------------------------
		// Painting creation.
		// ---------------------------------------------------------------------

		public function createDefaultPaintings():void {

			// Shared materials.
			_atlasXml = BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getXML( "framesAtlasXml", true );
			_frameMaterial = TextureUtil.getAtfMaterial( HomeView.HOME_BUNDLE_ID, "framesAtlasImage", _view );
			_frameMaterial.mipmap = false;
			_frameMaterial.smooth = true;

			// Default paintings.
			createPaintingAtIndex( BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBitmapData( "settingsPainting", true ), FrameType.DANGER, 0 );
			createPaintingAtIndex( new BitmapData( 512, 512, false, 0xFF0000 ), FrameType.EASEL, 1 );
			createPaintingAtIndex( BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBitmapData( "homePainting", true ), FrameType.WHITE, 2 );

			// Sample paintings. // TODO: remove when we are ready to show published paintings
//			for( var i:uint; i < 7; i++ ) {
//				createPaintingAtIndex( BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBitmapData( "samplePainting" + i, true ), FrameType.BLUE, i + 2 );
//			}

			// Go to initial painting.
			_cameraController.jumpToSnapPointIndex( 2 ); // TODO: move outside of method
		}

		public function createPaintingAtIndex( paintingBmd:BitmapData, frameType:String, index:uint ):void {

			// Update indices.
			if( index <= _homePaintingIndex ) _homePaintingIndex++;

			// Painting.
			var painting:Painting = new Painting( paintingBmd, _view );

			// Frame.
			var frameDescriptor:FrameTextureAtlasDescriptorVO = new FrameTextureAtlasDescriptorVO( frameType, _atlasXml, 1024, 512 );
			var frame:Frame = new Frame( _frameMaterial, frameDescriptor, painting.width, painting.height );

			// Both.
			var framedPainting:FramedPainting = new FramedPainting();
			framedPainting.setPainting( painting );
			framedPainting.setFrame( frame );

			// Add to display, store, and position.
			var numPaintings:uint = _paintings.length;
			if( index < numPaintings ) _paintings.splice( index, 0, framedPainting );
			else _paintings.push( framedPainting );
			numPaintings++;
			addChild( framedPainting );
			autoPositionPaintingAtIndex( framedPainting, index );

			// Need to update paintings to the right of this one?
			if( index < numPaintings - 1 ) {
				trace( this, "repositioning higher paintings..." );
				for( var i:uint = index + 1; i < numPaintings; i++ ) {
					autoPositionPaintingAtIndex( _paintings[ i ], i );
				}
			}
		}

		private function autoPositionPaintingAtIndex( framedPainting:FramedPainting, index:uint ):void {

			// Position painting.
			var px:Number = 0;
			if( index == 0 ) {
				px = framedPainting.width / 2;
			}
			else {
				var previousPainting:FramedPainting = _paintings[ index - 1 ];
				px = previousPainting.x + previousPainting.width / 2 + FRAME_GAP + framedPainting.width / 2;
			}
			framedPainting.x = px;
			framedPainting.z = -framedPainting.depth / 2;

			// Create or update snap point.
			var snapPoint:Number = _snapPointForPainting[ framedPainting ];
			if( snapPoint ) {
				_cameraController.positionManager.updateSnapPointAtIndex( index, px );
			}
			else {
				_cameraController.positionManager.pushSnapPoint( px );
			}
			_snapPointForPainting[ framedPainting ] = px;

			// Create or update shadow.
			var shadow:Mesh = _shadowForPainting[ framedPainting ];
			if( shadow ) {
				shadow.x = px;
			}
			else {
				_room.addShadow( framedPainting.x, this.y, framedPainting.width, framedPainting.height );
			}
		}

		private function removePaintingAtIndex( index:uint ):void {
			// TODO... remove painting, remove shadow, remove snap point
		}

		public function getHomePaintingIndex():uint {
			return _homePaintingIndex;
		}
	}
}
