package net.psykosoft.psykopaint2.core.configuration
{

	import away3d.core.managers.Stage3DProxy;

	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display.Stage3D;

	import net.psykosoft.psykopaint2.base.robotlegs.bundles.SignalCommandMapBundle;
	import net.psykosoft.psykopaint2.core.commands.ChangeStateCommand;
	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;
	import net.psykosoft.psykopaint2.core.commands.RetrievePaintingDataCommand;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.ApplicationRenderer;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.StateModel;
	import net.psykosoft.psykopaint2.core.models.UserModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyBlockingGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyEaselRectUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyExpensiveUiActionToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyHomeViewZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationMovingSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataSetSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpRemovedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpShownSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfacePreviewLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestBlankSourceImageActivationSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreResetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreSourceImageSetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreSurfaceSetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestGpuRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestInteractionBlockSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfacePreviewSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfaceSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationAutohideModeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintStateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintingActivationSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintingDataRetrievalSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal_OLD_TO_REMOVE;
	import net.psykosoft.psykopaint2.core.views.base.CoreRootView;
	import net.psykosoft.psykopaint2.core.views.base.CoreRootViewMediator;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationViewMediator;
	import net.psykosoft.psykopaint2.core.views.navigation.SbNavigationView;
	import net.psykosoft.psykopaint2.core.views.popups.MessagePopUpView;
	import net.psykosoft.psykopaint2.core.views.popups.MessagePopUpViewMediator;
	import net.psykosoft.psykopaint2.core.views.popups.PopUpManagerView;
	import net.psykosoft.psykopaint2.core.views.popups.PopUpManagerViewMediator;
	import net.psykosoft.psykopaint2.core.views.socket.PsykoSocketView;
	import net.psykosoft.psykopaint2.core.views.socket.PsykoSocketViewMediator;

	import robotlegs.bender.bundles.mvcs.MVCSBundle;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IInjector;
	import robotlegs.bender.framework.impl.Context;

	public class CoreConfig
	{
		private var _stage:Stage;
		private var _stage3d:Stage3D;
		private var _stage3dProxy:Stage3DProxy;
		private var _injector:IInjector;
		private var _mediatorMap:IMediatorMap;
		private var _commandMap:ISignalCommandMap;

		public function CoreConfig( display:DisplayObjectContainer, stage:Stage, stage3d:Stage3D, stage3dProxy:Stage3DProxy ) {
			super();

			var context:IContext = new Context();
			context.install( MVCSBundle, SignalCommandMapBundle );
			context.configure( new ContextView( display ) );

			_injector = context.injector;
			_mediatorMap = _injector.getInstance( IMediatorMap );
			_commandMap = _injector.getInstance( ISignalCommandMap );

			_stage = stage;
			_stage3d = stage3d;
			_stage3dProxy = stage3dProxy;

			mapClasses();
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
		// Classes.
		// -----------------------

		/*
		* These need to be mentioned somewhere so that getDefinitionByName works.
		* */
		private function mapClasses():void {
			MessagePopUpView;
		}

		// -----------------------
		// Models.
		// -----------------------

		private function mapModels():void {
			_injector.map( StateModel ).asSingleton();
			_injector.map( PaintingModel ).asSingleton();
			_injector.map( UserModel ).asSingleton();
			_injector.map( EaselRectModel ).asSingleton();
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
			_injector.map( Stage ).toValue( _stage );
			_injector.map( Stage3D ).toValue( _stage3d );
			_injector.map( Stage3DProxy ).toValue( _stage3dProxy );
			_injector.map( GestureManager ).asSingleton();
			_injector.map( ApplicationRenderer ).asSingleton();
		}

		// -----------------------
		// Notifications.
		// -----------------------

		private function mapNotifications():void {
			_injector.map( NotifyColorStyleCompleteSignal ).asSingleton();
			_injector.map( NotifyCropConfirmSignal ).asSingleton();
			_injector.map( NotifyStateChangeSignal ).asSingleton();
			_injector.map( NotifyGlobalGestureSignal ).asSingleton();
			_injector.map( NotifyNavigationToggledSignal ).asSingleton();
			_injector.map( NotifyExpensiveUiActionToggledSignal ).asSingleton();
			_injector.map( NotifyMemoryWarningSignal ).asSingleton();
			_injector.map( NotifyBlockingGestureSignal ).asSingleton();
			_injector.map( RequestNavigationToggleSignal ).asSingleton();
			_injector.map( RequestNavigationAutohideModeSignal ).asSingleton();
			_injector.map( NotifyNavigationMovingSignal ).asSingleton();
			_injector.map( NotifyPaintingDataSetSignal ).asSingleton();
			_injector.map( RequestPaintingActivationSignal ).asSingleton();
			_injector.map( NotifyPaintingActivatedSignal ).asSingleton();
			_injector.map( RequestDrawingCoreResetSignal ).asSingleton();
			_injector.map( RequestDrawingCoreSurfaceSetSignal ).asSingleton();
			_injector.map( RequestDrawingCoreSourceImageSetSignal ).asSingleton();
			_injector.map( RequestEaselUpdateSignal ).asSingleton();
			_injector.map( NotifyPopUpRemovedSignal ).asSingleton();
			_injector.map( NotifyEaselRectUpdateSignal ).asSingleton();
			_injector.map( NotifyHomeViewZoomCompleteSignal ).asSingleton();
			_injector.map( RequestHomeViewScrollSignal ).asSingleton();
			_injector.map( NotifyPopUpShownSignal ).asSingleton();
			_injector.map( RequestInteractionBlockSignal ).asSingleton();
			_injector.map( RequestLoadSurfaceSignal ).asSingleton();
			_injector.map( RequestLoadSurfacePreviewSignal ).asSingleton();
			_injector.map( NotifySurfacePreviewLoadedSignal ).asSingleton();
			_injector.map( NotifySurfaceLoadedSignal ).asSingleton();
			_injector.map( RequestBlankSourceImageActivationSignal ).asSingleton();
			_injector.map( RequestPaintStateSignal ).asSingleton();
			_injector.map( RequestHideSplashScreenSignal ).asSingleton();
		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {
			_commandMap.map( RequestStateChangeSignal_OLD_TO_REMOVE ).toCommand( ChangeStateCommand );
			_commandMap.map( RequestGpuRenderingSignal ).toCommand( RenderGpuCommand );
			_commandMap.map( RequestPaintingDataRetrievalSignal ).toCommand( RetrievePaintingDataCommand );
		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators():void {
			_mediatorMap.map( CoreRootView ).toMediator( CoreRootViewMediator );
			_mediatorMap.map( SbNavigationView ).toMediator( NavigationViewMediator );
			_mediatorMap.map( PsykoSocketView ).toMediator( PsykoSocketViewMediator );
			_mediatorMap.map( PopUpManagerView ).toMediator( PopUpManagerViewMediator );
			_mediatorMap.map( MessagePopUpView ).toMediator( MessagePopUpViewMediator );
		}
	}
}
