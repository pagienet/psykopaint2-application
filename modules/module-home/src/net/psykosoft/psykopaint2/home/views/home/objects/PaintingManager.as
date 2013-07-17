package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.materials.lightpickers.LightPickerBase;

	import br.com.stimuli.loading.BulkLoader;

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.views.base.CoreRootView;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.home.camera.HScrollCameraController;

	public class PaintingManager extends ObjectContainer3D
	{
		private var _paintings:Vector.<GalleryPainting>;
		private var _cameraController:HScrollCameraController;
		private var _room:Room;
		private var _view:View3D;
		private var _shadowForPainting:Dictionary;
		private var _easel:Easel;
		private var _lightPicker:LightPickerBase;
		private var _stage3dProxy:Stage3DProxy;
		private var _settingsPanel:Mesh;

		// TODO: make private
		public var homePaintingIndex:int = -1;

		public function PaintingManager( cameraController:HScrollCameraController, room:Room, view:View3D, lightPicker:LightPickerBase, stage3dProxy:Stage3DProxy ) {
			super();
			_cameraController = cameraController;
			_room = room;
			_view = view;
			_paintings = new Vector.<GalleryPainting>();
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

		public function setEaselContent( vo:PaintingInfoVO ):void {
			_easel.setContent( vo );
		}

		public function createDefaultPaintings():void {

			// -----------------------
			// Settings painting.
			// -----------------------

			// Painting.
			var settingsPainting:GalleryPainting = createPainting(
					BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBitmapData( "settingsPainting", true ),
					null
			);
			settingsPainting.x = 0;
			settingsPainting.z = -50;
			settingsPainting.scale( 1.2 );
			addPainting( settingsPainting );

			// Sign.
			_settingsPanel = TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage(
					BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBitmapData( "settingsPanel", true ),
					_stage3dProxy,
					true
			);
			_settingsPanel.x = settingsPainting.x;
			_settingsPanel.y = 305;
			_settingsPanel.z = -250;
			_settingsPanel.rotationX = -90;
			addChild( _settingsPanel );

			// -----------------------
			// Easel.
			// -----------------------

			_easel.easelVisible = true;
			_easel.scale( 1.35 );
			_easel.x = 1300;
			_easel.z = -250;
			_easel.y = 60;
			addPainting( _easel );

			// -----------------------
			// Home painting.
			// -----------------------

			var frameOffset:Point = FrameOffsets.getOffsetForFrameType( FrameType.WHITE_FRAME );
			var homePainting:GalleryPainting = createPainting(
					new CoreRootView.SplashImageAsset().bitmapData,
					BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBitmapData( FrameType.WHITE_FRAME, true ),
					frameOffset.x, frameOffset.y
			);
			homePainting.scale( 0.55 );
			homePainting.x = 2600;
			homePainting.z = -50;
			homePaintingIndex = 2;
			addPainting( homePainting );
		}

		public function createPainting( paintingBmd:BitmapData, frameBmd:BitmapData, frameOffsetX:Number = 0, frameOffsetY:Number = 0 ):FramedPainting {
			var hasFrame:Boolean = frameBmd != null;
			// TODO: right now, transparency is based on frame presence. This is probably not a safe assumption.
			var framedPainting:FramedPainting = new FramedPainting( _view, hasFrame, true );
			if( paintingBmd ) {
				framedPainting.setPaintingBitmapData( paintingBmd, _stage3dProxy );
			}
			if( hasFrame ) {
				framedPainting.setFrameBitmapData( frameBmd, _stage3dProxy, frameOffsetX, frameOffsetY );
			}
			return framedPainting;
		}

		private function addPainting( painting:GalleryPainting ):void {
			_paintings.push( painting );
			addChild( painting );
			_cameraController.positionManager.pushSnapPoint( painting.x );
		}

		public function getPaintingAtIndex( index:uint ):GalleryPainting {
			return _paintings[ index ];
		}

		public function get easel():Easel {
			return _easel;
		}
	}
}
