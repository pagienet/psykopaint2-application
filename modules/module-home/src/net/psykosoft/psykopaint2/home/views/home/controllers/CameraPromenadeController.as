package net.psykosoft.psykopaint2.home.views.home.controllers
{
	import away3d.cameras.Camera3D;

	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import org.osflash.signals.Signal;

	public class CameraPromenadeController
	{
		public var activePositionChanged : Signal = new Signal();

		private var _target : Camera3D;
		private var _targetPositions : Vector.<Number>;
		private var _stage : Stage;
		private var _lastPositionX : Number;
		private var _velocity : Number = 0;
		private var _minX : Number;
		private var _maxX : Number;
		private var _activeTargetPositionID : int;
		private var _tween : TweenLite;
		private var _hasEnterFrame : Boolean;
		private var _friction : Number;
		private var _tweenTime : Number = .5;
		private var _startTime : Number;
		private var _startPos : Number;
		private var _interactionRect : Rectangle;

		// uses X coordinate as distance reference
		public function CameraPromenadeController(target : Camera3D, stage : Stage, minX : Number = -814, maxX : Number = 814)
		{
			_target = target;
			_targetPositions = new <Number>[];
			_stage = stage;
			_minX = minX;
			_maxX = maxX;
			_interactionRect = new Rectangle(0, 0, _stage.stageWidth, _stage.stageHeight);
		}

		public function registerTargetPosition(id : int, positionX : Number) : void
		{
			_targetPositions[id] = positionX;
		}

		public function start() : void
		{
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		private function onMouseDown(event : MouseEvent) : void
		{
			if (_interactionRect.contains(event.stageX, event.stageY)) {
				resetPan(event.stageX / CoreSettings.GLOBAL_SCALING);
				_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
		}

		private function onMouseMove(event : MouseEvent) : void
		{
			updateMovement(event.stageX / CoreSettings.GLOBAL_SCALING);
		}

		private function onMouseUp(event : MouseEvent) : void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			moveToBestPosition();
		}

		private function resetPan(stageX : Number) : void
		{
			_lastPositionX = stageX;
			killTween();
		}

		public function stop() : void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		private function updateMovement(stageX : Number) : void
		{
			var dx : Number = (stageX - _lastPositionX)*1.2;
			_velocity = _velocity + (dx - _velocity) * .95;
			var targetX : Number = _target.x + dx;
			if (targetX > _maxX)
				targetX = _maxX;
			else if (targetX < _minX)
				targetX = _minX;
			_target.x = targetX;
			_lastPositionX = stageX;
		}

		private function moveToBestPosition() : void
		{
			killTween();
			var targetID : int;

			if (Math.abs(_velocity) < 5) {
				targetID = findClosestID(_target.x);
				TweenLite.to(_target,.5, {x: _targetPositions[targetID], ease:Quad.easeOut});
			}
			else {
				// convert per frame to per second
				_velocity *= 60;
				_startPos = _target.x;
				var targetTime : Number = .25;
				var targetFriction : Number = .8;
				if (_velocity > 0) targetFriction = -targetFriction;
				// where would the target end up with the current speed after aimed time with aimed friction?
				targetID = findClosestID(_startPos + _velocity * targetTime + targetFriction * targetTime * targetTime );

				// solving:
				// p(t) = p(0) + v(0)*t + a*t^2 / 2 = target
				// v(t) = v(0) + a*t = 0
				// for a (acceleration, ie negative friction) and t

				_tweenTime = 2 * (_targetPositions[targetID] - _startPos) / _velocity;
				_friction = -_velocity/_tweenTime;

				_startTime = getTimer();
				_hasEnterFrame = true;
				_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}

			if (_activeTargetPositionID != targetID) {
				_activeTargetPositionID = targetID;
				activePositionChanged.dispatch();
			}
		}

		private function onEnterFrame(event : Event) : void
		{
			var t : Number = (getTimer() - _startTime)/1000;
			if (t > _tweenTime) {
				_target.x = _targetPositions[_activeTargetPositionID];
				killTween();
			}
			else {
				_target.x = _startPos + _velocity*t + .5*_friction * t * t;
			}
		}

		private function findClosestID(position : Number) : int
		{
			var minDiff : Number = Number.POSITIVE_INFINITY;
			var currentPosition : Number = position;
			var bestID : int;

			for (var i : int = 0; i < _targetPositions.length; ++i) {
				var pos : Number = _targetPositions[i];
				var diff : Number = Math.abs(pos - currentPosition);
				if (diff < minDiff) {
					bestID = i;
					minDiff = diff;
	 			}
			}

			return bestID;
		}

		public function get activeTargetPositionID() : int
		{
			return _activeTargetPositionID;
		}

		public function navigateTo(positionID : int) : void
		{
			if (_activeTargetPositionID != positionID) {
				_activeTargetPositionID = positionID;
				killTween();
				_tween = TweenLite.to(_target, 1, {x : _targetPositions[positionID], ease: Quad.easeInOut, overwrite : 0});
			}
		}

		private function killTween() : void
		{
			if (_tween) {
				_tween.kill();
				_tween = null;
			}

			if (_hasEnterFrame) {
				_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				_hasEnterFrame = false;
			}
		}


		public function get interactionRect() : Rectangle
		{
			return _interactionRect;
		}

		public function set interactionRect(interactionRect : Rectangle) : void
		{
			_interactionRect = interactionRect;
		}
	}
}
