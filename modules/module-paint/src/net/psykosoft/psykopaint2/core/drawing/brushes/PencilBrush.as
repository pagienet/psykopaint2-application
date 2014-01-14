package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapTdsiStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.RubbedStrokeMesh;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.resources.ITextureManager;

	public class PencilBrush extends AbstractBrush
	{
        private var _surfaceRelief:PsykoParameter;

		public function PencilBrush()
		{
            super(false, false);
            type = BrushType.PENCIL;

            _surfaceRelief = new PsykoParameter( PsykoParameter.NumberParameter, "Surface influence",.3, 0, 1.0);
			_shininess.numberValue = .4;
			_glossiness.numberValue = .5;
			_bumpiness.numberValue = .6;
			_sizeFactor.lowerRangeValue = 0.2;
			_sizeFactor.upperRangeValue = 0.4;
		
		}

		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel, renderer:CanvasRenderer, paintSettingsModel : UserPaintSettingsModel) : void
		{
			super.activate(view, context, canvasModel, renderer, paintSettingsModel);
			if (_brushShape)
				assignBrushShape();
		}

		override protected function createBrushMesh() : IBrushMesh
		{
			return new RubbedStrokeMesh();
		}

		override protected function set brushShape(brushShape : AbstractBrushShape) : void
		{
			super.brushShape = brushShape;
			if (_brushMesh)
				assignBrushShape();
			_pathManager.brushAngleRange = brushShape.rotationRange;
		}

		private function assignBrushShape() : void
		{
			RubbedStrokeMesh(_brushMesh).brushTexture = _brushShape.texture;
			RubbedStrokeMesh(_brushMesh).normalTexture = _brushShape.normalSpecularMap;
			RubbedStrokeMesh(_brushMesh).pixelUVOffset = 0.5 / _brushShape.size;
			_pathManager.brushAngleRange = brushShape.rotationRange;
		}

		override protected function createColorStrategy() : IColorStrategy
		{
			var strategy : PyramidMapTdsiStrategy = new PyramidMapTdsiStrategy(_canvasModel);
			//strategy.setBlendFactors(.7,1);
			return strategy;
		}

        override protected function drawBrushColor():void {
            RubbedStrokeMesh(_brushMesh).setSurfaceRelief(_surfaceRelief.numberValue);
            super.drawBrushColor();
        }


        override protected function processPoint(point:SamplePoint):void {
			//TODO - this is unfortunately broken after normalizing the brush sizes - needs fix:
            var scale : Number = point.size*10 * _sizeFactor.upperRangeValue - Math.random()*_sizeFactor.rangeValue;
            addStrokePoint(point, _brushShape.actualSize * _canvasScaleW * scale, _brushShape.rotationRange);
        }
    }
}