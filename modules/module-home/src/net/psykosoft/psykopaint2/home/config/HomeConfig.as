package net.psykosoft.psykopaint2.home.config
{

	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfacePreviewSignal;
	import net.psykosoft.psykopaint2.home.commands.LoadGalleryPaintingCommand;
	import net.psykosoft.psykopaint2.home.commands.LoadPaintingDataFileCommand;
	import net.psykosoft.psykopaint2.home.commands.LoadSurfacePreviewCommand;
	import net.psykosoft.psykopaint2.home.commands.load.SetUpHomeModuleCommand;
	import net.psykosoft.psykopaint2.home.commands.unload.DestroyHomeModuleCommand;
	import net.psykosoft.psykopaint2.home.model.WallpaperModel;
	import net.psykosoft.psykopaint2.home.signals.NotifyCameraFlipRequest;
	import net.psykosoft.psykopaint2.home.signals.NotifyCameraSnapshotRequest;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewSceneReadySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseGallerySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseSampleImagesSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseUserImagesSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestExitGallerySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestExitPickAnImageSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestHomeIntroSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestHomeRootViewRemovalSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestLoadPaintingDataFileSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestLoadGalleryPaintingSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestOpenPaintingDataVOSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestRetrieveCameraImageSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestSetupHomeModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootView;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootViewMediator;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryBrowseSubNavView;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryBrowseSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryPaintingSubNavView;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryPaintingSubNavViewMediator;
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
			mapSignals();
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
			_injector.map( WallpaperModel ).asSingleton();
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

		private function mapSignals():void {
			_injector.map( NotifyCameraSnapshotRequest ).asSingleton();
			_injector.map( NotifyCameraFlipRequest ).asSingleton();
	   		_injector.map( RequestWallpaperChangeSignal ).asSingleton();
	   		_injector.map( NotifyHomeModuleSetUpSignal ).asSingleton();
	   		_injector.map( NotifyHomeModuleDestroyedSignal ).asSingleton();
	   		_injector.map( RequestHomeIntroSignal ).asSingleton();
	   		_injector.map( RequestOpenPaintingDataVOSignal ).asSingleton();
	   		_injector.map( RequestHomeRootViewRemovalSignal ).asSingleton();
	   		_injector.map( NotifyHomeViewSceneReadySignal ).asSingleton();
			_injector.map( RequestBrowseSampleImagesSignal ).asSingleton();
			_injector.map( RequestBrowseUserImagesSignal ).asSingleton();
			_injector.map( RequestBrowseGallerySignal ).asSingleton();
			_injector.map( RequestExitPickAnImageSignal ).asSingleton();
			_injector.map( RequestExitGallerySignal ).asSingleton();
			_injector.map( RequestRetrieveCameraImageSignal ).asSingleton();
			_injector.map( RequestHomePanningToggleSignal ).asSingleton();
			_injector.map( RequestOpenGalleryImageSignal ).asSingleton();
		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {

			_injector.unmap( RequestLoadSurfacePreviewSignal );
			_commandMap.map( RequestLoadSurfacePreviewSignal ).toCommand( LoadSurfacePreviewCommand );
			_commandMap.map( RequestSetupHomeModuleSignal ).toCommand( SetUpHomeModuleCommand );
			_commandMap.map( RequestDestroyHomeModuleSignal ).toCommand( DestroyHomeModuleCommand );
			_commandMap.map( RequestLoadPaintingDataFileSignal ).toCommand( LoadPaintingDataFileCommand );
			_commandMap.map( RequestLoadGalleryPaintingSignal ).toCommand( LoadGalleryPaintingCommand );
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
			_mediatorMap.map( GalleryBrowseSubNavView ).toMediator( GalleryBrowseSubNavViewMediator );
			_mediatorMap.map( GalleryPaintingSubNavView ).toMediator( GalleryPaintingSubNavViewMediator );
			_mediatorMap.map( PickAUserImageView ).toMediator( PickAUserImageViewMediator );
			_mediatorMap.map( CaptureImageSubNavView ).toMediator( CaptureImageSubNavViewMediator );
			_mediatorMap.map( CaptureImageView ).toMediator( CaptureImageViewMediator );
		}
	}
}
