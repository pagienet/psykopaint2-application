package net.psykosoft.psykopaint2.paint.configuration
{

	import net.psykosoft.psykopaint2.core.commands.ClearCanvasCommand;
	import net.psykosoft.psykopaint2.core.commands.UndoCanvasActionCommand;
	import net.psykosoft.psykopaint2.core.controllers.GyroscopeLightController;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.BrushShapeLibrary;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.drawing.modules.ColorStyleModule;
	import net.psykosoft.psykopaint2.core.managers.accelerometer.AccelerometerManager;
	import net.psykosoft.psykopaint2.core.managers.accelerometer.GyroscopeManager;
	import net.psykosoft.psykopaint2.core.managers.pen.WacomPenManager;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.LightingModel;
	import net.psykosoft.psykopaint2.core.model.RubberMeshModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.rendering.RubberMeshRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyActivateBrushChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyAvailableBrushTypesSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasMatrixChanged;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStylePresetsAvailableSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalAccelerometerSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGyroscopeUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyHistoryStackChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationHideSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySetColorStyleSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestClearCanvasSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestColorStyleMatrixChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfaceSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestOpenCroppedBitmapDataSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUndoSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateCropImageSignal;
	import net.psykosoft.psykopaint2.paint.commands.DeletePaintingCommand;
	import net.psykosoft.psykopaint2.paint.commands.DestroyPaintModuleCommand;
	import net.psykosoft.psykopaint2.paint.commands.ExportCanvasCommand;
	import net.psykosoft.psykopaint2.paint.commands.LoadSurfaceCommand;
	import net.psykosoft.psykopaint2.paint.commands.SavePaintingCommand;
	import net.psykosoft.psykopaint2.paint.commands.SetupPaintModuleCommand;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleSetUpSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestCanvasExportSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestDestroyPaintModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintRootViewRemovalSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingDeletionSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingSaveSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetCanvasBackgroundSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetupPaintModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestZoomCanvasToDefaultViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestZoomCanvasToEaselViewSignal;
	import net.psykosoft.psykopaint2.paint.views.base.PaintRootView;
	import net.psykosoft.psykopaint2.paint.views.base.PaintRootViewMediator;
	import net.psykosoft.psykopaint2.paint.views.brush.EditBrushSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.EditBrushSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectBrushSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectBrushSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectColorSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectColorSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasSubNavView;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasView;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasViewMediator;

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
			_injector.map(GyroscopeManager).asSingleton();
			_injector.map(AccelerometerManager).asSingleton();
			_injector.map(WacomPenManager).asSingleton();
			_injector.map(GyroscopeLightController).asSingleton();
			_injector.map(BrushShapeLibrary).asSingleton();
			_injector.map(BrushKitManager).asSingleton();
			_injector.map(ColorStyleModule).asSingleton();

			_injector.map(CanvasRenderer).asSingleton();
			_injector.map(LightingModel).asSingleton();
			_injector.map(CanvasModel).asSingleton();
			_injector.map(CanvasHistoryModel).asSingleton();

			_injector.map(RubberMeshRenderer).asSingleton();
			_injector.map(RubberMeshModel).asSingleton();
		}

		// -----------------------
		// Notifications.
		// -----------------------

		private function mapNotifications():void {
			_injector.map( NotifyCanvasMatrixChanged ).asSingleton();
			_injector.map( RequestZoomCanvasToDefaultViewSignal ).asSingleton();
			_injector.map( RequestZoomCanvasToEaselViewSignal ).asSingleton();
			_injector.map( NotifyPaintModuleSetUpSignal ).asSingleton();
			_injector.map( NotifyPaintModuleDestroyedSignal ).asSingleton();
			_injector.map( RequestSetCanvasBackgroundSignal ).asSingleton();
			_injector.map( RequestPaintRootViewRemovalSignal ).asSingleton();

			// Map notification signals.
			_injector.map( NotifyAvailableBrushTypesSignal ).asSingleton();
			_injector.map( NotifyActivateBrushChangedSignal ).asSingleton();

			_injector.map( NotifyColorStyleModuleActivatedSignal ).asSingleton();
			_injector.map( NotifySetColorStyleSignal ).asSingleton();
			_injector.map( NotifyColorStylePresetsAvailableSignal ).asSingleton();
			_injector.map( NotifyColorStyleChangedSignal ).asSingleton();
			_injector.map( NotifyColorStyleConfirmSignal ).asSingleton();
			_injector.map( RequestColorStyleMatrixChangedSignal ).asSingleton();

			_injector.map( NotifyNavigationHideSignal ).asSingleton();

			_injector.map( NotifyHistoryStackChangedSignal ).asSingleton();

			_injector.map( NotifyGyroscopeUpdateSignal ).asSingleton();
			_injector.map( NotifyGlobalAccelerometerSignal ).asSingleton();

			_injector.map( RequestChangeRenderRectSignal ).asSingleton();
		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {

			_commandMap.map( RequestCanvasExportSignal ).toCommand( ExportCanvasCommand );
			_commandMap.map( RequestPaintingSaveSignal ).toCommand( SavePaintingCommand );
			_commandMap.map( RequestPaintingDeletionSignal ).toCommand( DeletePaintingCommand );
			_commandMap.map( RequestSetupPaintModuleSignal ).toCommand( SetupPaintModuleCommand );
			_commandMap.map( RequestDestroyPaintModuleSignal ).toCommand( DestroyPaintModuleCommand );

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
			_mediatorMap.map( EditBrushSubNavView ).toMediator( EditBrushSubNavViewMediator );
			_mediatorMap.map( SelectBrushSubNavView ).toMediator( SelectBrushSubNavViewMediator );
			_mediatorMap.map( SelectColorSubNavView ).toMediator( SelectColorSubNavViewMediator );
			_mediatorMap.map( CanvasSubNavView ).toMediator( CanvasSubNavViewMediator );
			_mediatorMap.map( CanvasView ).toMediator( CanvasViewMediator );
			_mediatorMap.map( PaintRootView ).toMediator( PaintRootViewMediator );
		}
	}
}
