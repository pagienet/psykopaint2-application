package net.psykosoft.psykopaint2.app
{

	import flash.events.Event;

	import net.psykosoft.psykopaint2.app.config.AppConfig;
	import net.psykosoft.psykopaint2.app.states.TransitionSplashToHomeState;
	import net.psykosoft.psykopaint2.app.views.base.AppRootView;
	import net.psykosoft.psykopaint2.base.states.StateMachine;
	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.book.BookModule;
	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.crop.CropModule;
	import net.psykosoft.psykopaint2.home.HomeModule;
	import net.psykosoft.psykopaint2.paint.PaintModule;

	public class AppModule extends ModuleBase
	{
		private var _coreModule : CoreModule;
		private var _applicationStateMachine : StateMachine;

		public function AppModule()
		{
			super();
			_applicationStateMachine = new StateMachine();
			if (CoreSettings.NAME == "") CoreSettings.NAME = "AppModule";
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			initialize();
		}

		private function initialize() : void
		{
			createCoreModule();
		}

		// Core module.
		private function createCoreModule() : void
		{
			trace(this, "creating core module...");
			_coreModule = new CoreModule();
			_coreModule.isStandalone = false;
			_coreModule.moduleReadySignal.addOnce(onCoreModuleReady);
			addChild(_coreModule);
		}

		private function onCoreModuleReady() : void
		{
			trace(this, "core module is ready");
			_coreModule.startEnterFrame();
			createCropModule();
		}

		private function createCropModule() : void
		{
			trace(this, "creating crop module...");
			var cropModule : CropModule = new CropModule(_coreModule);
			cropModule.isStandalone = false;
			cropModule.moduleReadySignal.addOnce(onCropModuleReady);
			cropModule.initialize();
		}

		private function onCropModuleReady() : void
		{
			trace(this, "crop module is ready");
			createPaintModule();
		}

		// Paint module.
		private function createPaintModule() : void
		{
			trace(this, "creating paint module...");
			var paintModule : PaintModule = new PaintModule(_coreModule);
			paintModule.isStandalone = false;
			paintModule.moduleReadySignal.addOnce(onPaintModuleReady);
			paintModule.initialize();
		}

		private function onPaintModuleReady() : void
		{
			trace(this, "paint module is ready");
			createHomeModule();
		}

		// Home module.
		private function createHomeModule() : void
		{
			trace(this, "creating home module...");
			var homeModule : HomeModule = new HomeModule(_coreModule);
			homeModule.isStandalone = false;
			homeModule.moduleReadySignal.addOnce(onHomeModuleReady);
			homeModule.initialize();
		}

		private function onHomeModuleReady() : void
		{
			trace(this, "home module is ready");
			createBookModule();
		}

		// Book module.
		private function createBookModule() : void
		{
			trace(this, "creating book module...");
			var bookModule : BookModule = new BookModule(_coreModule);
			bookModule.isStandalone = false;
			bookModule.moduleReadySignal.addOnce(onBookModuleReady);
			bookModule.initialize();
		}

		private function onBookModuleReady() : void
		{
			trace(this, "book module is ready");

			// Initialize the app module.
			new AppConfig(_coreModule.injector);

			// Init display tree for this module.
			var appRootView : AppRootView = new AppRootView();
			_coreModule.injector.getInstance( RequestAddViewToMainLayerSignal ).dispatch( appRootView );

			transitionToHomeState();
		}

		private function transitionToHomeState() : void
		{
			var homeState : TransitionSplashToHomeState = _coreModule.injector.getInstance(TransitionSplashToHomeState);
			_applicationStateMachine.setActiveState(homeState);
		}
	}
}
