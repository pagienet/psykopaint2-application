package net.psykosoft.psykopaint2.home.views.home.controllers
{
	import away3d.cameras.Camera3D;

	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import org.osflash.signals.Signal;

	public class CameraPromenadeController
	{
		public var activePositionChanged : Signal = new Signal();

		private var _target : Camera3D;
		private var _targetPositions : Vector.<Vector3D>;
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
		private var _startPos : Vector3D;
		private var _interactionRect : Rectangle;
		private var _started : Boolean;
		private var _maxIndex : int;
		private var _minIndex : int;

		// uses X coordinate as distance reference
		public function CameraPromenadeController(target : Camera3D, stage : Stage)
		{
			_target = target;
			_targetPositions = new <Vector3D>[];
			_stage = stage;
			_minX = Number.POSITIVE_INFINITY;
			_maxX = Number.NEGATIVE_INFINITY;
			_interactionRect = new Rectangle(0, 0, _stage.stageWidth, _stage.stageHeight);
		}

		public function registerTargetPosition(id : int, position : Vector3D) : void
		{
			if (position.x < _minX) {
				_minX = position.x;
				_minIndex = id;
			}

			if (position.x > _maxX) {
				_maxX = position.x;
				_maxIndex = id;
			}

			_targetPositions[id] = position;
		}

		public function start() : void
		{
			if (!_started) {
				_started = true;
				_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
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
			_started = false;
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		private function updateMovement(stageX : Number) : void
		{
			var dx : Number = (stageX - _lastPositionX)*1.2;
			_velocity = _velocity + (dx - _velocity) * .95;
			_lastPositionX = stageX;

			var targetX : Number = _target.x + dx;
			var firstIndex : int;
			var secondIndex : int;

			if (targetX > _maxX) {
				targetX = _maxX;
				firstIndex = _maxIndex;
				secondIndex = _maxIndex;
			}
			else if (targetX < _minX) {
				targetX = _minX;
				firstIndex = _minIndex;
				secondIndex = _minIndex;
			}
			else {
				firstIndex = getLowerBoundingIndex(targetX);
				secondIndex = getUpperBoundingIndex(targetX);
				if (firstIndex < 0) firstIndex = 0;
				if (secondIndex < 0) secondIndex = 0;
			}

			var firstSnap : Vector3D = _targetPositions[firstIndex];

			if (firstIndex == secondIndex) {
				_target.position = firstSnap;
			}
			else {
				var secondSnap : Vector3D = _targetPositions[secondIndex];
				var ratio : Number = (targetX - firstSnap.x)/(secondSnap.x - firstSnap.x);
				_target.x = targetX;
				_target.y = firstSnap.y + ratio*(secondSnap.y - firstSnap.y);
				_target.z = firstSnap.z + ratio*(secondSnap.z - firstSnap.z);
			}

		}

		private function getLowerBoundingIndex(x : Number) : int
		{
			var len : int = _targetPositions.length;
			var bestIndex : int = -1;
			var bestDistance : Number = Number.POSITIVE_INFINITY;

			for (var i : int = 0; i < len; ++i) {
				var snapX : Number = _targetPositions[i].x;
				if (snapX < x) {
					var distance : Number = x - snapX;
					if (distance < bestDistance) {
						bestDistance = distance;
						bestIndex = i;
					}
				}
			}

			return bestIndex;
		}

		private function getUpperBoundingIndex(x : Number) : int
		{
			var len : int = _targetPositions.length;
			var bestIndex : int = -1;
			var bestDistance : Number = Number.POSITIVE_INFINITY;

			for (var i : int = 0; i < len; ++i) {
				var snapX : Number = _targetPositions[i].x;
				if (snapX > x) {
					var distance : Number = snapX - x;
					if (distance < bestDistance) {
						bestDistance = distance;
						bestIndex = i;
					}
				}
			}

			return bestIndex;
		}

		private function moveToBestPosition() : void
		{
			killTween();
			var targetID : int;

			if (Math.abs(_velocity) < 5) {
				targetID = findClosestID(_target.x);
				var targetPos : Vector3D = _targetPositions[targetID];
				TweenLite.to(_target,.5,
							{	x: targetPos.x,
								y: targetPos.y,
								z: targetPos.z,
								ease:Quad.easeOut
							});
			}
			else {
				// convert per frame to per second
				_velocity *= 60;
				_startPos = _target.position;
				var targetTime : Number = .25;
				var targetFriction : Number = .8;
				if (_velocity > 0) targetFriction = -targetFriction;
				// where would the target end up with the current speed after aimed time with aimed friction?
				targetID = findClosestID(_startPos.x + _velocity * targetTime + targetFriction * targetTime * targetTime );

				// solving:
				// p(t) = p(0) + v(0)*t + a*t^2 / 2 = target
				// v(t) = v(0) + a*t = 0
				// for 'a' (acceleration, ie negative friction) and 't'

				_tweenTime = 2 * (_targetPositions[targetID].x - _startPos.x) / _velocity;
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
			var targetPos : Vector3D = _targetPositions[_activeTargetPositionID];

			if (t > _tweenTime) {
				_target.position = targetPos;
				killTween();
			}
			else {
				var movement : Number = (_velocity + .5*_friction * t) * t;
				var ratio : Number = movement/(targetPos.x - _startPos.x);
				_target.x = _startPos.x + movement;
				_target.y = _startPos.y + (targetPos.y - _startPos.y)*ratio;
				_target.z = _startPos.z + (targetPos.z - _startPos.z)*ratio;
			}
		}

		private function findClosestID(x : Number) : int
		{
			var minDiff : Number = Number.POSITIVE_INFINITY;
			var currentPosition : Number = x;
			var bestID : int;

			for (var i : int = 0; i < _targetPositions.length; ++i) {
				var pos : Number = _targetPositions[i].x;
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
				var target : Vector3D = _targetPositions[positionID];
				killTween();
				_tween = TweenLite.to(_target, 1,
										{	x : target.x,
											y : target.y,
											z : target.z,
											ease: Quad.easeInOut, overwrite : 0});
			}
		}

		public function force(positionID : int) : void
		{
			_activeTargetPositionID = positionID;
			killTween();
			_target.position = _targetPositions[_activeTargetPositionID];
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
