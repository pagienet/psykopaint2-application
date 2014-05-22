package net.psykosoft.psykopaint2.core.model
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	
	import net.psykosoft.psykopaint2.core.drawing.actions.CanvasSnapShot;
	import net.psykosoft.psykopaint2.core.resources.texture_management;
	import net.psykosoft.psykopaint2.core.signals.NotifyHistoryStackChangedSignal;

	use namespace texture_management;

	public class CanvasHistoryModel
	{
		[Inject]
		public var notifyHistoryStackChanged : NotifyHistoryStackChangedSignal;

		[Inject]
		public var stage3d : Stage3D;

		[Inject]
		public var canvas : CanvasModel;

		private var _context : Context3D;

		private var _hasHistory : Boolean;

		private var _snapShot : CanvasSnapShot;	// contains the current state

		public function CanvasHistoryModel()
		{
		}

		[PostConstruct]
		public function init() : void
		{
			_context = stage3d.context3D;
		}

		public function get hasHistory() : Boolean
		{
			return _hasHistory;
		}

		public function undo() : void
		{
			if (_hasHistory)
				restoreSnapshot();
		}

		private function restoreSnapshot() : void
		{
			_snapShot.exchangeWithCanvas(canvas);
		}

		// returned snapshot is READ-ONLY!
		public function takeSnapshot() : CanvasSnapShot
		{
			if (!_snapShot)
				_snapShot = new CanvasSnapShot(_context, canvas);
			_snapShot.updateSnapshot();
			_hasHistory = true;
			notifyStackChange();
			return _snapShot;
		}

		private function notifyStackChange() : void
		{
			notifyHistoryStackChanged.dispatch(_hasHistory);
		}

		public function clearHistory() : void
		{
			if (_snapShot) _snapShot.dispose();
			_snapShot = null;
			_hasHistory = false;
			notifyStackChange();
		}
	}
}
