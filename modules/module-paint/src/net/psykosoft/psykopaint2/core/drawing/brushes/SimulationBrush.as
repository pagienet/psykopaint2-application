package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.base.errors.AbstractMethodError;

	public class SimulationBrush extends AbstractBrush
	{
		private var _lastDrawCount : int;
		private var _cleanUpTickerTimer : Timer;

		public function SimulationBrush(drawNormalsOrSpecular : Boolean)
		{
			super(drawNormalsOrSpecular, false, true);
		}

		override public function stopProgression() : void
		{
			cleanUpTicker();
			_renderInvalid = false;
		}

		override protected function createBrushMesh() : IBrushMesh
		{
			return new SimulationMesh();
		}

		override protected function onPathStart() : void
		{
			_view.stage.frameRate = 30;
			super.onPathStart();

			cleanUpTicker();
			resetSimulation();

			_view.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}


		override protected function onPathPoints(points : Vector.<SamplePoint>) : void
		{
			super.onPathPoints(points);

			// keep track of when we last added points, so we can figure out if the user has been stationary
			_lastDrawCount = 0;
		}

		private function onEnterFrame(event : Event) : void
		{
			if (++_lastDrawCount == 2)
				SimulationMesh(_brushMesh).appendStationary();

			if (_brushMesh.numTriangles > 0)
				updateSimulation();

			invalidateRender();
		}

		override protected function onPathEnd() : void
		{
			// set lastDrawCount to 3 to prevent final stationary, we need to add this before snap shot is trimmed
			_lastDrawCount = 3;
			SimulationMesh(_brushMesh).appendStationary();

			_view.stage.frameRate = 60;
			_cleanUpTickerTimer = new Timer(1500, 1);
			_cleanUpTickerTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			_cleanUpTickerTimer.start();

			super.onPathEnd();
		}

		private function onTimerComplete(event : TimerEvent) : void
		{
			cleanUpTicker();
		}

		private function cleanUpTicker() : void
		{
			if (_cleanUpTickerTimer) {
				_cleanUpTickerTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				_cleanUpTickerTimer = null;
			}

			_view.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		protected function resetSimulation() : void
		{
			throw AbstractMethodError("Abstract method called");
		}

		protected function updateSimulation() : void
		{
			throw AbstractMethodError("Abstract method called");
		}


		override public function deactivate() : void
		{
			cleanUpTicker();
			super.deactivate();
		}
	}
}
