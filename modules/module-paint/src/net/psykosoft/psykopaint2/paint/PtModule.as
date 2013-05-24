package net.psykosoft.psykopaint2.paint
{

	import com.junkbyte.console.Cc;

	import flash.display.DisplayObjectContainer;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.utils.BsStackUtil;

	import net.psykosoft.psykopaint2.core.CrModule;
	import net.psykosoft.psykopaint2.core.config.CrSettings;
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

	public class PtModule extends Sprite
	{
		private var _renderSignal:Signal;
		private var _time:Number = 0;
		private var _textField:TextField;
		private var _fpsStackUtil:BsStackUtil;
		private var _renderTimeStackUtil:BsStackUtil;
		private var _crModule:CrModule;

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
			// Request the core and wait for its initialization.
			// It is async because it loads assets, loads stage3d, etc...
			_crModule = new CrModule();
			_crModule.moduleReadySignal.addOnce( onCoreModuleReady );
			addChild( _crModule );
		}

		private function onCoreModuleReady( coreInjector:Injector ):void {
			Cc.log( this, "core module is ready, injector: " + coreInjector );

			initStats();
			new DrawingCore( coreInjector ); // All needed to init the drawing core.

			// Initialize the paint module.
			var config:PtConfig = new PtConfig( coreInjector );
			_renderSignal = config.injector.getInstance( PtRequestRenderFrameSignal ); // Necessary for rendering the core on enter frame.

			_crModule.addChild( new PtRootView() ); // Initialize display tree.

			config.injector.getInstance( PtRequestDrawingCoreStartupSignal ).dispatch(); // Ignite drawing core, causes first "real" application states...

			addEventListener( Event.ENTER_FRAME, onEnterFrame ); // Start enterframe.

			moduleReadySignal.dispatch( coreInjector ); // Notify potential super modules.
		}

		// TODO: remove
		private function initStats():void {
			_fpsStackUtil = new BsStackUtil();
			_renderTimeStackUtil = new BsStackUtil();
			_fpsStackUtil.count = 24;
			_renderTimeStackUtil.count = 24;
			_textField = new TextField();
			_textField.width = 200;
			_textField.selectable = false;
			_textField.mouseEnabled = false;
			_textField.scaleX = _textField.scaleY = CrSettings.RUNNING_ON_RETINA_DISPLAY ? 2 : 1;
			addChild( _textField );
		}

		// ---------------------------------------------------------------------
		// Loop.
		// ---------------------------------------------------------------------

		private function update():void {
			_renderSignal.dispatch();
		}

		// TODO: remove
		private function updateStats():void {
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
