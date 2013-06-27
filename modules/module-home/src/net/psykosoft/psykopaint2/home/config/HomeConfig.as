package net.psykosoft.psykopaint2.home.config
{

	import net.psykosoft.psykopaint2.home.commands.ZoomThenChangeStateCommand;
	import net.psykosoft.psykopaint2.home.signals.RequestEaselPaintingUpdateSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestZoomThenChangeStateSignal;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavView;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.home.HomeViewMediator;
	import net.psykosoft.psykopaint2.home.views.newpainting.NewPaintingSubNavView;
	import net.psykosoft.psykopaint2.home.views.newpainting.NewPaintingSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.picksurface.HomePickSurfaceSubNavView;
	import net.psykosoft.psykopaint2.home.views.picksurface.HomePickSurfaceSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.settings.SettingsSubNavView;
	import net.psykosoft.psykopaint2.home.views.settings.SettingsSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.settings.WallpaperSubNavView;
	import net.psykosoft.psykopaint2.home.views.settings.WallpaperSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.snapshot.HomeSnapShotView;
	import net.psykosoft.psykopaint2.home.views.snapshot.HomeSnapShotViewMediator;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;

	public class HomeConfig
	{
		private var _injector:Injector;
		private var _mediatorMap:IMediatorMap;
		private var _commandMap:ISignalCommandMap;

		public function HomeConfig( injector:Injector ) {
			super();

			_injector = injector;
			_mediatorMap = _injector.getInstance( IMediatorMap );
			_commandMap = _injector.getInstance( ISignalCommandMap );

			mapMediators();
			mapCommands();
			mapNotifications();
			mapSingletons();
			mapServices();
			mapModels();
		}

		public function get injector():Injector {
			return _injector;
		}

		// -----------------------
		// Models.
		// -----------------------

		private function mapModels():void {

		}

		// -----------------------
		// Services.
		// -----------------------

		private function mapServices():void {


		}

		// -----------------------
		// Singletons.
		// -----------------------

		private function mapSingletons():void {

		}

		// -----------------------
		// Notifications.
		// -----------------------

		private function mapNotifications():void {
	   		_injector.map( RequestWallpaperChangeSignal ).asSingleton();
	   		_injector.map( RequestEaselPaintingUpdateSignal ).asSingleton();
		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {
			_commandMap.map( RequestZoomThenChangeStateSignal ).toCommand( ZoomThenChangeStateCommand );
		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators():void {
			_mediatorMap.map( HomeView ).toMediator( HomeViewMediator );
			_mediatorMap.map( NewPaintingSubNavView ).toMediator( NewPaintingSubNavViewMediator );
			_mediatorMap.map( SettingsSubNavView ).toMediator( SettingsSubNavViewMediator );
			_mediatorMap.map( WallpaperSubNavView ).toMediator( WallpaperSubNavViewMediator );
			_mediatorMap.map( HomeSubNavView ).toMediator( HomeSubNavViewMediator );
			_mediatorMap.map( HomeSnapShotView ).toMediator( HomeSnapShotViewMediator );
			_mediatorMap.map( HomePickSurfaceSubNavView ).toMediator( HomePickSurfaceSubNavViewMediator );
		}
	}
}
