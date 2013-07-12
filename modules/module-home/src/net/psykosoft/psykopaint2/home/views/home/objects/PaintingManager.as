package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.lightpickers.LightPickerBase;

	import br.com.stimuli.loading.BulkLoader;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.home.controller.ScrollCameraController;

	public class PaintingManager extends ObjectContainer3D
	{
		private var _paintings:Vector.<GalleryPainting>;
		private var _cameraController:ScrollCameraController;
		private var _room:Room;
		private var _view:View3D;
		private var _snapPointForPainting:Dictionary;
		private var _shadowForPainting:Dictionary;
		private var _easel:Easel;
		private var _lightPicker : LightPickerBase;
		private var _stage3dProxy:Stage3DProxy;

		// TODO: make private
		public var homePaintingIndex:int = -1;

		private const FRAME_GAP:Number = 300;

		public function PaintingManager( cameraController:ScrollCameraController, room:Room, view:View3D, lightPicker:LightPickerBase, stage3dProxy:Stage3DProxy ) {
			super();
			_cameraController = cameraController;
			_room = room;
			_view = view;
			_paintings = new Vector.<GalleryPainting>();
			_snapPointForPainting = new Dictionary();
			_shadowForPainting = new Dictionary();
			_lightPicker = lightPicker;
			_stage3dProxy = stage3dProxy;
			_easel = new Easel( _view, _lightPicker );
		}

		override public function dispose():void {

			trace( "dispose()" );

			for( var i:uint; i < _paintings.length; i++ ) {
				var frame:GalleryPainting = _paintings[ i ];
				frame.dispose();
				frame = null;
			}
			_paintings = null;

//			_framesTexture.dispose();
//			_framesTexture = null;
//			_frameMaterial.dispose();
//			_frameMaterial = null;

			super.dispose();
		}

		public function setEaselContent( vo : PaintingInfoVO ):void {
			_easel.setContent(vo);
		}

		public function createDefaultPaintings():void {

			// Settings painting.
			createPaintingAtIndex( BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBitmapData( "settingsPainting", true ), null, 0, 1.5 );

			// Easel.
			addPaintingAt(1, _easel);

			_easel.easelVisible = true;
			autoPositionPaintingAtIndex( _easel, 1 );
			_easel.z -= 750;
			_easel.y -= 150;

			// Home painting.
			createPaintingAtIndex( BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBitmapData( "homePainting", true ), null, 2, 1.5 );
			homePaintingIndex = 2;

			// Sample paintings. // TODO: remove when we are ready to show published paintings
//			for( var i:uint; i < 7; i++ ) {
//				createPaintingAtIndex( BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBitmapData( "samplePainting" + i, true ), FrameType.BLUE, i + 2 );
//			}
		}

		public function createPaintingAtIndex( paintingBmd:BitmapData, frameBmd:BitmapData, index:uint, paintingScale:Number = 1 ):FramedPainting {

			trace( this, "creating painting at index: " + index );

			// Painting and frame.
			var framedPainting:FramedPainting = new FramedPainting( _view );
			framedPainting.scaleX = framedPainting.scaleY = framedPainting.scaleZ = paintingScale;
			if( paintingBmd ) {
				framedPainting.setPaintingBitmapData( paintingBmd, _stage3dProxy );
			}
			if( frameBmd ) {
				framedPainting.setFrameBitmapData( frameBmd, _stage3dProxy );
			}

			addPaintingAt(index, framedPainting);

			return framedPainting;
		}

		private function addPaintingAt(index : uint, painting : GalleryPainting) : void
		{
// Add to display, store, and position.
			var numPaintings : uint = _paintings.length;
			if (index < numPaintings) _paintings.splice(index, 0, painting);
			else _paintings.push(painting);
			numPaintings++;
			addChild(painting);
			autoPositionPaintingAtIndex(painting, index);

			// Need to update paintings to the right of this one?
			if (index < numPaintings - 1) {
				for (var i : uint = index + 1; i < numPaintings; i++) {
					autoPositionPaintingAtIndex(_paintings[ i ], i);
				}
			}
		}

		public function getPaintingAtIndex( index:uint ):GalleryPainting {
			return _paintings[ index ];
		}

		private function autoPositionPaintingAtIndex( framedPainting:GalleryPainting, index:uint ):void {

			// Position painting.
			var px:Number = 0;
			if( index == 0 ) {
				px = framedPainting.width / 2;
			}
			else {
				var previousPainting:GalleryPainting = _paintings[ index - 1 ];
				px = previousPainting.x + previousPainting.width / 2 + FRAME_GAP + framedPainting.width / 2;
			}
			framedPainting.x = px;
			framedPainting.z = -50;

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
		}

		private function removePaintingAtIndex( index:uint ):void {
			// TODO... remove painting, remove shadow, remove snap point
		}

		public function get easel():Easel {
			return _easel;
		}
	}
}
