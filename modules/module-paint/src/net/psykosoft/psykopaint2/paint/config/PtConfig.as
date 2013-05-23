package net.psykosoft.psykopaint2.paint.config
{

	import flash.display.DisplayObjectContainer;

	import net.psykosoft.psykopaint2.base.robotlegs.BsSignalCommandMapBundle;
	import net.psykosoft.psykopaint2.core.signals.notifications.CrNotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.paint.commands.PtRenderFrameCommand;
	import net.psykosoft.psykopaint2.paint.commands.PtSetSourceImageCommand;
	import net.psykosoft.psykopaint2.paint.commands.PtStartUpDrawingCoreCommand;
	import net.psykosoft.psykopaint2.paint.commands.PtUpdateAppStateFromActivatedDrawingCoreModuleCommand;
	import net.psykosoft.psykopaint2.paint.commands.PtUpdateCanvasRectCommand;
	import net.psykosoft.psykopaint2.paint.signals.requests.PtRequestDrawingCoreStartupSignal;
	import net.psykosoft.psykopaint2.paint.signals.requests.PtRequestRenderFrameSignal;
	import net.psykosoft.psykopaint2.paint.signals.requests.PtRequestSourceImageSetSignal;
	import net.psykosoft.psykopaint2.paint.signals.requests.PtRequestStateUpdateFromModuleActivationSignal;
	import net.psykosoft.psykopaint2.paint.views.brush.PtBrushParametersSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.PtBrushParametersSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.brush.PtSelectBrushSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.PtSelectBrushSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.brush.PtSelectShapeSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.PtSelectShapeSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.canvas.PtCanvasSubNavView;
	import net.psykosoft.psykopaint2.paint.views.canvas.PtCanvasSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.canvas.PtCanvasView;
	import net.psykosoft.psykopaint2.paint.views.canvas.PtCanvasViewMediator;
	import net.psykosoft.psykopaint2.paint.views.color.PtColorStyleSubNavView;
	import net.psykosoft.psykopaint2.paint.views.color.PtColorStyleSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.color.PtColorStyleView;
	import net.psykosoft.psykopaint2.paint.views.color.PtColorStyleViewMediator;
	import net.psykosoft.psykopaint2.paint.views.crop.PtCropSubNavView;
	import net.psykosoft.psykopaint2.paint.views.crop.PtCropSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.crop.PtCropView;
	import net.psykosoft.psykopaint2.paint.views.crop.PtCropViewMediator;
	import net.psykosoft.psykopaint2.paint.views.pick.PtPickAnImageView;
	import net.psykosoft.psykopaint2.paint.views.pick.PtPickAnImageViewMediator;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.bundles.mvcs.MVCSBundle;
	import robotlegs.bender.extensions.contextView.ContextView;

	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;

	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.impl.Context;

	// TODO: add all views to config
	// TODO: add commands views to config

	public class PtConfig
	{
		private var _injector:Injector;
		private var _mediatorMap:IMediatorMap;
		private var _commandMap:ISignalCommandMap;

		public function PtConfig( display:DisplayObjectContainer, injector:Injector ) {
			super();

			var context:IContext = new Context();
			context.install( MVCSBundle, BsSignalCommandMapBundle );
			context.configure( new ContextView( display ) );

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

		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {
			_commandMap.map( PtRequestStateUpdateFromModuleActivationSignal ).toCommand( PtUpdateAppStateFromActivatedDrawingCoreModuleCommand );
			_commandMap.map( PtRequestSourceImageSetSignal ).toCommand( PtSetSourceImageCommand );
			_commandMap.map( PtRequestRenderFrameSignal ).toCommand( PtRenderFrameCommand );
			// TODO: bug here! CrNotifyNavigationToggledSignal is already mapped
			_commandMap.map( CrNotifyNavigationToggledSignal ).toCommand( PtUpdateCanvasRectCommand );
			_commandMap.map( PtRequestDrawingCoreStartupSignal ).toCommand( PtStartUpDrawingCoreCommand );
		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators():void {
			_mediatorMap.map( PtBrushParametersSubNavView ).toMediator( PtBrushParametersSubNavViewMediator );
			_mediatorMap.map( PtSelectBrushSubNavView ).toMediator( PtSelectBrushSubNavViewMediator );
			_mediatorMap.map( PtSelectShapeSubNavView ).toMediator( PtSelectShapeSubNavViewMediator );
			_mediatorMap.map( PtCanvasSubNavView ).toMediator( PtCanvasSubNavViewMediator );
			_mediatorMap.map( PtCanvasView ).toMediator( PtCanvasViewMediator );
			_mediatorMap.map( PtColorStyleSubNavView ).toMediator( PtColorStyleSubNavViewMediator );
			_mediatorMap.map( PtColorStyleView ).toMediator( PtColorStyleViewMediator );
			_mediatorMap.map( PtCropSubNavView ).toMediator( PtCropSubNavViewMediator );
			_mediatorMap.map( PtCropView ).toMediator( PtCropViewMediator );
			_mediatorMap.map( PtPickAnImageView ).toMediator( PtPickAnImageViewMediator );
		}
	}
}
