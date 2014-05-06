package net.psykosoft.psykopaint2.core.managers.gestures
{
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	/**
	 * GrabThrowController is a function that allows touch-and-drag functionality, but keeps track of velocity when
	 * released so the application can decide to do something.
	 *
	 * Three events can occur:
	 * - GrabThrowEvent::DRAG_STARTED: Dragging has started
	 * - GrabThrowEvent::DRAG_UPDATE: Simply moving when touching
	 * - GrabThrowEvent::RELEASE: Drag stopped, velocity can be used for momentum
	 */
	public class GrabThrowController extends EventDispatcher
	{
		private var _stage : Stage;
		private var _started : Boolean;
		private var _interactionRect : Rectangle;
		private var _lastPositionX : Number;
		private var _lastPositionY : Number;
		private var _velocityX : Number = 0;
		private var _velocityY : Number = 0;
		private var _touchID : int = -1;
		private var _isDragging : Boolean;
		private var _exclusive : Boolean;
		private var _priority : int;

		public function GrabThrowController(stage : Stage)
		{
			_stage = stage;
		}

		public function get interactionRect() : Rectangle
		{
			return _interactionRect;
		}

		public function set interactionRect(value : Rectangle) : void
		{
			_interactionRect = value;
		}

		public function start(priority : int = 0, exclusive : Boolean = false) : void
		{
			if (!_started) {
				_exclusive = exclusive;
				_touchID = -1;
				_started = true;
				_priority = priority;

				//FIXME: there are cases when _stage = null
				if (CoreSettings.RUNNING_ON_iPAD)
					_stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin, false, priority);
				else
					_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, priority);
			}
		}

		public function stop() : void
		{
			_started = false;

			if (CoreSettings.RUNNING_ON_iPAD) {
				_stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
				_stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
				_stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			}
			else {
				_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
		}

		private function onMouseDown(event : MouseEvent) : void
		{
			if (beginGrabThrow(event.stageX, event.stageY)) {
				if (_exclusive) event.stopImmediatePropagation();
				_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, _priority);
				_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, _priority);
			}
		}

		private function onTouchBegin(event : TouchEvent) : void
		{
			if (!event.isPrimaryTouchPoint) {
				// multitouch detected, not a pan gesture anymore
				if (_isDragging) endGrabThrow(true);
				return;
			}

			if (beginGrabThrow(event.stageX, event.stageY)) {
				if (_exclusive) event.stopImmediatePropagation();
				_stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove, false, _priority);
				_stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd, false, _priority);
			}
		}

		private function onMouseMove(event : MouseEvent) : void
		{
			updateMove(event.stageX, event.stageY);
		}

		private function onTouchMove(event : TouchEvent) : void
		{
			updateMove(event.stageX, event.stageY);
		}

		private function onMouseUp(event : MouseEvent) : void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			endGrabThrow(false);
		}

		private function onTouchEnd(event : TouchEvent) : void
		{
			_stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			_stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			endGrabThrow(false);
		}

		private function beginGrabThrow(x : Number, y : Number) : Boolean
		{
			_lastPositionX = x;
			_lastPositionY = y;
			_velocityX = 0;
			_velocityY = 0;

			if (!_interactionRect || _interactionRect.contains(_lastPositionX, _lastPositionY)) {
				_isDragging = true;
				dispatchEvent(new GrabThrowEvent(GrabThrowEvent.DRAG_STARTED, _velocityX, _velocityY));
				return true;
			}
			return false;
		}

		private function updateMove(x : Number, y : Number) : void
		{
			var dx : Number = x - _lastPositionX;
			var dy : Number = y - _lastPositionY;
			// include slight smoothing of velocity
			_velocityX += (dx - _velocityX) * .95;
			_velocityY += (dy - _velocityY) * .95;
			_lastPositionX = x;
			_lastPositionY = y;
			dispatchEvent(new GrabThrowEvent(GrabThrowEvent.DRAG_UPDATE, _velocityX, _velocityY, false));
		}

		private function endGrabThrow(interrupted : Boolean) : void
		{
			_isDragging = false;
			dispatchEvent(new GrabThrowEvent(GrabThrowEvent.RELEASE, _velocityX, _velocityY, interrupted));
		}

		public function get isActive() : Boolean
		{
			return _started;
		}
	}
}
