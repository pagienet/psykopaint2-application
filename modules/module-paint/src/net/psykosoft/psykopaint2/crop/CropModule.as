package net.psykosoft.psykopaint2.crop
{

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.configuration.CropConfig;
	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedBitmapData;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.crop.signals.NotifyCropModuleSetUpSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestDestroyCropModuleSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetupCropModuleSignal;
	import net.psykosoft.psykopaint2.crop.views.base.CropRootView;
	import net.psykosoft.psykopaint2.paint.configuration.PaintSettings;

	public class CropModule extends ModuleBase
	{
		private var _coreModule:CoreModule;
		private var _moduleSetUp : Boolean = true;

		public function CropModule( core:CoreModule = null ) {
			super();
			_coreModule = core;
			if( CoreSettings.NAME == "" ) CoreSettings.NAME = "CropModule";
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

			var tempData : BitmapData = new RefCountedBitmapData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, false);

			_coreModule.injector.getInstance(RequestNavigationStateChangeSignal).dispatch(NavigationStateType.HOME_ON_EASEL);
			_coreModule.injector.getInstance(NotifyCropModuleSetUpSignal).addOnce(onCropModuleSetUp);
			_coreModule.injector.getInstance(RequestSetupCropModuleSignal).dispatch(tempData);
		}

		private function destroyStandaloneModule() : void
		{
			graphics.beginFill(0xffffff);
			graphics.drawRect(0, 0, 500, 500);
			graphics.endFill();
			_coreModule.injector.getInstance(RequestDestroyCropModuleSignal).dispatch();
			_coreModule.injector.getInstance(RequestNavigationStateChangeSignal).dispatch(NavigationStateType.HOME_ON_EASEL);
		}

		private function onCropModuleSetUp() : void
		{
			_coreModule.injector.getInstance(RequestNavigationStateChangeSignal).dispatch(NavigationStateType.CROP);
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
			new CropConfig(_coreModule.injector);

			// Init display tree for this module.
			var cropRootView : CropRootView = new CropRootView();
			_coreModule.injector.getInstance(RequestAddViewToMainLayerSignal).dispatch(cropRootView);

			// Notify potential super modules.
			moduleReadySignal.dispatch();
		}
	}
}
