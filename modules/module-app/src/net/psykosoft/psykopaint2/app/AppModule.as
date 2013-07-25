package net.psykosoft.psykopaint2.app
{

	import flash.events.Event;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.app.config.AppConfig;
	import net.psykosoft.psykopaint2.app.states.BookState;
	import net.psykosoft.psykopaint2.app.states.CropState;
	import net.psykosoft.psykopaint2.app.states.HomeState;
	import net.psykosoft.psykopaint2.app.states.IntroToHomeState;
	import net.psykosoft.psykopaint2.app.states.PaintState;
	import net.psykosoft.psykopaint2.app.states.SplashScreenState;
	import net.psykosoft.psykopaint2.app.states.TransitionHomeToPaintState;
	import net.psykosoft.psykopaint2.app.views.base.AppRootView;
	import net.psykosoft.psykopaint2.base.states.StateMachine;
	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.book.BookModule;
	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyHomeViewZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestGpuRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal_OLD_TO_REMOVE;
	import net.psykosoft.psykopaint2.home.HomeModule;
	import net.psykosoft.psykopaint2.paint.PaintModule;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.framework.api.IInjector;

	public class AppModule extends ModuleBase
	{
		private var _coreModule:CoreModule;
		private var _applicationStateMachine : StateMachine;

		public function AppModule() {
			super();
			_applicationStateMachine = new StateMachine();
			if( CoreSettings.NAME == "" ) CoreSettings.NAME = "AppModule";
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
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

		private function initialize():void {
			createCoreModule();
		}

		private function createStates() : void
		{
			var injector : IInjector = _coreModule.injector;
			injector.map(IntroToHomeState).asSingleton();
			injector.map(HomeState).asSingleton();
			injector.map(CropState).asSingleton();
			injector.map(PaintState).asSingleton();
			injector.map(BookState).asSingleton();
			injector.map(TransitionHomeToPaintState).asSingleton();
		}

		// Core module.
		private function createCoreModule():void {
			trace( this, "creating core module..." );
			_coreModule = new CoreModule();
			_applicationStateMachine.setActiveState(new SplashScreenState(_coreModule));
			_coreModule.isStandalone = false;
			_coreModule.moduleReadySignal.addOnce( onCoreModuleReady );
			addChild( _coreModule );
		}
		private function onCoreModuleReady():void {
			trace( this, "core module is ready, injector: " + _coreModule.injector );
			_coreModule.startEnterFrame();
			createStates();
			createPaintModule();
		}

		// Paint module.
		private function createPaintModule():void {
//			var rlStage:Stage = _coreModule.injector.getInstance( Stage );
//			var rlStage3d:Stage3D = _coreModule.injector.getInstance( Stage3D );
			trace( this, "creating paint module..." );
			var paintModule:PaintModule = new PaintModule( _coreModule );
			paintModule.isStandalone = false;
			paintModule.moduleReadySignal.addOnce( onPaintModuleReady );
			paintModule.initialize();
		}
		private function onPaintModuleReady( coreInjector:Injector ):void {
		    trace( this, "paint module is ready" );
			createHomeModule();
		}

		// Home module.
		private function createHomeModule():void {
			trace( this, "creating home module..." );
			var homeModule:HomeModule = new HomeModule( _coreModule );
			homeModule.isStandalone = false;
			homeModule.moduleReadySignal.addOnce( onHomeModuleReady );
			homeModule.initialize();
		}
		private function onHomeModuleReady( coreInjector:Injector ):void {
			trace( this, "home module is ready" );
			createBookModule();
		}

		// Book module.
		private function createBookModule():void {
			trace( this, "creating book module..." );
			var bookModule:BookModule = new BookModule( _coreModule );
			bookModule.isStandalone = false;
			bookModule.moduleReadySignal.addOnce( onBookModuleReady );
			bookModule.initialize();
		}
		private function onBookModuleReady( coreInjector:Injector ):void {
			trace( this, "book module is ready" );

			// Initialize the app module.
			new AppConfig( _coreModule.injector );

			// Init display tree for this module.
			var appRootView:AppRootView = new AppRootView();
			appRootView.allViewsReadySignal.addOnce( onViewsReady );
			_coreModule.addModuleDisplay( appRootView );
		}

		private function onViewsReady():void {

			trace( this, "app views ready -" );

			transitionToHomeState();
		}

		private function transitionToHomeState() : void
		{
			var homeState : IntroToHomeState = _coreModule.injector.getInstance(IntroToHomeState);
			_applicationStateMachine.setActiveState(homeState);
		}
	}
}
