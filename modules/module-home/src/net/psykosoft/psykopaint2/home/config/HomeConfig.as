package net.psykosoft.psykopaint2.home.config
{

	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfacePreviewSignal;
	import net.psykosoft.psykopaint2.home.commands.LoadPaintingDataCommand;
	import net.psykosoft.psykopaint2.home.commands.LoadSurfacePreviewCommand;
	import net.psykosoft.psykopaint2.home.commands.load.SetUpHomeModuleCommand;
	import net.psykosoft.psykopaint2.home.commands.unload.DestroyHomeModuleCommand;
	import net.psykosoft.psykopaint2.home.signals.NotifyCameraFlipRequest;
	import net.psykosoft.psykopaint2.home.signals.NotifyCameraSnapshotRequest;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestHomeIntroSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestHomeRootViewRemovalSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestLoadPaintingDataSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestOpenPaintingDataVOSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestSetupHomeModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootView;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootViewMediator;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavView;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.home.HomeViewMediator;
	import net.psykosoft.psykopaint2.home.views.newpainting.NewPaintingSubNavView;
	import net.psykosoft.psykopaint2.home.views.newpainting.NewPaintingSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.pickimage.CaptureImageSubNavView;
	import net.psykosoft.psykopaint2.home.views.pickimage.CaptureImageSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.pickimage.CaptureImageView;
	import net.psykosoft.psykopaint2.home.views.pickimage.CaptureImageViewMediator;
	import net.psykosoft.psykopaint2.home.views.pickimage.ConfirmCaptureImageSubNavView;
	import net.psykosoft.psykopaint2.home.views.pickimage.ConfirmCaptureImageSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.pickimage.PickAUserImageView;
	import net.psykosoft.psykopaint2.home.views.pickimage.PickAUserImageViewMediator;
	import net.psykosoft.psykopaint2.home.views.pickimage.PickAnImageSubNavView;
	import net.psykosoft.psykopaint2.home.views.pickimage.PickAnImageSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.picksurface.PickSurfaceSubNavView;
	import net.psykosoft.psykopaint2.home.views.picksurface.PickSurfaceSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.settings.SettingsSubNavView;
	import net.psykosoft.psykopaint2.home.views.settings.SettingsSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.settings.WallpaperSubNavView;
	import net.psykosoft.psykopaint2.home.views.settings.WallpaperSubNavViewMediator;

	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IInjector;

	public class HomeConfig
	{
		private var _injector:IInjector;
		private var _mediatorMap:IMediatorMap;
		private var _commandMap:ISignalCommandMap;

		public function HomeConfig( injector:IInjector ) {
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

		public function get injector():IInjector {
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
			_injector.map( NotifyCameraSnapshotRequest ).asSingleton();
			_injector.map( NotifyCameraFlipRequest ).asSingleton();
	   		_injector.map( RequestWallpaperChangeSignal ).asSingleton();
	   		_injector.map( NotifyHomeModuleSetUpSignal ).asSingleton();
	   		_injector.map( NotifyHomeModuleDestroyedSignal ).asSingleton();
	   		_injector.map( RequestHomeIntroSignal ).asSingleton();
	   		_injector.map( RequestOpenPaintingDataVOSignal ).asSingleton();
	   		_injector.map( RequestHomeRootViewRemovalSignal ).asSingleton();
		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {

			// Mapped in the core as singleton for compatibility and remapped here.
			_injector.unmap( RequestLoadSurfacePreviewSignal );
			_commandMap.map( RequestLoadSurfacePreviewSignal ).toCommand( LoadSurfacePreviewCommand );
			_commandMap.map( RequestSetupHomeModuleSignal ).toCommand( SetUpHomeModuleCommand );
			_commandMap.map( RequestDestroyHomeModuleSignal ).toCommand( DestroyHomeModuleCommand );
			_commandMap.map( RequestLoadPaintingDataSignal ).toCommand( LoadPaintingDataCommand );
		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators():void {
			_mediatorMap.map( HomeRootView ).toMediator( HomeRootViewMediator );
			_mediatorMap.map( HomeView ).toMediator( HomeViewMediator );
			_mediatorMap.map( NewPaintingSubNavView ).toMediator( NewPaintingSubNavViewMediator );
			_mediatorMap.map( SettingsSubNavView ).toMediator( SettingsSubNavViewMediator );
			_mediatorMap.map( WallpaperSubNavView ).toMediator( WallpaperSubNavViewMediator );
			_mediatorMap.map( HomeSubNavView ).toMediator( HomeSubNavViewMediator );
			_mediatorMap.map( PickSurfaceSubNavView ).toMediator( PickSurfaceSubNavViewMediator );
			_mediatorMap.map( PickAnImageSubNavView ).toMediator( PickAnImageSubNavViewMediator );
			_mediatorMap.map( PickAUserImageView ).toMediator( PickAUserImageViewMediator );
			_mediatorMap.map( CaptureImageSubNavView ).toMediator( CaptureImageSubNavViewMediator );
			_mediatorMap.map( ConfirmCaptureImageSubNavView ).toMediator( ConfirmCaptureImageSubNavViewMediator );
			_mediatorMap.map( CaptureImageView ).toMediator( CaptureImageViewMediator );
		}
	}
}
