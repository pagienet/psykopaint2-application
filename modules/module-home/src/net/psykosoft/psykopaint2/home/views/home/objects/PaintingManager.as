package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.textures.BitmapTexture;

	import br.com.stimuli.loading.BulkLoader;

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.core.views.splash.SplashView;
	import net.psykosoft.psykopaint2.home.assets.HomeEmbeddedAssets;
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

		override public function dispose():void {

			trace( "dispose()" );

			// Remove all paintings ( includes easel ).
			for( var i:uint; i < _paintings.length; i++ ) {
				var painting:GalleryPainting = _paintings[ i ];
				removeChild( painting );
				painting.dispose();
				painting = null;
			}
			_paintings = null;

			// Remove settings panel.
			removeChild( _settingsPanel );
			var tex:BitmapTexture = BitmapTexture( TextureMaterial( _settingsPanel.material ).texture );
			_settingsPanel.material.dispose();
			tex.dispose();
			_settingsPanel.geometry.dispose();
			_settingsPanel.dispose();
			_settingsPanel = null;

			// Clear other variables.
			_shadowForPainting = null;

			// Forget references.
			_view = null;
			_cameraController = null;
			_room = null;
			_lightPicker = null;

			super.dispose();
		}

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

		public function createDefaultPaintings():void {

//			trace( this, "creating paintings..." );
//			var time:uint;

			// -----------------------
			// Settings painting.
			// -----------------------

//			time = getTimer();

			// Painting.
			var settingsBmd:BitmapData = new HomeEmbeddedAssets.instance.SettingsPainting().bitmapData;
			var settingsPainting:GalleryPainting = createPainting(
					settingsBmd,
					null
			);
			settingsPainting.x = 0;
			settingsPainting.z = -50;
			settingsPainting.scale( 1.5 );
			addPainting( settingsPainting );

//			trace( this, "time taken to create settings painting: " + String( getTimer() - time ) );
//			time = getTimer();

			// Sign.
			var settingsPanelBmd:BitmapData = new HomeEmbeddedAssets.instance.SettingsPanel().bitmapData;
			_settingsPanel = TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage(
					settingsPanelBmd,
					_stage3dProxy,
					true
			);
			_settingsPanel.x = settingsPainting.x;
			_settingsPanel.y = 600;
			_settingsPanel.z = -250;
			_settingsPanel.rotationX = -90;
			addChild( _settingsPanel );

//			trace( this, "time taken to create settings sign: " + String( getTimer() - time ) );

			// -----------------------
			// Easel.
			// -----------------------

//			time = getTimer();

			_easel.easelVisible = true;
			_easel.scale( 1.5 );
			_easel.x = 2000;
			_easel.z = -750;
			_easel.y = -75;
			addPainting( _easel );

//			trace( this, "time taken to create easel: " + String( getTimer() - time ) );

			// -----------------------
			// Home painting.
			// -----------------------

//			time = getTimer();

			var whiteFrameBmd:BitmapData = new HomeEmbeddedAssets.instance.WhiteFrame().bitmapData;
			var frameOffset:Point = FrameOffsets.getOffsetForFrameType( FrameType.WHITE_FRAME );
			var homePainting:GalleryPainting = createPainting(
					new SplashView.SplashImageAsset().bitmapData,
					whiteFrameBmd,
					frameOffset.x, frameOffset.y
			);
			homePainting.scale( 0.65 );
			homePainting.y += 20;
			homePainting.x = 4000;
			homePainting.z = -50;
			homePaintingIndex = 2;
			addPainting( homePainting );

//			trace( this, "time taken to create home painting: " + String( getTimer() - time ) );
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
