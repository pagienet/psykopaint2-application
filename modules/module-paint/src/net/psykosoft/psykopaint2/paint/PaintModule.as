package net.psykosoft.psykopaint2.paint
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import net.psykosoft.psykopaint2.base.utils.data.ByteArrayUtil;
	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.paint.configuration.PaintConfig;
	import net.psykosoft.psykopaint2.paint.configuration.PaintSettings;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleSetUpSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestDestroyPaintModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetupPaintModuleSignal;
	
	public class PaintModule extends ModuleBase
	{
		private var _coreModule:CoreModule;
		private var _moduleSetUp : Boolean = true;
		
		[Embed(source="dummy.jpg", mimeType="image/jpg")]
		protected var DummyImage:Class;
		
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
			if ( !CoreSettings.RUNNING_ON_iPAD ) stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		private function onKeyUp(event : KeyboardEvent) : void
		{
			if (event.keyCode != Keyboard.F4) return;
			_moduleSetUp = !_moduleSetUp;
			if (_moduleSetUp)
				setupStandaloneModule();
			else
				destroyStandaloneModule();
		}

		private function setupStandaloneModule() : void
		{
			graphics.clear();

			var paintingDataVO : PaintingDataVO = new PaintingDataVO();
			paintingDataVO.width = CoreSettings.STAGE_WIDTH;
			paintingDataVO.height = CoreSettings.STAGE_HEIGHT;
			paintingDataVO.colorData = ByteArrayUtil.createBlankColorData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, 0x00000000);
			
			var tempData:BitmapData = (new DummyImage() as Bitmap).bitmapData;
			//var tempData : BitmapData = new TrackedBitmapData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, false);
		//	tempData.perlinNoise(64, 64, 8, 50, true, true);
			paintingDataVO.sourceImageData =  tempData.getPixels(tempData.rect); //ByteArrayUtil.createBlankColorData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, 0xffffffff);
			//paintingDataVO.sourceImageData = null;
			paintingDataVO.normalSpecularData = ByteArrayUtil.createBlankColorData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, 0x80808080);
			paintingDataVO.normalSpecularOriginal = new BitmapData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, false, 0x808080);
			tempData.dispose();

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
