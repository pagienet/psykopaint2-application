package net.psykosoft.psykopaint2.core.views.debug
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.utils.misc.StackUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.rendering.ApplicationRenderer;

	public class DebugView extends Sprite
	{
		private var _statsTextField:TextField;
		private var _versionTextField:TextField;
		private var _memoryIcon:TextField;
		private var _memoryIconTimer:Timer;
		private var _memoryWarningCount:uint;
		private var _fpsStackUtil:StackUtil;
		private var _renderTimeStackUtil:StackUtil;

		private var _fps:Number = 0;
		private var _time:Number = 0;

		public function DebugView() {
			super();

			initVersionDisplay();
			initStats();
			initMemoryWarningDisplay();

			// Start enterframe.
			if( CoreSettings.SHOW_STATS || CoreSettings.SHOW_MEMORY_USAGE )
				addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}

		public function refreshVersion():void {
			if( _versionTextField ) {
				var resMsg:String = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? "2048x1536" : "1024x768";
				_versionTextField.text = CoreSettings.NAME + ", " + resMsg + ", version: " + CoreSettings.VERSION;
			}
		}

		public function flashMemoryIcon():void {
			if( !_memoryIconTimer ) {
				_memoryIconTimer = new Timer( 5000, 1 );
				_memoryIconTimer.addEventListener( TimerEvent.TIMER, onMemoryIconTimerTick );
			}
			_memoryWarningCount++;
			_memoryIcon.text = "MEMORY WARNING: " + _memoryWarningCount;
			_memoryIconTimer.start();
			_memoryIcon.visible = true;
		}

		private function initMemoryWarningDisplay():void {
			if( !CoreSettings.SHOW_MEMORY_WARNINGS ) return;
			_memoryIcon = new TextField();
			_memoryIcon.name = "memory text field";
			_memoryIcon.selectable = _memoryIcon.mouseEnabled = false;
			_memoryIcon.scaleX = _memoryIcon.scaleY = CoreSettings.GLOBAL_SCALING;
			_memoryIcon.textColor = 0xFF0000;
			_memoryIcon.width = 200;
			_memoryIcon.height = 25;
			_memoryIcon.y = CoreSettings.GLOBAL_SCALING * 40;
			addChild( _memoryIcon );
		}

		private function initStats():void {
			if( !CoreSettings.SHOW_STATS ) return;
			_fpsStackUtil = new StackUtil();
			_renderTimeStackUtil = new StackUtil();
			_fpsStackUtil.count = 24;
			_renderTimeStackUtil.count = 24;
			_statsTextField = new TextField();
			_statsTextField.name = "stats text field";
			_statsTextField.width = 200;
			_statsTextField.selectable = false;
			_statsTextField.mouseEnabled = false;
			_statsTextField.scaleX = _statsTextField.scaleY = CoreSettings.GLOBAL_SCALING;
			addChild( _statsTextField );
		}

		private function initVersionDisplay():void {
			if( CoreSettings.SHOW_VERSION ) {
				_versionTextField = new TextField();
				_versionTextField.name = "version text field";
				_versionTextField.scaleX = _versionTextField.scaleY = CoreSettings.GLOBAL_SCALING;
				_versionTextField.width = 250;
				_versionTextField.mouseEnabled = _versionTextField.selectable = false;
				_versionTextField.y = CoreSettings.GLOBAL_SCALING * 50;
				addChild( _versionTextField );
			}
		}

		private function evalFPS():void {
			var oldTime:Number = _time;
			_time = getTimer();
			_fps = 1000 / (_time - oldTime);
			_fpsStackUtil.pushValue( _fps );
			_fps = int( _fpsStackUtil.getAverageValue() );
//			trace( ">>> fps: " + _fps );
		}

		private function updateStats():void {
			if( !CoreSettings.SHOW_STATS ) return;
			_renderTimeStackUtil.pushValue( ApplicationRenderer.renderTime );
			var renderTime:int = int( _renderTimeStackUtil.getAverageValue() );
			_statsTextField.text = _fps + "/" + stage.frameRate + "fps \n" + "Render time: " + renderTime + "ms\n" +
									( CoreSettings.SHOW_MEMORY_USAGE ? "Memory usage: " + uint(System.privateMemory/1024)/1024 + "MB" : "");
		}

		private function onMemoryIconTimerTick( event:TimerEvent ):void {
			_memoryIconTimer.reset();
			_memoryIcon.visible = false;
		}

		private function onEnterFrame( event:Event ):void {
			evalFPS();
			updateStats();
		}
	}
}
