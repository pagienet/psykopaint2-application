package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapTdsiStrategy;

	public class SplatBrushBase extends AbstractBrush
	{
		public function SplatBrushBase(drawNormalsOrSpecular : Boolean)
		{
			super(drawNormalsOrSpecular);
		}

		override protected function createColorStrategy() : IColorStrategy
		{
			return new PyramidMapTdsiStrategy(_canvasModel);
		}

	}
}
