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
		private var _paintings:Vector.<FramedPainting>;
		private var _cameraController:ScrollCameraController;
		private var _room:Room;
		private var _view:View3D;
		private var _snapPointForPainting:Dictionary;
		private var _shadowForPainting:Dictionary;
		private var _easel:FramedPainting;
		private var _pendingEaselContent:PaintingInfoVO;
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
			_paintings = new Vector.<FramedPainting>();
			_snapPointForPainting = new Dictionary();
			_shadowForPainting = new Dictionary();
			_lightPicker = lightPicker;
			_stage3dProxy = stage3dProxy;
		}

		override public function dispose():void {

			trace( "dispose()" );

			for( var i:uint; i < _paintings.length; i++ ) {
				var frame:FramedPainting = _paintings[ i ];
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
			_pendingEaselContent = vo? vo.clone() : null;
			if( _easel ) setEaselPaintingNow();
		}

		private function setEaselPaintingNow():void {
			if (_pendingEaselContent) {
				var painting:EaselPainting = new EaselPainting( _pendingEaselContent, _lightPicker, _view );
				if( CoreSettings.RUNNING_ON_RETINA_DISPLAY ) painting.scale( 0.5 );
				_easel.setPainting( painting );
				_pendingEaselContent.dispose();
				_pendingEaselContent = null;
			}
			else {
				_easel.setPainting(null);
			}
		}

		public function createDefaultPaintings():void {

			// Settings painting.
			createPaintingAtIndex( BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBitmapData( "settingsPainting", true ), null, 0, 1.5 );

			// Easel.
			_easel = createPaintingAtIndex( null, null, 1 );
			_easel.easelVisible = true;
			if( _pendingEaselContent ) setEaselPaintingNow();
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
				framedPainting.setPaintingBmd( paintingBmd, _stage3dProxy );
			}
			if( frameBmd ) {
				framedPainting.setFrameBmd( frameBmd, _stage3dProxy );
			}

			// Add to display, store, and position.
			var numPaintings:uint = _paintings.length;
			if( index < numPaintings ) _paintings.splice( index, 0, framedPainting );
			else _paintings.push( framedPainting );
			numPaintings++;
			addChild( framedPainting );
			autoPositionPaintingAtIndex( framedPainting, index );

			// Need to update paintings to the right of this one?
			if( index < numPaintings - 1 ) {
				for( var i:uint = index + 1; i < numPaintings; i++ ) {
					autoPositionPaintingAtIndex( _paintings[ i ], i );
				}
			}

			return framedPainting;
		}

		public function getPaintingAtIndex( index:uint ):FramedPainting {
			return _paintings[ index ];
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

		public function get easel():FramedPainting {
			return _easel;
		}
	}
}
