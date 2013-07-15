package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapTdsiStrategy;

	public class SplatBrushBase extends AbstractBrush
	{
		protected var _maxBrushRenderSize:Number;
		protected var _minBrushRenderSize:Number;

		public function SplatBrushBase(drawNormalsOrSpecular : Boolean)
		{
			super(drawNormalsOrSpecular);
			//I think this should rather be parameters. Right now this affect all brushes when changed so tread carefully:
			_maxBrushRenderSize = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 256 : 128;
			_minBrushRenderSize = 1;
		}

		override protected function createColorStrategy() : IColorStrategy
		{
			return new PyramidMapTdsiStrategy(_canvasModel);
		}

		override protected function onPathStart() : void
		{
			super.onPathStart();

			if (_brushShape)  _maxBrushRenderSize = Math.min( _maxBrushRenderSize, _brushShape.size  );
		}
	}
}
