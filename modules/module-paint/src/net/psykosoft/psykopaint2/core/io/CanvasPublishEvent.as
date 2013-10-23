package net.psykosoft.psykopaint2.core.io
{
	import flash.events.Event;

	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;

	public class CanvasPublishEvent extends Event
	{
		public static const COMPLETE : String = "ExportComplete";
		public static const PROGRESS : String = "ExportProgress";

		private var _paintingDataVO : PaintingDataVO;
		private var _stages : int;
		private var _numStages : int;

		public function CanvasPublishEvent(type : String, paintingDataVO : PaintingDataVO, stages : int = 1, numStages : int = 1, bubbles : Boolean = false, cancelable : Boolean = true)
		{
			super(type, bubbles, cancelable);
			_paintingDataVO = paintingDataVO;
			_stages = stages;
			_numStages = numStages;
		}

		public function get paintingDataVO() : PaintingDataVO
		{
			return _paintingDataVO;
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
			return new CanvasPublishEvent(type, _paintingDataVO, _stages, _numStages, bubbles, cancelable);
		}
	}
}
