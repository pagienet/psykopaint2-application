package net.psykosoft.psykopaint2.core.drawing.config
{

	import flash.display.DisplayObjectContainer;

	import net.psykosoft.psykopaint2.core.commands.ClearCanvasCommand;
	import net.psykosoft.psykopaint2.core.commands.UndoCanvasActionCommand;
	import net.psykosoft.psykopaint2.core.controllers.GyroscopeLightController;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.BrushShapeLibrary;
	import net.psykosoft.psykopaint2.core.drawing.modules.ColorStyleModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.CropModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
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
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStylePresetsAvailableSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalAccelerometerSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGyroscopeUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyHistoryStackChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationHideSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySetColorStyleSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestClearCanvasSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestColorStyleMatrixChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSaveCPUForUISignal;
	import net.psykosoft.psykopaint2.core.signals.RequestResumeCPUUsageForUISignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUndoSignal;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.bundles.mvcs.MVCSBundle;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IInjector;
	import robotlegs.bender.framework.impl.Context;

	public class DrawingCoreConfig
	{
		private var _childContext : IContext;
		private var _injector : IInjector;
		private var _mediatorMap : IMediatorMap;
		private var _commandMap : ISignalCommandMap;

		public function DrawingCoreConfig(childDisplay : DisplayObjectContainer, injector : IInjector)
		{

			trace(this);

			_childContext = new Context();
			_childContext.install(MVCSBundle);
			_childContext.configure(new ContextView(childDisplay));

			_injector = injector;
			_mediatorMap = _injector.getInstance(IMediatorMap);
			_commandMap = _injector.getInstance(ISignalCommandMap);

			// Map notification signals.
			_injector.map( NotifyModuleActivatedSignal ).asSingleton();
			_injector.map( NotifyAvailableBrushTypesSignal ).asSingleton();
			_injector.map( NotifyActivateBrushChangedSignal ).asSingleton();

			_injector.map( NotifyCropCompleteSignal ).asSingleton();
			_injector.map( NotifyCropModuleActivatedSignal ).asSingleton();

			_injector.map( NotifyColorStyleModuleActivatedSignal ).asSingleton();
			_injector.map( NotifySetColorStyleSignal ).asSingleton();
			_injector.map( NotifyColorStylePresetsAvailableSignal ).asSingleton();
			_injector.map( NotifyColorStyleChangedSignal ).asSingleton();
			_injector.map( NotifyColorStyleConfirmSignal ).asSingleton();
			_injector.map( RequestColorStyleMatrixChangedSignal ).asSingleton();

			_injector.map( NotifyNavigationHideSignal ).asSingleton();

			_injector.map( NotifyPaintModuleActivatedSignal ).asSingleton();
			_injector.map( NotifyHistoryStackChangedSignal ).asSingleton();

			_injector.map( NotifyGyroscopeUpdateSignal ).asSingleton();
			_injector.map( NotifyGlobalAccelerometerSignal ).asSingleton();

			_injector.map( RequestSaveCPUForUISignal ).asSingleton();
			_injector.map( RequestResumeCPUUsageForUISignal ).asSingleton();
			_injector.map( RequestChangeRenderRectSignal ).asSingleton();

			// Map singletons
			_injector.map(GyroscopeManager).asSingleton();
			_injector.map(AccelerometerManager).asSingleton();
			_injector.map(WacomPenManager).asSingleton();
			_injector.map(GyroscopeLightController).asSingleton();
			_injector.map(BrushShapeLibrary).asSingleton();
			_injector.map(PaintModule).asSingleton();
			_injector.map(CropModule).asSingleton();
			_injector.map(ColorStyleModule).asSingleton();
			_injector.map(ModuleManager).asSingleton();

			_injector.map(CanvasRenderer).asSingleton();
			_injector.map(LightingModel).asSingleton();
			_injector.map(CanvasModel).asSingleton();
			_injector.map(CanvasHistoryModel).asSingleton();

			_injector.map(RubberMeshRenderer).asSingleton();
			_injector.map(RubberMeshModel).asSingleton();
			
			// todo: add RubberMeshHistoryModel again when used (disabled for better memory containment):
//			_injector.map(RubberMeshHistoryModel).asSingleton();

			// map signals to commands
			_commandMap.map(RequestClearCanvasSignal).toCommand(ClearCanvasCommand);
//			_commandMap.map(RequestResizeCanvasSignal).toCommand(ResizeCanvasCommand);
			_commandMap.map(RequestUndoSignal).toCommand(UndoCanvasActionCommand);

		}

		public function get injector():IInjector {
			return _injector;
		}
	}
}