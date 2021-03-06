package net.psykosoft.psykopaint2.home.config
{

	import net.psykosoft.psykopaint2.core.commands.DisposePaintingDataCommand;
	import net.psykosoft.psykopaint2.core.models.CanvasSurfaceSettingsModel;
	import net.psykosoft.psykopaint2.home.commands.LoadPaintingDataFileCommand;
	import net.psykosoft.psykopaint2.home.commands.LoadSurfacePreviewCommand;
	import net.psykosoft.psykopaint2.home.commands.RequestLoadSurfacePreviewSignal;
	import net.psykosoft.psykopaint2.home.commands.StartNewColorPaintingCommand;
	import net.psykosoft.psykopaint2.home.commands.load.SetUpHomeModuleCommand;
	import net.psykosoft.psykopaint2.home.commands.unload.DestroyBookCommand;
	import net.psykosoft.psykopaint2.home.commands.unload.DestroyHomeModuleCommand;
	import net.psykosoft.psykopaint2.home.commands.unload.DisconnectHomeModuleShakeAndBakeCommand;
	import net.psykosoft.psykopaint2.home.commands.unload.RemoveHomeModuleDisplayCommand;
	import net.psykosoft.psykopaint2.home.model.ActiveGalleryPaintingModel;
	import net.psykosoft.psykopaint2.home.model.WallpaperModel;
	import net.psykosoft.psykopaint2.home.signals.NotifyCameraFlipRequest;
	import net.psykosoft.psykopaint2.home.signals.NotifyCameraSnapshotRequest;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewDeleteModeChangedSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewIntroZoomCompleteSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewSceneReadySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyBookSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDisconnectHomeModuleShakeAndBakeSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDisposePaintingDataSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestHomeIntroSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestHomeRootViewRemovalSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestLoadPaintingDataFileSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestOpenPaintingDataVOSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestRemoveHomeModuleDisplaySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestSetupHomeModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestStartNewColorPaintingSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootView;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootViewMediator;
	import net.psykosoft.psykopaint2.home.views.book.BookView;
	import net.psykosoft.psykopaint2.home.views.book.BookViewMediator;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryBrowseSubNavView;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryBrowseSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryPaintingSubNavView;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryPaintingSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryShareSubNavView;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryShareSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryUserSubNavView;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryUserSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryView;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryViewMediator;
	import net.psykosoft.psykopaint2.home.views.home.EaselView;
	import net.psykosoft.psykopaint2.home.views.home.EaselViewMediator;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavView;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.home.HomeViewMediator;
	import net.psykosoft.psykopaint2.home.views.home.RoomView;
	import net.psykosoft.psykopaint2.home.views.home.RoomViewMediator;
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
	import net.psykosoft.psykopaint2.home.views.settings.CanvasSurfaceSubNavView;
	import net.psykosoft.psykopaint2.home.views.settings.CanvasSurfaceSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.settings.SettingsHelpSubNavView;
	import net.psykosoft.psykopaint2.home.views.settings.SettingsHelpSubNavViewMediator;
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
			_injector.map( CanvasSurfaceSettingsModel ).asSingleton();
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
			_injector.map( ActiveGalleryPaintingModel ).asSingleton();
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
			_injector.map( NotifyHomeViewIntroZoomCompleteSignal ).asSingleton();
			_injector.map( NotifyHomeViewDeleteModeChangedSignal ).asSingleton();
		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {

			_commandMap.map( RequestLoadSurfacePreviewSignal ).toCommand( LoadSurfacePreviewCommand );
			_commandMap.map( RequestSetupHomeModuleSignal ).toCommand( SetUpHomeModuleCommand );
			_commandMap.map( RequestDestroyHomeModuleSignal ).toCommand( DestroyHomeModuleCommand );
			//RequestDestroyHomeModuleSignal DOES ALL THOSE 4 THINGS:
			_commandMap.map( RequestDisposePaintingDataSignal ).toCommand( DisposePaintingDataCommand );
			_commandMap.map( RequestRemoveHomeModuleDisplaySignal ).toCommand( RemoveHomeModuleDisplayCommand );
			_commandMap.map( RequestDisconnectHomeModuleShakeAndBakeSignal ).toCommand( DisconnectHomeModuleShakeAndBakeCommand );
			_commandMap.map( RequestDestroyBookSignal ).toCommand( DestroyBookCommand );
			_commandMap.map( RequestLoadPaintingDataFileSignal ).toCommand( LoadPaintingDataFileCommand );
			_commandMap.map( RequestStartNewColorPaintingSignal ).toCommand( StartNewColorPaintingCommand );
			
		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators():void {
			_mediatorMap.map( HomeRootView ).toMediator( HomeRootViewMediator );
			_mediatorMap.map( HomeView ).toMediator( HomeViewMediator );
			_mediatorMap.map( EaselView ).toMediator( EaselViewMediator );
			_mediatorMap.map( RoomView ).toMediator( RoomViewMediator );
			_mediatorMap.map( GalleryView ).toMediator( GalleryViewMediator );
			_mediatorMap.map( NewPaintingSubNavView ).toMediator( NewPaintingSubNavViewMediator );
			_mediatorMap.map( SettingsSubNavView ).toMediator( SettingsSubNavViewMediator );
			_mediatorMap.map( WallpaperSubNavView ).toMediator( WallpaperSubNavViewMediator );
			_mediatorMap.map( SettingsHelpSubNavView ).toMediator( SettingsHelpSubNavViewMediator );
			_mediatorMap.map( CanvasSurfaceSubNavView ).toMediator( CanvasSurfaceSubNavViewMediator );
//			_mediatorMap.map( PickSurfaceSubNavView ).toMediator( PickSurfaceSubNavViewMediator );
			_mediatorMap.map( PickAnImageSubNavView ).toMediator( PickAnImageSubNavViewMediator );
			_mediatorMap.map( GalleryBrowseSubNavView ).toMediator( GalleryBrowseSubNavViewMediator );
			_mediatorMap.map( GalleryPaintingSubNavView ).toMediator( GalleryPaintingSubNavViewMediator );
			_mediatorMap.map( GalleryShareSubNavView ).toMediator( GalleryShareSubNavViewMediator );
			_mediatorMap.map( GalleryUserSubNavView ).toMediator( GalleryUserSubNavViewMediator );
			_mediatorMap.map( HomeSubNavView ).toMediator( HomeSubNavViewMediator );
			_mediatorMap.map( PickAUserImageView ).toMediator( PickAUserImageViewMediator );
			_mediatorMap.map( CaptureImageSubNavView ).toMediator( CaptureImageSubNavViewMediator );
			_mediatorMap.map( CaptureImageView ).toMediator( CaptureImageViewMediator );
			_mediatorMap.map( BookView ).toMediator( BookViewMediator );
		}
	}
}
