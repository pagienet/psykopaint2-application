package net.psykosoft.psykopaint2.core.io
{
	import flash.events.Event;
	import flash.utils.ByteArray;

	public class CanvasSerializationEvent extends Event
	{
		public static const COMPLETE : String = "SerializationComplete";
		public static const PROGRESS : String = "SerializationProgress";

		private var _data : ByteArray;
		private var _stages : int;
		private var _numStages : int;

		public function CanvasSerializationEvent(type : String, data : ByteArray, stages : int = 1, numStages : int = 1, bubbles : Boolean = false, cancelable : Boolean = true)
		{
			super(type, bubbles, cancelable);
			_data = data;
			_stages = stages;
			_numStages = numStages;
		}

		public function get data() : ByteArray
		{
			return _data;
		}

		public function get stages() : int
		{
			return _stages;
		}

		public function get numStages() : int
		{
			return _numStages;
		}

		override public function clone() : Event
		{
			return new CanvasSerializationEvent(type, _data, _stages, _numStages, bubbles, cancelable);
		}
	}
}
