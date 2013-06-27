package net.psykosoft.psykopaint2.paint.config
{

	import net.psykosoft.psykopaint2.core.signals.RequestPaintingLoadSignal;
	import net.psykosoft.psykopaint2.paint.commands.ExportCanvasCommand;
	import net.psykosoft.psykopaint2.paint.commands.GoToHomeWithCanvasSnapShotCommand;
	import net.psykosoft.psykopaint2.paint.commands.LoadPaintingCommand;
	import net.psykosoft.psykopaint2.paint.commands.SavePaintingCommand;
	import net.psykosoft.psykopaint2.paint.commands.SetSourceImageCommand;
	import net.psykosoft.psykopaint2.paint.commands.SetSurfaceImageCommand;
	import net.psykosoft.psykopaint2.paint.commands.StartUpDrawingCoreCommand;
	import net.psykosoft.psykopaint2.paint.commands.UpdateAppStateFromActivatedDrawingCoreModuleCommand;
	import net.psykosoft.psykopaint2.paint.signals.RequestCanvasExportSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestDrawingCoreStartupSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestGoToHomeWithCanvasSnapshotSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingSaveSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSourceImageSetSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestStateUpdateFromModuleActivationSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSurfaceImageSetSignal;
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
	import net.psykosoft.psykopaint2.paint.views.pick.image.PickAnImageView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.PickAnImageViewMediator;
	import net.psykosoft.psykopaint2.paint.views.pick.surface.PickASurfaceSubNavView;
	import net.psykosoft.psykopaint2.paint.views.pick.surface.PickASurfaceSubNavViewMediator;
	
	import org.swiftsuspenders.Injector;
	
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;

	public class PaintConfig
	{
		private var _injector:Injector;
		private var _mediatorMap:IMediatorMap;
		private var _commandMap:ISignalCommandMap;

		public function PaintConfig( injector:Injector ) {
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
			_commandMap.map( RequestStateUpdateFromModuleActivationSignal ).toCommand( UpdateAppStateFromActivatedDrawingCoreModuleCommand );
			_commandMap.map( RequestSourceImageSetSignal ).toCommand( SetSourceImageCommand );
			_commandMap.map( RequestDrawingCoreStartupSignal ).toCommand( StartUpDrawingCoreCommand );
			_commandMap.map( RequestSurfaceImageSetSignal ).toCommand( SetSurfaceImageCommand );
			_commandMap.map( RequestCanvasExportSignal ).toCommand( ExportCanvasCommand );
			_commandMap.map( RequestPaintingSaveSignal ).toCommand( SavePaintingCommand );
			_injector.unmap( RequestPaintingLoadSignal ); // Mapped in the core as singleton for compatibility.
			_commandMap.map( RequestPaintingLoadSignal ).toCommand( LoadPaintingCommand );
			_commandMap.map( RequestGoToHomeWithCanvasSnapshotSignal ).toCommand( GoToHomeWithCanvasSnapShotCommand );
			
			
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
			_mediatorMap.map( PickAnImageView ).toMediator( PickAnImageViewMediator );
			_mediatorMap.map( PickASurfaceSubNavView ).toMediator( PickASurfaceSubNavViewMediator );
		}
	}
}
