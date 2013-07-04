package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.materials.lightpickers.StaticLightPicker;

	import br.com.stimuli.loading.BulkLoader;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.home.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.home.views.home.data.FrameType;
	import net.psykosoft.psykopaint2.home.views.home.objects.EaselPainting;
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
		private var _atlasXml:XML;
		private var _easel:FramedPainting;
		private var _pendingEaselContent:PaintingVO;
		private var _lightPicker : LightPickerBase;

		// TODO: make private
		public var homePaintingIndex:int = -1;

		private const FRAME_GAP:Number = 300;

		public function PaintingManager( cameraController:ScrollCameraController, room:WallRoom, view:View3D, lightPicker : LightPickerBase ) {
			super();
			_cameraController = cameraController;
			_room = room;
			_view = view;
			_paintings = new Vector.<FramedPainting>();
			_snapPointForPainting = new Dictionary();
			_shadowForPainting = new Dictionary();
			_lightPicker = lightPicker;
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

		public function setEaselContent( vo : PaintingVO ):void {
			_pendingEaselContent = vo;
			if( _easel ) setEaselPaintingNow();
		}

		private function setEaselPaintingNow():void {
			var painting:EaselPainting = new EaselPainting( _pendingEaselContent, _lightPicker );
			if( CoreSettings.RUNNING_ON_RETINA_DISPLAY ) painting.scale( 0.5 );
			_easel.setPainting( painting );
			_pendingEaselContent = null;
		}

		public function createDefaultPaintings():void {

			// Shared materials.
			_atlasXml = BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getXML( "framesAtlasXml", true );
			_frameMaterial = TextureUtil.getAtfMaterial( HomeView.HOME_BUNDLE_ID, "framesAtlasImage", _view );
			_frameMaterial.mipmap = false;
			_frameMaterial.smooth = true;

			// Settings painting.
			createPaintingAtIndex( BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBitmapData( "settingsPainting", true ), FrameType.DANGER, 0, true, 1.5 );

			// Easel.
			_easel = createPaintingAtIndex( null, null, 1, false );
			_easel.easelVisible = true;
			if( _pendingEaselContent ) setEaselPaintingNow();
			autoPositionPaintingAtIndex( _easel, 1, false, 1 );
			_easel.z -= 750;
			_easel.y -= 150;

			// Home painting.
			createPaintingAtIndex( BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBitmapData( "homePainting", true ), FrameType.WHITE, 2, true, 1.5 );
			homePaintingIndex = 2;

			// Sample paintings. // TODO: remove when we are ready to show published paintings
//			for( var i:uint; i < 7; i++ ) {
//				createPaintingAtIndex( BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBitmapData( "samplePainting" + i, true ), FrameType.BLUE, i + 2 );
//			}
		}

		public function createPaintingAtIndex( paintingBmd:BitmapData, frameType:String, index:uint, addShadow:Boolean, paintingScale:Number = 1 ):FramedPainting {

			trace( this, "creating painting at index: " + index );

			// Painting.
			if( paintingBmd ) {
				var painting:Painting = new Painting( paintingBmd, _view );
			}

			// Frame.
			if( frameType ) {
				var frameDescriptor:FrameTextureAtlasDescriptorVO = new FrameTextureAtlasDescriptorVO( frameType, _atlasXml, 1024, 512 );
				var frame:Frame = new Frame( _frameMaterial, frameDescriptor, painting.width, painting.height );
			}

			// Both.
			var framedPainting:FramedPainting = new FramedPainting( _view );
			framedPainting.scaleX = framedPainting.scaleY = framedPainting.scaleZ = paintingScale;
			if( painting ) {
				framedPainting.setPainting( painting );
			}
			if( frame ) {
				framedPainting.setFrame( frame );
			}

			// Add to display, store, and position.
			var numPaintings:uint = _paintings.length;
			if( index < numPaintings ) _paintings.splice( index, 0, framedPainting );
			else _paintings.push( framedPainting );
			numPaintings++;
			addChild( framedPainting );
			autoPositionPaintingAtIndex( framedPainting, index, addShadow, paintingScale );

			// Need to update paintings to the right of this one?
			if( index < numPaintings - 1 ) {
				trace( this, "repositioning higher paintings..." );
				for( var i:uint = index + 1; i < numPaintings; i++ ) {
					autoPositionPaintingAtIndex( _paintings[ i ], i, addShadow, paintingScale );
				}
			}

			return framedPainting;
		}

		private function autoPositionPaintingAtIndex( framedPainting:FramedPainting, index:uint, addShadow:Boolean, paintingScale:Number = 1 ):void {

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
				trace( this, "reusing snap point: " + index );
				_cameraController.positionManager.updateSnapPointAtIndex( index, px );
			}
			else {
				trace( this, "pushing snap point: " + index );
				_cameraController.positionManager.pushSnapPoint( px );
			}
			_snapPointForPainting[ framedPainting ] = px;

			// Create or update shadow.
			var shadow:Mesh = _shadowForPainting[ framedPainting ];
			if( shadow ) {
				shadow.x = px;
				shadow.scaleX = shadow.scaleY = shadow.scaleZ = ( paintingScale );
			}
			else {
				if( addShadow ) {
					shadow = _room.addShadow( framedPainting.x, this.y, framedPainting.width, framedPainting.height );
					shadow.scaleX = shadow.scaleY = shadow.scaleZ = ( paintingScale );
				}
			}
		}

		private function removePaintingAtIndex( index:uint ):void {
			// TODO... remove painting, remove shadow, remove snap point
		}

		public function get easel():FramedPainting {
			return _easel;
		}
	}
}
