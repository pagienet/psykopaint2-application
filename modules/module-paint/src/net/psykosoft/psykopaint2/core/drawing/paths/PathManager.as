package net.psykosoft.psykopaint2.core.drawing.paths
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.configuration.CoreConfig;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ConditionalDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.EndConditionalDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.IPointDecorator;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.managers.pen.WacomPenManager;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;

	final public class PathManager
	{
		public static const ENGINE_TYPE_BASIC:int = 0;
		public static const ENGINE_TYPE_CATMULL:int = 1;
		public static const ENGINE_TYPE_EXPERIMENTAL:int = 2;
		
		
		private static var _engineDepot : Vector.<Vector.<IPathEngine>> = Vector.<Vector.<IPathEngine>>([new Vector.<IPathEngine>(),new Vector.<IPathEngine>(),new Vector.<IPathEngine>()]);
		private static var _samplePointDepot : Vector.<SamplePoint> = new Vector.<SamplePoint>(500);
		private static var _recycleCount:int = 0;
		
		
		static public function getPathEngine( type:int ) : IPathEngine
		{
			if (_engineDepot[type].length > 0) {
				return _engineDepot[type].pop();
			} else {
				if ( type == 0 )
				{
					return new PathEngineBasic();
				} else if ( type == 1) 
				{
					return new PathEngineCatmull();
				} else if ( type == 2)
				{
					return new PathEngineExperimental();
				}
				return null;
			}
		}

		static public function getSamplePoint( x: Number, y:Number, speed : Number = 0, size:Number = 0, angle:Number = 0, pressure:Number = -1, penButtonState:int = 0, colors:Vector.<Number> = null, bumpFactors:Vector.<Number> = null, first:Boolean = false) : SamplePoint
		{
			if (_recycleCount > 0) {
				var p : SamplePoint = _samplePointDepot[--_recycleCount];
				return p.resetData(x, y, speed, size, angle, pressure, penButtonState, colors, bumpFactors, first);
			} else {
				
				return new SamplePoint(x, y,  speed, size, angle, pressure, penButtonState, colors, bumpFactors, first);
			}
		}

		static public function recyclePathEngine(value : IPathEngine) : void
		{
			value.clear();
			_engineDepot[value.type].push(value);

		}

		static public function recycleSamplePoints(value : Vector.<SamplePoint>) : void
		{
			for ( var i:int =  value.length; --i > -1; )
			{
				_samplePointDepot[_recycleCount++] = value[i];
			}
			value.length = 0;
		}

		static public function recycleSamplePoint(value:SamplePoint):void
		{
			_samplePointDepot[_recycleCount++] = value;
		}

		
		
		private var _view : DisplayObject;
		private var _active : Boolean;
		private var _pathEngine : IPathEngine;
		private var _callbacks : PathManagerCallbackInfo;
		private var _accumulatedResults:Vector.<SamplePoint>;
		private var _touchID : int;
		private var _pointDecorators : Vector.<IPointDecorator>;
		private var _brushAngleRange:Number = Math.PI;
		public var canvasModel:CanvasModel;

		
		private var _startCallbacksSent : Boolean;
		
		private var _canvasScaleX:Number;
		private var _canvasScaleY:Number;
		private var _canvasOffsetX:Number;
		private var _canvasOffsetY:Number;
		private var recordedData:Vector.<Number>;
		private var playbackActive:Boolean;
		private var singleStepPlaybackActive:Boolean;
		
		private var playbackIndex:int;
		private var playbackOffset:int;
		private var playBackOffsetX:Number;
		private var playBackOffsetY:Number;
		
		private var gestureStopTimeout:int;
		private var GESTURE_RECOGNITION_TIME:Number = 500;
		private var renderer:CanvasRenderer;
		private const _applyArray:Array = [];
			
		//private var twoFingerGestureTimeout:int
		//private var singleTouchBeginEvent:TouchEvent;
		private var _strokeInProgress:Boolean;
		private var _key1isDown:Boolean;
		private var _key2isDown:Boolean;
		
		public function PathManager( type:int )
		{
			_pathEngine = getPathEngine( type );
			_accumulatedResults = new Vector.<SamplePoint>();
			_pointDecorators = new Vector.<IPointDecorator>();
			
			
			//FOR DEBUGGING ONLY:
			if (!CoreSettings.RUNNING_ON_iPAD ) recordedData = new Vector.<Number>();
		}
		
		public function set minSamplesPerStep( value:int ):void
		{
			_pathEngine.minSamplesPerStep.intValue = value;
		}
		
		public function set outputStepSize( value:Number ):void
		{
			_pathEngine.outputStepSize.numberValue = value;
		}
		
		public function set brushAngleRange( value:Number ):void
		{
			_brushAngleRange = value;
		}
		
		public function get brushAngleRange():Number
		{
			return _brushAngleRange;
		}

		public function setCallbacks( callbackObject : Object, onPathPoints : Function, onPathStart : Function = null, onPathEnd : Function = null, onPickColor : Function = null) : void
		{
			_callbacks = new PathManagerCallbackInfo(callbackObject, onPathPoints, onPathStart, onPathEnd, onPickColor );
		}

		public function clearCallbacks() : void
		{
			_callbacks = null
		}
		
		public function removeAllPointDecorators():void
		{
			_pointDecorators.length = 0;
		}
		
		public function addPointDecorator( decorator:IPointDecorator ):void
		{
			_pointDecorators.push( decorator );
		}
		
		public function removePointDecorator( decorator:IPointDecorator ):void
		{
			var idx:int = _pointDecorators.indexOf( decorator );
			if ( idx != -1 ) _pointDecorators.splice(idx,1);
		}

		protected function sendPointsCallbacks(points : Vector.<SamplePoint>) : void
		{
			if(_callbacks.onPathPoints) {
				_applyArray[0] = points;
				_callbacks.onPathPoints.apply(_callbacks.callbackObject, _applyArray );
				PathManager.recycleSamplePoints(points);
			}
		}

		protected function sendStartCallbacks() : void
		{
			_startCallbacksSent = true;
			if (_callbacks.onPathStart) _callbacks.onPathStart.apply(_callbacks.callbackObject);
		}

		protected function sendEndCallbacks() : void
		{
			if (!_strokeInProgress) _view.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame, false );
		
			if (_startCallbacksSent && _callbacks.onPathEnd) _callbacks.onPathEnd.apply(_callbacks.callbackObject);
			_startCallbacksSent = false;
			
			
		}

		protected function onEnterFrame(event : Event) : void
		{
			if ( playbackActive && event != null )
			{
				if ( playbackIndex == 0 )
				{
					onSampleStart(recordedData[playbackIndex+1] + playBackOffsetX,recordedData[playbackIndex+2]+ playBackOffsetY);
					playbackIndex += 3;
				} 
				
				while ( playbackIndex < recordedData.length )
				{
					if ( getTimer() - playbackOffset < recordedData[playbackIndex] ) break;
					
					if ( playbackIndex == recordedData.length - 3 )
					{
						onSampleEnd(recordedData[playbackIndex+1]+ playBackOffsetX,recordedData[playbackIndex+2]+ playBackOffsetY);
						playbackActive = false;
					} else {
						onSamplePoint(recordedData[playbackIndex+1]+ playBackOffsetX,recordedData[playbackIndex+2]+ playBackOffsetY);
					}
					playbackIndex += 3;
				} 
			}
			
			updateDecorators();
			
			if ( _accumulatedResults.length > 0 )
			{
				sendPointsCallbacks(_accumulatedResults);
				_accumulatedResults.length = 0;
			}
			
			if (!playbackActive && !singleStepPlaybackActive && !_strokeInProgress && !hasActiveDecorators() )
			{
				sendEndCallbacks();
			}
			
		}

		protected function onTouchBegin(event : TouchEvent) : void
		{
			
			//Navbar touched?
			var stage : Stage = event.target as Stage;
			if (!stage) return;
			
			if (_touchID == -1) {
				_strokeInProgress = true;
				_touchID = event.touchPointID;
				/*
				singleTouchBeginEvent = event;
				twoFingerGestureTimeout = setTimeout( onSingleTouchBegin, 40 );
				*/
				onSingleTouchBegin(event);
			}
			/*
			else {
				clearTimeout(twoFingerGestureTimeout);
				_strokeInProgress = false;
				_touchID = -1;
			}
			*/
		}
		
		protected function onSingleTouchBegin( event : TouchEvent ) : void
		{
			//clearTimeout(twoFingerGestureTimeout);
			_view.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 10000 );
			
			_view.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			_view.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			
			onSampleStart(event.stageX, event.stageY);
		
		}
		
		// for purposes of le debug
		protected function onMouseDown(event : MouseEvent) : void
		{
			
			var stage : Stage = event.target as Stage;
			if (!stage) {
				//DisplayObject(event.target).transform.colorTransform = new ColorTransform(-1,-1,-1,1,255,255,255);
				return;
			}
			
			_view.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 10000 );
			_strokeInProgress = true;
			
			//TEMPORARY RECORDING FOR TESTS:
			playbackActive = false;
			singleStepPlaybackActive = false;
			playbackOffset = getTimer();
			
			if ( !CoreSettings.RUNNING_ON_iPAD )
			{
				recordedData.length = 0;
				recordedData.push(getTimer() - playbackOffset,event.stageX, event.stageY);
			} 
			
			onSampleStart(event.stageX, event.stageY);
			_view.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_view.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function onTouchEnd(event : TouchEvent) : void
		{
			if ( event.touchPointID == _touchID ) 
			{
				//clearTimeout(twoFingerGestureTimeout);
				enableGestureRecognition(true);
				_strokeInProgress = false;
				onSampleEnd(event.stageX, event.stageY);
				_view.stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
				_view.stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
				_touchID = -1;
			}
		}

		protected function onMouseUp(event : MouseEvent) : void
		{
			_strokeInProgress = false;
			enableGestureRecognition(true);
			if ( !CoreSettings.RUNNING_ON_iPAD && !playbackActive )
			{
				recordedData.push(getTimer() - playbackOffset,event.stageX, event.stageY);
			}
			onSampleEnd(event.stageX, event.stageY);
			_view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_view.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function onTouchMove(event : TouchEvent) : void
		{
			if (event.touchPointID == _touchID)
			{
				//onSingleTouchBegin();
				if ( gestureStopTimeout == -1 && GestureManager.gesturesEnabled ) gestureStopTimeout = setTimeout(enableGestureRecognition,GESTURE_RECOGNITION_TIME,false);
				onSamplePoint(event.stageX, event.stageY);
			}
		}

		private function onMouseMove(event : MouseEvent) : void
		{
			if (!CoreSettings.RUNNING_ON_iPAD && !playbackActive )
			{
				recordedData.push(getTimer() - playbackOffset,event.stageX, event.stageY);
			}
			if ( gestureStopTimeout == -1 && GestureManager.gesturesEnabled ) gestureStopTimeout = setTimeout(enableGestureRecognition,GESTURE_RECOGNITION_TIME,false);
			
			onSamplePoint(event.stageX, event.stageY);
		}

		protected function onSampleStart(stageX : Number, stageY : Number) : void
		{
			//attempt to prevent sending new start before end
			if ( _startCallbacksSent )
			{
				sendEndCallbacks();
			}

			var px : Number = stageX*_canvasScaleX + _canvasOffsetX;
			var py : Number = stageY*_canvasScaleY + _canvasOffsetY;
			
			_pathEngine.clear();
			if ( WacomPenManager.hasPen )
			{
				_pathEngine.addFirstPoint( px, py, WacomPenManager.currentPressure, WacomPenManager.buttonState);
			} else {
			 	_pathEngine.addFirstPoint( px, py, -1, (_key1isDown ? 1 : 0) | (_key2isDown ? 2 : 0));
			}
			sendStartCallbacks();
			if ( _pathEngine.sendTaps ) {
				update(true);
				onEnterFrame(null);
			}
		}

		protected function onSamplePoint(stageX : Number, stageY : Number) : void
		{
			var px : Number = stageX*_canvasScaleX + _canvasOffsetX;
			var py : Number = stageY*_canvasScaleY + _canvasOffsetY;
			
			if ( WacomPenManager.hasPen )
			{
				if ( _pathEngine.addPoint(px,py, WacomPenManager.currentPressure, WacomPenManager.buttonState) ) update();
			} else {
				if ( _pathEngine.addPoint(px,py, -1,  (_key1isDown ? 1 : 0) | (_key2isDown ? 2 : 0)) ) update();
			}
		}

		protected function onSampleEnd(stageX : Number, stageY : Number) : void
		{
			var px : Number = stageX*_canvasScaleX + _canvasOffsetX;
			var py : Number = stageY*_canvasScaleY + _canvasOffsetY;

			if ( WacomPenManager.hasPen )
				_pathEngine.addPoint( px, py, WacomPenManager.currentPressure, WacomPenManager.buttonState, true); 
			 else 
				_pathEngine.addPoint( px, py, -1,  (_key1isDown ? 1 : 0) | (_key2isDown ? 2 : 0), true); 
			update(true);
			onEnterFrame(null);
			if (!hasActiveDecorators() )
			{
				sendEndCallbacks();
			} 
			
			
		}
		
		protected function update(forceUpdate : Boolean = false) : void
		{
			_pathEngine.update( _accumulatedResults, forceUpdate )
			//_accumulatedResults = _accumulatedResults.concat( );
			//updateDecorators();
		}
		
		protected function updateDecorators() : void
		{
			
			var conditionalStack:Vector.<Vector.<SamplePoint>>;
			var inCondition:int = -1;
			for ( var i:int = 0; i < _pointDecorators.length; i++ )
			{
				if ( _pointDecorators[i].active )
				{
					if ( _pointDecorators[i] is ConditionalDecorator )
					{
						conditionalStack = _pointDecorators[i].compare( _accumulatedResults, this );
						inCondition = 0;
					} else if (  _pointDecorators[i] is EndConditionalDecorator )
					{
						inCondition++;
						if ( inCondition == 2 )
						{
							_accumulatedResults = conditionalStack[0].concat(conditionalStack[1]);
							inCondition = -1;
						}
					} else {
						if ( inCondition == -1 )
						{
							_accumulatedResults = _pointDecorators[i].process( _accumulatedResults, this, _strokeInProgress );
						} else {
							conditionalStack[inCondition] = _pointDecorators[i].process( conditionalStack[inCondition], this, _strokeInProgress );
						}
					}
				}
			}
		}

		public function activate( view : DisplayObject, canvasModel:CanvasModel, renderer : CanvasRenderer ) : void
		{
			_touchID = -1;
			_startCallbacksSent = false;
			_strokeInProgress = false;
			this.canvasModel = canvasModel;
			this.renderer = renderer;
			_view = view;
			
			if (_active) return;
			_active = true;
			
			if ( CoreSettings.RUNNING_ON_iPAD )
			{
				_view.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			} else {
				_view.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				_view.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown );
				_view.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp );
			}
			
		}
		
		protected function onKeyDown(event:KeyboardEvent):void
		{
			if ( event.keyCode == Keyboard.P )
			{
				if ( recordedData.length > 8 )
				{
					playBackOffsetX = 0;
					playBackOffsetY = 0;
					
					playbackIndex = 0;
					playbackOffset = getTimer();
					playbackActive = true;
					_view.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 10000 );
				}
			} else if ( event.keyCode == Keyboard.O )
			{
				if ( recordedData.length > 8 )
				{
					playBackOffsetX = _view.stage.mouseX - recordedData[1];
					playBackOffsetY = _view.stage.mouseY - recordedData[2];
					
					playbackIndex = 0;
					playbackOffset = getTimer();
					playbackActive = true;
					_view.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 10000 );
				}
			}else if ( event.keyCode == Keyboard.RIGHT)
			{
				playbackActive = false;
				_view.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 10000 );
				if ( recordedData.length > 8 )
				{
					if ( !singleStepPlaybackActive )
					{
						playBackOffsetX = 0;
						playBackOffsetY = 0;
						playbackIndex = 0;
						singleStepPlaybackActive = true;
						onSampleStart(recordedData[playbackIndex+1] ,recordedData[playbackIndex+2]);
						
					} else {
						if ( playbackIndex == recordedData.length - 3 )
						{
							onSampleEnd(recordedData[playbackIndex+1],recordedData[playbackIndex+2]);
							singleStepPlaybackActive = false;
						} else {
							onSamplePoint(recordedData[playbackIndex+1],recordedData[playbackIndex+2]);
						}
					}
					playbackIndex += 3;
				}
			} else if ( event.keyCode == Keyboard.NUMBER_1)
			{
				_key1isDown  = true;
			} else if ( event.keyCode == Keyboard.NUMBER_2)
			{
				_key2isDown  = true;
			}
			
		}
		
		protected function onKeyUp(event:KeyboardEvent):void
		{
			if ( event.keyCode == Keyboard.NUMBER_1)
			{
				_key1isDown  = false;
			} else if ( event.keyCode == Keyboard.NUMBER_2)
			{
				_key2isDown  = false;
			}
		}
		
		public function deactivate() : void
		{
			_active = false;
			_view.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame );

			if ( CoreSettings.RUNNING_ON_iPAD )
			{
				_view.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
				_view.stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
				_view.stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			} else {
				_view.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				_view.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				_view.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown );
				_view.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp );
			}
			enableGestureRecognition( true );
		}

		public function getParameterSetAsXML( path:Array ):XML
		{
			var result:XML = _pathEngine.getParameterSetAsXML(path);
			for ( var i:int = 0; i < _pointDecorators.length; i++ )
			{
				var subPath:Array = path.concat(["pointdecorator_"+i]);
				result.appendChild(_pointDecorators[i].getParameterSetAsXML(subPath) );
			}
			return result;
		}
		
		public function getParameterSet( vo:ParameterSetVO, showInUiOnly:Boolean ):void
		{
			
			_pathEngine.getParameterSet( vo, showInUiOnly );
			for ( var i:int = 0; i < _pointDecorators.length; i++ )
			{
				_pointDecorators[i].getParameterSet(vo, showInUiOnly);
			}
			
		}
		
		public function updateParametersFromXML(message:XML):void
		{
			for ( var j:int = message.parameter.length(); --j >-1 ;  )
			{
				var parameter:XML = message.parameter[j];
				var path:Array = String(parameter.@path).split(".");
				if ( path.length == 1 && path[0] == "pathengine" )
				{
					_pathEngine.updateParametersFromXML(message);
					delete message.parameter[j];
				} else if ( path.length == 2 && path[1].indexOf("pointdecorator") == 0 )
				{
					_pointDecorators[int(path[1].split("_")[1])].updateParametersFromXML(message);
					delete message.parameter[j];
				}
			}
		}
		
		public function removePointDecoratorAt(index:int):void
		{
			_pointDecorators.splice(index,1);
			
		}
		
		public function movePointDecorator(oldIndex:int, newIndex:int):void
		{
			var decorator:IPointDecorator = _pointDecorators.splice(oldIndex,1)[0];
			_pointDecorators.splice(newIndex,0,decorator);
		}
		
		public function hasActiveDecorators():Boolean
		{
			for ( var i:int = 0; i < _pointDecorators.length; i++ )
			{
				if (_pointDecorators[i].hasActivePoints() ) return true
			}
			return false;
		}
		
		public function stopActiveDecorators():void
		{
			for ( var i:int = 0; i < _pointDecorators.length; i++ )
			{
				_pointDecorators[i].clearActivePoints();
			}
		}
		
		public function stopProgression():void
		{
			if ( hasActiveDecorators() )
			{
				stopActiveDecorators();
				sendEndCallbacks();
			}
		}
		
		public function get callbacks():PathManagerCallbackInfo
		{
			return _callbacks;
		}

		public function setCanvasMatrix(matrix : Matrix) : void
		{
			if (!matrix) {
				_canvasScaleX = _canvasScaleY = 1;
				_canvasOffsetX = _canvasOffsetY = 0;
			}
			else {
				matrix = matrix.clone();
				matrix.invert();
				_canvasScaleX = matrix.a;
				_canvasScaleY = matrix.d;
				_canvasOffsetX = matrix.tx * CoreSettings.STAGE_WIDTH;
				_canvasOffsetY = matrix.ty * CoreSettings.STAGE_HEIGHT;
				trace ("scale:", _canvasScaleX, _canvasScaleY);
				trace ("offset:", _canvasOffsetX, _canvasOffsetY);
			}
		}
		
		public function getParameterByPath(path:Array):PsykoParameter
		{
			if ( path.length == 2 && path[0] == "pathengine" )
			{
				return _pathEngine.getParameterByPath(path);
			} else if ( path.length > 1 && path[1].indexOf("pointdecorator") == 0 )
			{
				var parameter:PsykoParameter = _pointDecorators[int(path[1].split("_")[1])].getParameterByPath(path);
				if ( parameter != null ) return parameter;
			}
			throw("PathManager.getParameterByPath parameter not found: "+path.join("."));
			return null;
		}
		
		public function getDecoratorByPath(path:String):IPointDecorator
		{
			var index:int = int(path.split(".").pop().split("_")[1]);
			if ( index >= _pointDecorators.length ) throw("PathManager.getDecoratorByPath decorator not found: "+path);
			
			return _pointDecorators[index];
		}
		
		public function get strokeInProgress():Boolean
		{
			return _startCallbacksSent;
		}
			
		
		private function enableGestureRecognition( enable:Boolean ):void
		{
			if ( gestureStopTimeout != -1 ) clearTimeout( gestureStopTimeout );
			GestureManager.gesturesEnabled = enable;
			gestureStopTimeout = -1;
		}
	}
}