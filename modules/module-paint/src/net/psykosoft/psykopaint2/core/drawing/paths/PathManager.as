package net.psykosoft.psykopaint2.core.drawing.paths
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ConditionalDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.EndConditionalDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.IPointDecorator;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	final public class PathManager
	{
		public static const ENGINE_TYPE_BASIC:int = 0;
		public static const ENGINE_TYPE_CATMULL:int = 1;
		
		
		private static var _engineDepot : Vector.<Vector.<IPathEngine>> = Vector.<Vector.<IPathEngine>>([new Vector.<IPathEngine>(),new Vector.<IPathEngine>(),]);
		private static var _samplePointDepot : Vector.<SamplePoint> = new Vector.<SamplePoint>();
	

		static public function getPathEngine( type:int ) : IPathEngine
		{
			if (_engineDepot[type].length > 0) {
				return _engineDepot[type].pop();
			} else {
				if ( type == 1 )
				{
					return new PathEngineCatmull();
				} else {
					return new PathEngineBasic();
				}
			}
		}

		static public function getSamplePointXY(x : Number, y : Number, speed : Number = 0, size:Number = 0, angle:Number = 0, colors:Vector.<Number> = null) : SamplePoint
		{
			if (_samplePointDepot.length > 0) {
				var p : SamplePoint = _samplePointDepot.pop();
				return p.resetData(x, y, speed, size, angle, colors);
			} else {
				return new SamplePoint(x, y,  speed, size, angle, colors);
			}
		}
		
		static public function getSamplePoint( point:Point, speed : Number = 0, size:Number = 0, angle:Number = 0, colors:Vector.<Number> = null) : SamplePoint
		{
			if (_samplePointDepot.length > 0) {
				var p : SamplePoint = _samplePointDepot.pop();
				return p.resetData(point.x, point.y, speed, size, angle, colors);
			} else {
				return new SamplePoint(point.x, point.y,  speed, size, angle, colors);
			}
		}

		static public function recyclePathEngine(value : IPathEngine) : void
		{
			value.clear();
			_engineDepot[value.type].push(value);

		}

		static public function recycleSamplePoints(value : Vector.<SamplePoint>) : void
		{
			_samplePointDepot = _samplePointDepot.concat(value);
			value.length = 0;
		}

		static public function recycleSamplePoint(value:SamplePoint):void
		{
			_samplePointDepot.push(value);
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

		// these two is to prevent both mouse & touch handling to happen, which sometimes causes double start/end path triggers
		private var _listeningToMouse : Boolean;
		private var _listeningToTouch : Boolean;
		private var _startCallbacksSent : Boolean;
		
		private var _currentTick:uint;
		private var _lastUpdateTick:uint;
		

		public function PathManager( type:int )
		{
			_pathEngine = getPathEngine( type );
			_accumulatedResults = new Vector.<SamplePoint>();
			_pointDecorators = new Vector.<IPointDecorator>();
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

		public function setCallbacks(callbackObject : Object, onPathPoints : Function, onPathStart : Function = null, onPathEnd : Function = null, onPickColor : Function = null) : void
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
				_callbacks.onPathPoints.apply(_callbacks.callbackObject, [points]);
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
			if (!_listeningToMouse && !_listeningToTouch) _view.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame, false );
		
			if (_startCallbacksSent && _callbacks.onPathEnd) _callbacks.onPathEnd.apply(_callbacks.callbackObject);
			_startCallbacksSent = false;
		}

		protected function onTouchBegin(event : TouchEvent) : void
		{
			if (_listeningToMouse) return;
			_view.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 10000 );

			if (_touchID == -1) {
				_listeningToTouch = true;
				_touchID = event.touchPointID;

				_view.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
				_view.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);

				onSampleStart(new Point(event.stageX, event.stageY));
			}
		}

		protected function onTouchMove(event : TouchEvent) : void
		{
			if (event.touchPointID == _touchID)
				onSamplePoint(new Point(event.stageX, event.stageY));
		}

		protected function onTouchEnd(event : TouchEvent) : void
		{
			if (event.touchPointID == _touchID) {
				_listeningToTouch = false;
				onSampleEnd(new Point(event.stageX, event.stageY));
				_view.stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
				_view.stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
				_touchID = -1;
			}
		}
		
		protected function onEnterFrame(event : Event) : void
		{
			_currentTick++;
			
			if ( _accumulatedResults.length == 0 && hasActiveDecorators() )
			{
				updateDecorators();
			}
			if ( _accumulatedResults.length > 0 )
			{
				sendPointsCallbacks(_accumulatedResults);
				_accumulatedResults.length = 0;
			}
			
			if (!_listeningToTouch && !_listeningToMouse && !hasActiveDecorators() )
			{
				sendEndCallbacks();
			}
			
		}

		// for purposes of le debug
		protected function onMouseDown(event : MouseEvent) : void
		{
			if (_listeningToTouch) return;
			_view.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 10000 );
			_listeningToMouse = true;
			if ( !(event.target is Stage) ) return;
			onSampleStart(new Point(event.stageX, event.stageY));
			_view.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_view.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		protected function onMouseUp(event : MouseEvent) : void
		{
			_listeningToMouse = false;
			onSampleEnd(new Point(event.stageX, event.stageY));
			_view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_view.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		private function onMouseMove(event : MouseEvent) : void
		{
			onSamplePoint(new Point(event.stageX, event.stageY));
		}

		protected function onSampleStart(location : Point) : void
		{
			_pathEngine.clear();
			_pathEngine.addFirstPoint(location );
			sendStartCallbacks();
			if ( _pathEngine.sendTaps ) {
				update(true);
				onEnterFrame(null);
			}
		}

		protected function onSamplePoint(location : Point) : void
		{
			if ( _pathEngine.addPoint(location)) update();
		}

		protected function onSampleEnd(location : Point) : void
		{
			_pathEngine.addPoint(location, true);
			update(true);
			onEnterFrame(null);
			if (!hasActiveDecorators() )
			{
				sendEndCallbacks();
			} 
			
			
		}

		protected function update(forceUpdate : Boolean = false) : void
		{
			_accumulatedResults = _accumulatedResults.concat(_pathEngine.update( forceUpdate ) );
			updateDecorators();
		}
		
		protected function updateDecorators() : void
		{
			if ( _currentTick == _lastUpdateTick ) return;
			_lastUpdateTick = _currentTick;
			
			trace("updateDecorators: before: "+_accumulatedResults.length+ " points (frame: "+_currentTick+")");
			var conditionalStack:Vector.<Vector.<SamplePoint>>;
			var inCondition:int = -1;
			for ( var i:int = 0; i < _pointDecorators.length; i++ )
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
						_accumulatedResults = _pointDecorators[i].process( _accumulatedResults, this, _listeningToTouch || _listeningToMouse );
					} else {
						conditionalStack[inCondition] = _pointDecorators[i].process( conditionalStack[inCondition], this, _listeningToTouch || _listeningToMouse );
					}
				}
			}
			trace("updateDecorators: after: "+_accumulatedResults.length+ " points");
		}

		public function activate(view : DisplayObject, canvasModel:CanvasModel ) : void
		{
			_touchID = -1;
			_startCallbacksSent = false;
			this.canvasModel = canvasModel;
			if (_active) return;
			
			_active = true;
			_view = view;
			_view.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			
			_view.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		public function deactivate() : void
		{
			_active = false;
			_view.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			_view.stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			_view.stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);

			_view.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame );

			_view.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_view.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_view.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}

		public function getParameterSet( path:Array ):XML
		{
			var result:XML = _pathEngine.getParameterSet(path);
			for ( var i:int = 0; i < _pointDecorators.length; i++ )
			{
				var subPath:Array = path.concat(["pointdecorator_"+i]);
				result.appendChild(_pointDecorators[i].getParameterSet(subPath) );
			}
			return result;
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
	}
}