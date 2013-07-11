package net.psykosoft.psykopaint2.core.io
{
	import flash.events.Event;

	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;

	public class CanvasExportEvent extends Event
	{
		public static const COMPLETE : String = "ExportComplete";

		private var _paintingDataVO : PaintingDataVO;

		public function CanvasExportEvent(type : String, paintingDataVO : PaintingDataVO, bubbles : Boolean = false, cancelable : Boolean = true)
		{
			super(type, bubbles, cancelable);
			_paintingDataVO = paintingDataVO;
		}

		public function get paintingDataVO() : PaintingDataVO
		{
			return _paintingDataVO;
		}

		override public function clone() : Event
		{
			return new CanvasExportEvent(type, _paintingDataVO, bubbles, cancelable);
		}
	}
}
