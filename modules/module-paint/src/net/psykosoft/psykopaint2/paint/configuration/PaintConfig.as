package net.psykosoft.psykopaint2.paint.configuration
{

	import net.psykosoft.psykopaint2.core.commands.ClearCanvasCommand;
	import net.psykosoft.psykopaint2.paint.commands.saving.SavePaintingToServerCommand;
	import net.psykosoft.psykopaint2.core.commands.UndoCanvasActionCommand;
	import net.psykosoft.psykopaint2.core.controllers.GyroscopeLightController;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.BrushShapeLibrary;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.managers.pen.WacomPenManager;
	import net.psykosoft.psykopaint2.core.managers.purchase.InAppPurchaseManager;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.LightingModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyActivateBrushChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyAvailableBrushTypesSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasMatrixChanged;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStylePresetsAvailableSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyHistoryStackChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySaveToServerFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySaveToServerStartedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySaveToServerSucceededSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyTogglePaintingEnableSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestClearCanvasSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfaceSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSavePaintingToServerSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUndoSignal;
	import net.psykosoft.psykopaint2.paint.commands.DeletePaintingCommand;
	import net.psykosoft.psykopaint2.paint.commands.DestroyPaintModuleCommand;
	import net.psykosoft.psykopaint2.paint.commands.ExportCanvasCommand;
	import net.psykosoft.psykopaint2.paint.commands.LoadSurfaceCommand;
	import net.psykosoft.psykopaint2.paint.commands.SetupPaintModuleCommand;
	import net.psykosoft.psykopaint2.paint.commands.saving.DiscardPaintingCommand;
	import net.psykosoft.psykopaint2.paint.commands.saving.SavePaintingCommand;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCanvasZoomedToDefaultViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCanvasZoomedToEaselViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyChangePipetteColorSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModeChangedSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleSetUpSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPickedColorChangedSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPipetteChargeChangedSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyShowPipetteSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestCanvasExportSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestDestroyPaintModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintRootViewRemovalSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingDeletionSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingDiscardSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingSaveSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetCanvasBackgroundSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetupPaintModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestZoomCanvasToDefaultViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestZoomCanvasToEaselViewSignal;
	import net.psykosoft.psykopaint2.paint.views.base.PaintRootView;
	import net.psykosoft.psykopaint2.paint.views.base.PaintRootViewMediator;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectBrushSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectBrushSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.brush.UpgradeSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.UpgradeSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasSubNavView;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasView;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasViewMediator;
	import net.psykosoft.psykopaint2.paint.views.canvas.PipetteView;
	import net.psykosoft.psykopaint2.paint.views.canvas.PipetteViewMediator;
	import net.psykosoft.psykopaint2.paint.views.color.ColorPickerSubNavView;
	import net.psykosoft.psykopaint2.paint.views.color.ColorPickerSubNavViewMediator;
	
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IInjector;

	public class PaintConfig
	{
		private var _injector:IInjector;
		private var _mediatorMap:IMediatorMap;
		private var _commandMap:ISignalCommandMap;

		public function PaintConfig( injector:IInjector ) {
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
			
			_injector.map(GyroscopeLightController).asSingleton();
			_injector.map(BrushShapeLibrary).asSingleton();
			_injector.map(BrushKitManager).asSingleton();
			_injector.map(CanvasRenderer).asSingleton();
			_injector.map(LightingModel).asSingleton();
			_injector.map(CanvasModel).asSingleton();
			_injector.map(CanvasHistoryModel).asSingleton();
			_injector.map(UserPaintSettingsModel).asSingleton();
			
			
		//	_injector.map(RubberMeshRenderer).asSingleton();
		//	_injector.map(RubberMeshModel).asSingleton();
		}

		// -----------------------
		// Notifications.
		// -----------------------

		private function mapSignals():void {
			_injector.map( NotifyCanvasMatrixChanged ).asSingleton();
			_injector.map( RequestZoomCanvasToDefaultViewSignal ).asSingleton();
			_injector.map( NotifyCanvasZoomedToDefaultViewSignal ).asSingleton();
			_injector.map( NotifyCanvasZoomedToEaselViewSignal ).asSingleton();
			_injector.map( RequestZoomCanvasToEaselViewSignal ).asSingleton();
			_injector.map( NotifyPaintModuleSetUpSignal ).asSingleton();
			_injector.map( NotifyPickedColorChangedSignal ).asSingleton();
			_injector.map( NotifyPaintModuleDestroyedSignal ).asSingleton();
			_injector.map( RequestSetCanvasBackgroundSignal ).asSingleton();
			_injector.map( RequestPaintRootViewRemovalSignal ).asSingleton();
			_injector.map( NotifyAvailableBrushTypesSignal ).asSingleton();
			_injector.map( NotifyActivateBrushChangedSignal ).asSingleton();
			_injector.map( NotifyColorStylePresetsAvailableSignal ).asSingleton();
			_injector.map( NotifyColorStyleChangedSignal ).asSingleton();
			_injector.map( NotifyHistoryStackChangedSignal ).asSingleton();
			_injector.map( NotifySaveToServerStartedSignal ).asSingleton();
			_injector.map( NotifySaveToServerSucceededSignal ).asSingleton();
			_injector.map( NotifySaveToServerFailedSignal ).asSingleton();
			_injector.map( NotifyShowPipetteSignal ).asSingleton();
			_injector.map( NotifyPipetteChargeChangedSignal ).asSingleton();
			_injector.map( NotifyChangePipetteColorSignal ).asSingleton();
			_injector.map( NotifyTogglePaintingEnableSignal ).asSingleton();
			_injector.map( NotifyPaintModeChangedSignal ).asSingleton();
			
		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {

			_commandMap.map( RequestCanvasExportSignal ).toCommand( ExportCanvasCommand );
			_commandMap.map( RequestPaintingSaveSignal ).toCommand( SavePaintingCommand );
			_commandMap.map( RequestPaintingDiscardSignal ).toCommand( DiscardPaintingCommand );
			_commandMap.map( RequestPaintingDeletionSignal ).toCommand( DeletePaintingCommand );
			_commandMap.map( RequestSetupPaintModuleSignal ).toCommand( SetupPaintModuleCommand );
			_commandMap.map( RequestDestroyPaintModuleSignal ).toCommand( DestroyPaintModuleCommand );

			_commandMap.map( RequestSavePaintingToServerSignal ).toCommand( SavePaintingToServerCommand );

			// TODO: Remove this unmap, this signifies bad cross-modular design
			_injector.unmap( RequestLoadSurfaceSignal );
			_commandMap.map( RequestLoadSurfaceSignal ).toCommand( LoadSurfaceCommand );

			_commandMap.map(RequestClearCanvasSignal).toCommand(ClearCanvasCommand);
			_commandMap.map(RequestUndoSignal).toCommand(UndoCanvasActionCommand);
		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators():void {
			//_mediatorMap.map( EditBrushSubNavView ).toMediator( EditBrushSubNavViewMediator );
			_mediatorMap.map( SelectBrushSubNavView ).toMediator( SelectBrushSubNavViewMediator );
			_mediatorMap.map( CanvasSubNavView ).toMediator( CanvasSubNavViewMediator );
			_mediatorMap.map( CanvasView ).toMediator( CanvasViewMediator );
			_mediatorMap.map( PaintRootView ).toMediator( PaintRootViewMediator );
			_mediatorMap.map( ColorPickerSubNavView ).toMediator( ColorPickerSubNavViewMediator );
			_mediatorMap.map( UpgradeSubNavView ).toMediator( UpgradeSubNavViewMediator );
			//_mediatorMap.map( AlphaSubNavView ).toMediator( AlphaSubNavViewMediator );
			_mediatorMap.map( PipetteView ).toMediator( PipetteViewMediator );
		}
	}
}
