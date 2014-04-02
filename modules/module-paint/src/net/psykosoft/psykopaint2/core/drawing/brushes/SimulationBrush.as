package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DStencilAction;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import net.psykosoft.psykopaint2.core.drawing.actions.CanvasSnapShot;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationRibbonMesh;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.base.errors.AbstractMethodError;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;

	public class SimulationBrush extends AbstractBrush
	{
		private var _lastDrawCount : int;
		private var _cleanUpTickerTimer : Timer;

		public function SimulationBrush(drawNormalsOrSpecular : Boolean)
		{
			super(drawNormalsOrSpecular);
		}

		override public function stopProgression() : void
		{
			cleanUpTicker();
			_renderInvalid = false;
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
				simulationMesh.appendStationary();

			if (_brushMesh.numTriangles > 0)
				updateSimulation();

			invalidateRender();
		}

		override protected function onPathEnd() : void
		{
			var tempSnapShot : CanvasSnapShot = snapshot;
			// set lastDrawCount to 3 to prevent final stationary, we need to add this before snap shot is trimmed
			_lastDrawCount = 3;
			simulationMesh.appendStationary();

			_view.stage.frameRate = 60;
			_cleanUpTickerTimer = new Timer(1500, 1);
			_cleanUpTickerTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			_cleanUpTickerTimer.start();

			super.onPathEnd();
			// dirty hack to cancel snapshot becoming null
			snapShot = tempSnapShot;
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

			snapShot = null;

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

		override protected function addStrokePoint(point : SamplePoint, size : Number, rotationRange : Number) : void
		{
			// todo: could use speed or something with lowerRangeValue?
			super.addStrokePoint(point, size*param_sizeFactor.upperRangeValue * 1.3, rotationRange);
		}


		override protected function drawColor():void
		{
			_context.setRenderToTexture(_canvasModel.fullSizeBackBuffer);
			_context.clear();

			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);

			_snapshot.drawColor();

			_context.setBlendFactors(param_blendMode.stringValue, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

			drawBrushColor();

			_canvasModel.swapColorLayer();
		}

		override protected function drawNormalsAndSpecular():void
		{
			_context.setDepthTest(false, Context3DCompareMode.ALWAYS);
			_context.setRenderToTexture(_canvasModel.fullSizeBackBuffer);
			_context.clear();

			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			_snapshot.drawNormalsSpecular();
			drawBrushNormalsAndSpecular();

			_canvasModel.swapNormalSpecularLayer();
		}

		protected function get simulationMesh():SimulationMesh
		{
			return SimulationMesh(_brushMesh);
		}
	}
}
