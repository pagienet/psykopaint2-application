package net.psykosoft.psykopaint2.core.models
{
	import flash.geom.Rectangle;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.signals.NotifyEaselRectUpdateSignal;

	public class EaselRectModel
	{
		[Inject]
		public var notifyEaselRectUpdateSignal:NotifyEaselRectUpdateSignal;

		private var _localScreenRect : Rectangle = new Rectangle(0, 0, 1024, 768);
		private var _absoluteScreenRect : Rectangle = new Rectangle(0, 0, 1024, 768);

		public function EaselRectModel()
		{
		}

		public function get localScreenRect() : Rectangle
		{
			return _localScreenRect;
		}

		public function get absoluteScreenRect() : Rectangle
		{
			return _absoluteScreenRect;
		}

		public function set absoluteScreenRect(value : Rectangle) : void
		{
			_absoluteScreenRect = value;
			_localScreenRect = value.clone();
			_localScreenRect.x /= CoreSettings.GLOBAL_SCALING;
			_localScreenRect.y /= CoreSettings.GLOBAL_SCALING;
			_localScreenRect.width /= CoreSettings.GLOBAL_SCALING;
			_localScreenRect.height /= CoreSettings.GLOBAL_SCALING;
			notifyEaselRectUpdateSignal.dispatch(_localScreenRect);
		}
	}
}
