package net.psykosoft.psykopaint2.core.managers.gestures
{
	import flash.events.Event;

	public class GrabThrowEvent extends Event
	{
		public static const DRAG_STARTED : String = "DragStarted";
		public static const DRAG_UPDATE : String = "DragUpdate";
		public static const RELEASE : String = "Release";

		private var _velocityX : Number;
		private var _velocityY : Number;

		public function GrabThrowEvent(type : String, velocityX : Number, velocityY : Number, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
			_velocityX = velocityX;
			_velocityY = velocityY;
		}

		public function get velocityX() : Number
		{
			return _velocityX;
		}

		public function get velocityY() : Number
		{
			return _velocityY;
		}

		override public function clone() : Event
		{
			return new GrabThrowEvent(type, _velocityX, _velocityY, bubbles, cancelable);
		}
	}
}
