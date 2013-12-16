package net.psykosoft.psykopaint2.core.managers.gestures
{
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
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

		public function start() : void
		{
			if (!_started) {
				_started = true;
				_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}

		public function stop() : void
		{
			_started = false;

			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		private function onMouseDown(event : MouseEvent) : void
		{
			_lastPositionX = event.stageX;
			_lastPositionY = event.stageY;
			_velocityX = 0;
			_velocityY = 0;

			if (!_interactionRect || _interactionRect.contains(_lastPositionX, _lastPositionY)) {
				dispatchEvent(new GrabThrowEvent(GrabThrowEvent.DRAG_STARTED, _lastPositionX, _lastPositionY, _velocityX, _velocityY));
				_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
		}

		private function onMouseMove(event : MouseEvent) : void
		{
			var dx : Number = event.stageX - _lastPositionX;
			var dy : Number = event.stageY - _lastPositionY;
			// include slight smoothing of velocity
			_velocityX += (dx - _velocityX) * .95;
			_velocityY += (dy - _velocityY) * .95;
			_lastPositionX = event.stageX;
			_lastPositionY = event.stageY;
			dispatchEvent(new GrabThrowEvent(GrabThrowEvent.DRAG_UPDATE, _lastPositionX, _lastPositionY, _velocityX, _velocityY));
	}

		private function onMouseUp(event : MouseEvent) : void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			dispatchEvent(new GrabThrowEvent(GrabThrowEvent.RELEASE, event.stageX, event.stageY, _velocityX, _velocityY));
		}
	}
}
