package net.psykosoft.psykopaint2.paint.configuration
{

	import net.psykosoft.psykopaint2.core.commands.ClearCanvasCommand;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasMatrixChanged;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreResetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreSourceImageSetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreSurfaceSetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintingActivationSignal;
	import net.psykosoft.psykopaint2.paint.commands.ActivatePaintingCommand;
	import net.psykosoft.psykopaint2.paint.commands.DeletePaintingCommand;
	import net.psykosoft.psykopaint2.paint.commands.ExportCanvasCommand;
	import net.psykosoft.psykopaint2.paint.commands.SavePaintingCommand;
	import net.psykosoft.psykopaint2.paint.commands.SetSourceImageCommand;
	import net.psykosoft.psykopaint2.paint.commands.SetSurfaceImageCommand;
	import net.psykosoft.psykopaint2.paint.commands.StartUpDrawingCoreCommand;
	import net.psykosoft.psykopaint2.paint.commands.UpdateAppStateFromActivatedDrawingCoreModuleCommand;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCameraFlipRequest;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCameraSnapshotRequest;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintingSavedSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestCanvasExportSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestDrawingCoreStartupSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingDeletionSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingSaveSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSourceImageSetSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestStateUpdateFromModuleActivationSignal;
	import net.psykosoft.psykopaint2.paint.views.brush.EditBrushSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.EditBrushSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectBrushSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectBrushSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasSubNavView;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasView;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasViewMediator;
	import net.psykosoft.psykopaint2.paint.views.color.ColorStyleSubNavView;
	import net.psykosoft.psykopaint2.paint.views.color.ColorStyleSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.color.ColorStyleView;
	import net.psykosoft.psykopaint2.paint.views.color.ColorStyleViewMediator;
	import net.psykosoft.psykopaint2.paint.views.crop.CropSubNavView;
	import net.psykosoft.psykopaint2.paint.views.crop.CropSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.crop.CropView;
	import net.psykosoft.psykopaint2.paint.views.crop.CropViewMediator;
	import net.psykosoft.psykopaint2.paint.views.pick.image.CaptureImageSubNavView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.CaptureImageSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.pick.image.CaptureImageView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.CaptureImageViewMediator;
	import net.psykosoft.psykopaint2.paint.views.pick.image.ConfirmCaptureImageSubNavView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.ConfirmCaptureImageSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.pick.image.PickASampleImageSubNavView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.PickASampleImageSubNavViewMediator;
	import net.psykosoft.psykopaint2.paint.views.pick.image.PickAUserImageView;
import net.psykosoft.psykopaint2.paint.views.pick.image.PickAUserImageViewMediator;
import net.psykosoft.psykopaint2.paint.views.pick.image.PickAnImageSubNavView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.PickAnImageSubNavViewMediator;

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

		}

		// -----------------------
		// Notifications.
		// -----------------------

		private function mapNotifications():void {
			_injector.map( NotifyCameraSnapshotRequest ).asSingleton();
			_injector.map( NotifyCameraFlipRequest ).asSingleton();
			_injector.map( NotifyPaintingSavedSignal ).asSingleton();
			_injector.map( NotifyCanvasMatrixChanged ).asSingleton();
		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {
			_commandMap.map( RequestStateUpdateFromModuleActivationSignal ).toCommand( UpdateAppStateFromActivatedDrawingCoreModuleCommand );
			_commandMap.map( RequestSourceImageSetSignal ).toCommand( SetSourceImageCommand );
			_commandMap.map( RequestDrawingCoreStartupSignal ).toCommand( StartUpDrawingCoreCommand );
			_commandMap.map( RequestCanvasExportSignal ).toCommand( ExportCanvasCommand );
			_commandMap.map( RequestPaintingSaveSignal ).toCommand( SavePaintingCommand );
			_commandMap.map( RequestPaintingDeletionSignal ).toCommand( DeletePaintingCommand );

			// Mapped in the core as singleton for compatibility and remapped here.
			_injector.unmap( RequestPaintingActivationSignal );
			_commandMap.map( RequestPaintingActivationSignal ).toCommand( ActivatePaintingCommand );
			_injector.unmap( RequestDrawingCoreResetSignal );
			_commandMap.map( RequestDrawingCoreResetSignal ).toCommand( ClearCanvasCommand );
			_injector.unmap( RequestDrawingCoreSurfaceSetSignal );
			_commandMap.map( RequestDrawingCoreSurfaceSetSignal ).toCommand( SetSurfaceImageCommand );
			_injector.unmap( RequestDrawingCoreSourceImageSetSignal );
			_commandMap.map( RequestDrawingCoreSourceImageSetSignal ).toCommand( SetSourceImageCommand );
		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators():void {
			_mediatorMap.map( EditBrushSubNavView ).toMediator( EditBrushSubNavViewMediator );
			_mediatorMap.map( SelectBrushSubNavView ).toMediator( SelectBrushSubNavViewMediator );
			_mediatorMap.map( CanvasSubNavView ).toMediator( CanvasSubNavViewMediator );
			_mediatorMap.map( CanvasView ).toMediator( CanvasViewMediator );
			_mediatorMap.map( ColorStyleSubNavView ).toMediator( ColorStyleSubNavViewMediator );
			_mediatorMap.map( ColorStyleView ).toMediator( ColorStyleViewMediator );
			_mediatorMap.map( CropSubNavView ).toMediator( CropSubNavViewMediator );
			_mediatorMap.map( CropView ).toMediator( CropViewMediator );
			_mediatorMap.map( PickAnImageSubNavView ).toMediator( PickAnImageSubNavViewMediator );
			_mediatorMap.map( PickAUserImageView ).toMediator( PickAUserImageViewMediator );
			_mediatorMap.map( PickASampleImageSubNavView ).toMediator( PickASampleImageSubNavViewMediator );
			_mediatorMap.map( CaptureImageSubNavView ).toMediator( CaptureImageSubNavViewMediator );
			_mediatorMap.map( ConfirmCaptureImageSubNavView ).toMediator( ConfirmCaptureImageSubNavViewMediator );
			_mediatorMap.map( CaptureImageView ).toMediator( CaptureImageViewMediator );
		}
	}
}
