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
			_snapShot = new CanvasSnapShot(_context, canvas);
		}

		public function swapSnapshots() : void
		{
			_hasHistory = true;
		}

		public function get hasHistory() : Boolean
		{
			return _hasHistory;
		}

		public function undo() : void
		{
			restoreSnapshot();
		}

		private function restoreSnapshot() : void
		{
			var temp : CanvasSnapShot = new CanvasSnapShot(_context, canvas);
			temp.updateSnapshot();

			_context.setRenderToTexture(canvas.colorTexture);
			_context.clear(0, 0, 0, 0);
			_snapShot.drawColor();

			_context.setRenderToTexture(canvas.normalSpecularMap);
			_context.clear(0, 0, 0, 0);
			_snapShot.drawNormalsSpecular();

			_context.setRenderToBackBuffer();

			_snapShot.dispose();
			_snapShot = temp;
		}

		// returned snapshot is READ-ONLY!
		public function takeSnapshot() : CanvasSnapShot
		{
			_snapShot.updateSnapshot();
			notifyStackChange();
			return _snapShot;
		}

		private function notifyStackChange() : void
		{
			notifyHistoryStackChanged.dispatch(_hasHistory);
		}
	}
}
