package net.psykosoft.psykopaint2.paint
{

	import com.junkbyte.console.Cc;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.utils.BsStackUtil;

	import net.psykosoft.psykopaint2.core.CrModule;
	import net.psykosoft.psykopaint2.core.drawing.DrawingCore;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.paint.commands.PtRenderFrameCommand;
	import net.psykosoft.psykopaint2.paint.config.PtConfig;
	import net.psykosoft.psykopaint2.paint.config.PtConfig;
	import net.psykosoft.psykopaint2.paint.signals.requests.PtRequestDrawingCoreStartupSignal;
	import net.psykosoft.psykopaint2.paint.signals.requests.PtRequestRenderFrameSignal;
	import net.psykosoft.psykopaint2.paint.views.base.PtRootView;

	import org.osflash.signals.Signal;

	import org.swiftsuspenders.Injector;

	// TODO: link core's nav view show hide signal to a request of canvas resize
	// TODO: fix linkage bug in PtConfig

	public class PtModule extends Sprite
	{
		private var _renderSignal:Signal;
		private var _time:Number = 0;
		private var _textField:TextField;
		private var _fpsStackUtil:BsStackUtil;
		private var _renderTimeStackUtil:BsStackUtil;

		public var moduleReadySignal:Signal;

		public function PtModule() {
			super();
			trace( ">>>>> PtModule starting..." );
			moduleReadySignal = new Signal();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		// ---------------------------------------------------------------------
		// Initialization.
		// ---------------------------------------------------------------------

		private function initialize():void {
			var coreModule:CrModule = new CrModule();
			coreModule.moduleReadySignal.addOnce( onCoreModuleReady );
			addChild( coreModule );
		}

		private function onCoreModuleReady( coreInjector:Injector ):void {
			Cc.log( this, "core module is ready, injector: " + coreInjector );

			// Initialize paint module.
			var config:PtConfig = new PtConfig( this, coreInjector );
			_renderSignal = config.injector.getInstance( PtRequestRenderFrameSignal );
			config.injector.getInstance( PtRequestDrawingCoreStartupSignal ).dispatch();

			// Initialize drawing core.
			new DrawingCore( coreInjector );

			// Initialize display tree.
			addChild( new PtRootView() );

			// Start enterframe.
			addEventListener( Event.ENTER_FRAME, onEnterFrame );

			// Notify.
			moduleReadySignal.dispatch( coreInjector );
		}

		// ---------------------------------------------------------------------
		// Loop.
		// ---------------------------------------------------------------------

		private function update():void {

			_renderSignal.dispatch();

			var oldTime:Number = _time;
			_time = getTimer();

			var fps:Number = 1000 / (_time - oldTime);
			_fpsStackUtil.pushValue( fps );
			fps = int( _fpsStackUtil.getAverageValue() );

			_renderTimeStackUtil.pushValue( PtRenderFrameCommand.renderTime );
			var renderTime:int = int( _renderTimeStackUtil.getAverageValue() );

			_textField.text = fps + "\n" + "Render time: " + renderTime + "ms";
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onEnterFrame( event:Event ):void {
			update();
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			initialize();
		}
	}
}
