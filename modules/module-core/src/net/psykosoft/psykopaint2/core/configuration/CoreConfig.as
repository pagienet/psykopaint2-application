package net.psykosoft.psykopaint2.core.configuration
{

	import flash.display.DisplayObjectContainer;

	import net.psykosoft.psykopaint2.base.robotlegs.bundles.SignalCommandMapBundle;
	import net.psykosoft.psykopaint2.core.commands.ChangeStateCommand;
	import net.psykosoft.psykopaint2.core.commands.LoadPaintingInfoFileCommand;
	import net.psykosoft.psykopaint2.core.commands.LovePaintingCommand;
	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;
	import net.psykosoft.psykopaint2.core.commands.RetrieveAllPaintingDataCommand;
	import net.psykosoft.psykopaint2.core.commands.UpdateFrameCommand;
	import net.psykosoft.psykopaint2.core.commands.bootstrap.BootstrapCoreModuleCommand;
	import net.psykosoft.psykopaint2.core.data.RetrievePaintingsDataProcessModel;
	import net.psykosoft.psykopaint2.core.managers.accelerometer.AccelerometerManager;
	import net.psykosoft.psykopaint2.core.managers.accelerometer.GyroscopeManager;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
	import net.psykosoft.psykopaint2.core.managers.misc.KeyDebuggingManager;
	import net.psykosoft.psykopaint2.core.managers.misc.MemoryWarningManager;
	import net.psykosoft.psykopaint2.core.managers.misc.UnDisposedObjectsManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.ApplicationRenderer;
	import net.psykosoft.psykopaint2.core.models.AMFGalleryService;
	import net.psykosoft.psykopaint2.core.models.AMFLoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.DummyGalleryService;
	import net.psykosoft.psykopaint2.core.models.DummyLoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.models.GalleryService;
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.NavigationStateModel;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.SavingProcessModel;
	import net.psykosoft.psykopaint2.core.models.UserConfigModel;
	import net.psykosoft.psykopaint2.core.services.AMFBridge;
	import net.psykosoft.psykopaint2.core.signals.NavigationCanHideWithGesturesSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyAMFConnectionFailed;
	import net.psykosoft.psykopaint2.core.signals.NotifyAddCommentFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyAddCommentSucceededSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyBlockingGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasExportEndedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasExportStartedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCoreModuleBootstrapCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyEaselRectUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyEaselTappedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalAccelerometerSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGyroscopeUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyHomeViewZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationMovingSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyLovePaintingSucceededSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyLovePaintingFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataSavedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataSetSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingInfoFileReadSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingInfoSavedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingSavingStartedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPasswordResetFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPasswordResetSucceededSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpRemovedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpShownSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySplashScreenRemovedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfacePreviewLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLogInFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLogOutFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLoggedInSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLoggedOutSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserPasswordReminderFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserPasswordReminderSentSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserRegisteredSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserRegistrationFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestCoreModuleBootstrapSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestCropSourceImageSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreResetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestFinalizeCropSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestFrameUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestGpuRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomePanningToggleSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfacePreviewSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfaceSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLovePaintingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationDisposalSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestAllPaintingDataRetrievalSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintingInfoFileReadSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestResumeCPUUsageForUISignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSaveCPUForUISignal;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.ToggleTransformGestureSignal;
	import net.psykosoft.psykopaint2.core.views.base.CoreRootView;
	import net.psykosoft.psykopaint2.core.views.base.CoreRootViewMediator;
	import net.psykosoft.psykopaint2.core.views.blocker.BlockerView;
	import net.psykosoft.psykopaint2.core.views.blocker.BlockerViewMediator;
	import net.psykosoft.psykopaint2.core.views.debug.DebugView;
	import net.psykosoft.psykopaint2.core.views.debug.DebugViewMediator;
	import net.psykosoft.psykopaint2.core.views.debug.ErrorsView;
	import net.psykosoft.psykopaint2.core.views.debug.ErrorsViewMediator;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationView;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationViewMediator;
	import net.psykosoft.psykopaint2.core.views.popups.login.LoginPopUpView;
	import net.psykosoft.psykopaint2.core.views.popups.login.LoginPopUpViewMediator;
	import net.psykosoft.psykopaint2.core.views.popups.messages.MessagePopUpView;
	import net.psykosoft.psykopaint2.core.views.popups.messages.MessagePopUpViewMediator;
	import net.psykosoft.psykopaint2.core.views.popups.PopUpManagerView;
	import net.psykosoft.psykopaint2.core.views.popups.PopUpManagerViewMediator;
	import net.psykosoft.psykopaint2.core.views.socket.PsykoSocketView;
	import net.psykosoft.psykopaint2.core.views.socket.PsykoSocketViewMediator;
	import net.psykosoft.psykopaint2.core.views.splash.SplashView;
	import net.psykosoft.psykopaint2.core.views.splash.SplashViewMediator;
	import net.psykosoft.psykopaint2.core.views.video.VideoView;
	import net.psykosoft.psykopaint2.core.views.video.VideoViewMediator;

	import robotlegs.bender.bundles.mvcs.MVCSBundle;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IInjector;
	import robotlegs.bender.framework.impl.Context;

	public class CoreConfig
	{
		private var _injector:IInjector;
		private var _mediatorMap:IMediatorMap;
		private var _commandMap:ISignalCommandMap;

		public function CoreConfig( display:DisplayObjectContainer ) {
			super();

			var context:IContext = new Context();
			context.install( MVCSBundle, SignalCommandMapBundle );
			context.configure( new ContextView( display ) );

			_injector = context.injector;
			_mediatorMap = _injector.getInstance( IMediatorMap );
			_commandMap = _injector.getInstance( ISignalCommandMap );

			mapClasses();
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
		// Classes.
		// -----------------------

		/*
		* These need to be mentioned somewhere so that getDefinitionByName works.
		* */
		private function mapClasses():void {
			MessagePopUpView;
			LoginPopUpView;
		}

		// -----------------------
		// Models.
		// -----------------------

		private function mapModels():void {
			_injector.map( NavigationStateModel ).asSingleton();
			_injector.map( PaintingModel ).asSingleton();
			_injector.map( EaselRectModel ).asSingleton();
			_injector.map(SavingProcessModel).asSingleton();
			_injector.map(UserConfigModel).asSingleton();
		}

		// -----------------------
		// Services.
		// -----------------------

		private function mapServices():void {
			_injector.map(AMFBridge).asSingleton();
		}

		// -----------------------
		// Singletons.
		// -----------------------

		private function mapSingletons():void {
			_injector.map( IOAneManager ).asSingleton();
			_injector.map( GestureManager ).asSingleton();
			_injector.map( ApplicationRenderer ).asSingleton();
			_injector.map( MemoryWarningManager ).asSingleton();
			_injector.map( KeyDebuggingManager ).asSingleton();
			_injector.map( UnDisposedObjectsManager ).asSingleton();
			_injector.map(GyroscopeManager).asSingleton();
			_injector.map(AccelerometerManager).asSingleton();
			_injector.map(RetrievePaintingsDataProcessModel).asSingleton();

			// -----------------------
			// Services.
			// -----------------------

			// Pick one.
			_injector.map( LoggedInUserProxy ).toSingleton(AMFLoggedInUserProxy);
//			_injector.map( LoggedInUserProxy ).toSingleton(DummyLoggedInUserProxy);

			// Pick one.
//			_injector.map(GalleryService).toSingleton(DummyGalleryService);
			_injector.map(GalleryService).toSingleton(AMFGalleryService);

		}

		// -----------------------
		// Notifications.
		// -----------------------

		private function mapSignals():void {
			_injector.map( RequestFinalizeCropSignal ).asSingleton();
			_injector.map( NotifyNavigationStateChangeSignal ).asSingleton();
			_injector.map( NotifyGlobalGestureSignal ).asSingleton();
			_injector.map( NotifyNavigationToggledSignal ).asSingleton();
			_injector.map( NotifyMemoryWarningSignal ).asSingleton();
			_injector.map( NotifyBlockingGestureSignal ).asSingleton();
			_injector.map( RequestNavigationToggleSignal ).asSingleton();
			_injector.map( NotifyNavigationMovingSignal ).asSingleton();
			_injector.map( NotifyPaintingDataSetSignal ).asSingleton();
			_injector.map( RequestDrawingCoreResetSignal ).asSingleton();
			_injector.map( RequestEaselUpdateSignal ).asSingleton();
			_injector.map( NotifyPopUpRemovedSignal ).asSingleton();
			_injector.map( NotifyEaselRectUpdateSignal ).asSingleton();
			_injector.map( NotifyHomeViewZoomCompleteSignal ).asSingleton();
			_injector.map( RequestHomeViewScrollSignal ).asSingleton();
			_injector.map( NotifyPopUpShownSignal ).asSingleton();
			_injector.map( RequestUpdateMessagePopUpSignal ).asSingleton();
			_injector.map( RequestLoadSurfaceSignal ).asSingleton();
			_injector.map( RequestLoadSurfacePreviewSignal ).asSingleton();
			_injector.map( NotifySurfacePreviewLoadedSignal ).asSingleton();
			_injector.map( NotifySurfaceLoadedSignal ).asSingleton();
			_injector.map( RequestCropSourceImageSignal ).asSingleton();
			_injector.map( RequestHideSplashScreenSignal ).asSingleton();
			_injector.map( NotifyPaintingInfoSavedSignal ).asSingleton();
			_injector.map( NotifyPaintingDataSavedSignal ).asSingleton();
			_injector.map( NotifyPaintingSavingStartedSignal ).asSingleton();
			_injector.map( NotifyCanvasExportStartedSignal ).asSingleton();
			_injector.map( NotifyCanvasExportEndedSignal ).asSingleton();
			_injector.map( NotifyCoreModuleBootstrapCompleteSignal ).asSingleton();
			_injector.map( RequestAddViewToMainLayerSignal ).asSingleton();
			_injector.map( RequestSaveCPUForUISignal ).asSingleton();
			_injector.map( RequestResumeCPUUsageForUISignal ).asSingleton();
			_injector.map( RequestNavigationDisposalSignal ).asSingleton();
			_injector.map( RequestChangeRenderRectSignal ).asSingleton();
			_injector.map( RequestShowPopUpSignal ).asSingleton();
			_injector.map( RequestHidePopUpSignal ).asSingleton();
			_injector.map( NotifySplashScreenRemovedSignal ).asSingleton();
			_injector.map( NotifyPaintingInfoFileReadSignal ).asSingleton();
			_injector.map( NotifyGyroscopeUpdateSignal ).asSingleton();
			_injector.map( NotifyGlobalAccelerometerSignal ).asSingleton();
			_injector.map( NotifyUserLoggedInSignal ).asSingleton();
			_injector.map( NotifyUserLogInFailedSignal ).asSingleton();
			_injector.map( NotifyUserLoggedOutSignal ).asSingleton();
			_injector.map( NotifyUserLogOutFailedSignal ).asSingleton();
			_injector.map( NotifyUserRegisteredSignal ).asSingleton();
			_injector.map( NotifyUserRegistrationFailedSignal ).asSingleton();
			_injector.map( ToggleTransformGestureSignal ).asSingleton();
			_injector.map( RequestHomePanningToggleSignal ).asSingleton();
			_injector.map( NotifyLovePaintingSucceededSignal ).asSingleton();
			_injector.map( NotifyLovePaintingFailedSignal ).asSingleton();
			_injector.map( NotifyAddCommentSucceededSignal ).asSingleton();
			_injector.map( NotifyAddCommentFailedSignal ).asSingleton();
			_injector.map( NotifyPasswordResetSucceededSignal ).asSingleton();
			_injector.map( NotifyPasswordResetFailedSignal ).asSingleton();
			_injector.map( NotifyUserPasswordReminderSentSignal ).asSingleton();
			_injector.map( NotifyUserPasswordReminderFailedSignal ).asSingleton();
			_injector.map( NavigationCanHideWithGesturesSignal ).asSingleton();
			_injector.map( NotifyEaselTappedSignal ).asSingleton();

			// services
			_injector.map( NotifyAMFConnectionFailed ).asSingleton();
		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {
			_commandMap.map( RequestNavigationStateChangeSignal ).toCommand( ChangeStateCommand );
			_commandMap.map( RequestGpuRenderingSignal ).toCommand( RenderGpuCommand );
			_commandMap.map( RequestAllPaintingDataRetrievalSignal ).toCommand( RetrieveAllPaintingDataCommand );
			_commandMap.map( RequestCoreModuleBootstrapSignal ).toCommand( BootstrapCoreModuleCommand );
			_commandMap.map( RequestFrameUpdateSignal ).toCommand( UpdateFrameCommand );
			_commandMap.map( RequestPaintingInfoFileReadSignal ).toCommand( LoadPaintingInfoFileCommand );
			_commandMap.map( RequestLovePaintingSignal ).toCommand( LovePaintingCommand );
		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators():void {
			_mediatorMap.map( CoreRootView ).toMediator( CoreRootViewMediator );
			_mediatorMap.map( NavigationView ).toMediator( NavigationViewMediator );
			_mediatorMap.map( PsykoSocketView ).toMediator( PsykoSocketViewMediator );
			_mediatorMap.map( PopUpManagerView ).toMediator( PopUpManagerViewMediator );
			_mediatorMap.map( MessagePopUpView ).toMediator( MessagePopUpViewMediator );
			_mediatorMap.map( LoginPopUpView ).toMediator( LoginPopUpViewMediator );
			_mediatorMap.map( DebugView ).toMediator( DebugViewMediator );
			_mediatorMap.map( ErrorsView ).toMediator( ErrorsViewMediator );
			_mediatorMap.map( VideoView ).toMediator( VideoViewMediator );
			_mediatorMap.map( SplashView ).toMediator( SplashViewMediator );
			_mediatorMap.map( BlockerView ).toMediator( BlockerViewMediator );
		}
	}
}
