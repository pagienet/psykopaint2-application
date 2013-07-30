package net.psykosoft.psykopaint2.core.models
{
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.signals.NotifyEaselRectUpdateSignal;

	public class EaselRectModel
	{
		[Inject]
		public var notifyEaselRectUpdateSignal:NotifyEaselRectUpdateSignal;

		private var _rect : Rectangle = new Rectangle(0, 0, 1024, 768);

		public function EaselRectModel()
		{
		}

		public function get rect() : Rectangle
		{
			return _rect;
		}

		public function set rect(value : Rectangle) : void
		{
			_rect = value;
			notifyEaselRectUpdateSignal.dispatch(_rect);
		}
	}
}
