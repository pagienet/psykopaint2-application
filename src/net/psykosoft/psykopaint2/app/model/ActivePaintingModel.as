package net.psykosoft.psykopaint2.app.model
{

	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyActivePaintingChangedSignal;

	public class ActivePaintingModel
	{
		[Inject]
		public var notifyActivePaintingChangedSignal:NotifyActivePaintingChangedSignal;

		private var _activePaintingName:String= "";

		public function ActivePaintingModel() {
			super();
		}

		public function changeActivePaintingName( value:String ):void {
			_activePaintingName = value;
			notifyActivePaintingChangedSignal.dispatch( value );
		}

		public function get activePaintingName():String {
			return _activePaintingName;
		}
	}
}
