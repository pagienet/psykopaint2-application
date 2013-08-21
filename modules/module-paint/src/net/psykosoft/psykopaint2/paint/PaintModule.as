package net.psykosoft.psykopaint2.paint
{

	import flash.display.BitmapData;
	import flash.display.Stage3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.data.ByteArrayUtil;

	import net.psykosoft.psykopaint2.base.utils.data.ByteArrayUtil;
	import net.psykosoft.psykopaint2.base.utils.io.BinaryLoader;
	import net.psykosoft.psykopaint2.base.utils.io.BitmapLoader;
	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.model.LightingModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.rendering.AmbientEnvMapModel;
	import net.psykosoft.psykopaint2.core.rendering.AmbientOccludedEnvMapModel;
	import net.psykosoft.psykopaint2.core.rendering.AmbientOccludedModel;
	import net.psykosoft.psykopaint2.core.rendering.AmbientOffsetEnvMapModel;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.paint.configuration.PaintConfig;
	import net.psykosoft.psykopaint2.paint.configuration.PaintSettings;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleSetUpSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestDestroyPaintModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetupPaintModuleSignal;

	[SWF(width=1024, height=768, frameRate=60)]
	public class PaintModule extends ModuleBase
	{
		private var _coreModule:CoreModule;
		private var _moduleSetUp : Boolean = true;
		private var _byteLoader : BinaryLoader;
		private var _bitmapLoader : BitmapLoader;

		public function PaintModule( core:CoreModule = null ) {
			super();
			_coreModule = core;
			if( CoreSettings.NAME == "" ) CoreSettings.NAME = "PaintModule";
			if( !_coreModule ) {
				addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			}
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			initialize();
		}

		// ---------------------------------------------------------------------
		// Initialization.
		// ---------------------------------------------------------------------

		public function initialize():void {
			trace( this, "initializing..." );
			// Init core module.
			if( !_coreModule )
				initStandalone();
			else {
				PaintSettings.isStandalone = false;
				init();
			}
		}

		private function onCoreModuleReady():void {

			init();
			_coreModule.injector.getInstance(RequestHideSplashScreenSignal).dispatch();
			_coreModule.startEnterFrame();
			setupStandaloneModule();
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		private function onKeyUp(event : KeyboardEvent) : void
		{
			if (event.keyCode == Keyboard.F4) {
				_moduleSetUp = !_moduleSetUp;
				if (_moduleSetUp)
					setupStandaloneModule();
				else
					destroyStandaloneModule();
			}
			else if (event.keyCode == Keyboard.SPACE) {
				var model : LightingModel = _coreModule.injector.getInstance(LightingModel);
				if (model.diffuseStrength == 1) {
					model.diffuseStrength = 0;
					model.specularStrength = 0;
					model.ambientColor = 0xffffff
				}
				else {
					model.diffuseStrength = 1;
					model.specularStrength = 1;
					model.ambientColor = 0x808088;
				}
			}
		}

		private function setupStandaloneModule() : void
		{
			graphics.clear();

			_bitmapLoader = new BitmapLoader();
			_bitmapLoader.loadAsset("/paint-packaged/environments/cornellEnvMap.png", onEnvMapLoaded);
		}

		private function onEnvMapLoaded(bitmapData : BitmapData) : void
		{
			var texture : Texture = Stage3D(_coreModule.injector.getInstance(Stage3D)).context3D.createTexture(bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false);
			texture.uploadFromBitmapData(bitmapData);
			var model : LightingModel = _coreModule.injector.getInstance(LightingModel);
			/*{
				model.ambientModel = new AmbientEnvMapModel();
				model.environmentMap = texture;
				model.ambientColor = 0xaaaaaa;
			}*/
			/*{
				model.useCamera = true;
				model.ambientModel = new AmbientOffsetEnvMapModel();
				model.ambientColor = 0xaaaaaa;
			}*/
			/*{
				model.ambientModel = new AmbientOccludedEnvMapModel();
				model.environmentMap = texture;
				model.ambientColor = 0xaaaaaa;
			} */
			{
				model.ambientModel = new AmbientOccludedModel();
				model.ambientColor = 0x808088;
			}
//			model.diffuseStrength = .7;
//			model.specularStrength = 1;
//			model.surfaceBumpiness = 100;
			_byteLoader = new BinaryLoader();
			_byteLoader.loadAsset( "/core-packaged/images/surfaces/canvas_normal_specular_0_1024.surf", onSurfaceLoaded );
		}

		private function onSurfaceLoaded(bytes:ByteArray) : void
		{
			bytes.uncompress();
			var paintingDataVO : PaintingDataVO = new PaintingDataVO();
			paintingDataVO.width = CoreSettings.STAGE_WIDTH;
			paintingDataVO.height = CoreSettings.STAGE_HEIGHT;
			paintingDataVO.colorData = ByteArrayUtil.createBlankColorData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, 0x00000000);
			paintingDataVO.sourceBitmapData = null;
			paintingDataVO.normalSpecularData = bytes;
			paintingDataVO.normalSpecularOriginal = bytes;

			_coreModule.injector.getInstance(RequestNavigationStateChangeSignal).dispatch(NavigationStateType.PREPARE_FOR_PAINT_MODE);
			_coreModule.injector.getInstance(NotifyPaintModuleSetUpSignal).addOnce(onPaintingModuleSetUp);
			_coreModule.injector.getInstance(RequestSetupPaintModuleSignal).dispatch((paintingDataVO));
		}

		private function destroyStandaloneModule() : void
		{
			graphics.beginFill(0xffffff);
			graphics.drawRect(0, 0, 500, 500);
			graphics.endFill();
			_coreModule.injector.getInstance(RequestDestroyPaintModuleSignal).dispatch();
			_coreModule.injector.getInstance(RequestNavigationStateChangeSignal).dispatch(NavigationStateType.HOME_ON_EASEL);
		}

		private function onPaintingModuleSetUp() : void
		{
			_coreModule.injector.getInstance(RequestNavigationStateChangeSignal).dispatch(NavigationStateType.PAINT_SELECT_BRUSH);
		}

		private function initStandalone() : void
		{
			PaintSettings.isStandalone = true;
			_coreModule = new CoreModule();
			_coreModule.isStandalone = false;
			_coreModule.moduleReadySignal.addOnce(onCoreModuleReady);
			addChild(_coreModule);
		}

		private function init() : void
		{
			// Initialize robotlegs for this module.
			new PaintConfig(_coreModule.injector);

			// Notify potential super modules.
			moduleReadySignal.dispatch();
		}
	}
}
