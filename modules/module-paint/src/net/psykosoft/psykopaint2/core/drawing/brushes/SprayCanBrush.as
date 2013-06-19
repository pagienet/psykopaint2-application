package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import de.popforge.math.LCG;
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapTdsiStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TextureSplatMesh;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.resources.ITextureManager;
	
	public class SprayCanBrush extends SplatBrushBase
	{

		private var rng:LCG;
		

		public function SprayCanBrush()
		{
			super(true);
			rng = new LCG(Math.random() * 0xffffff);
			type = BrushType.SPRAY_CAN;
			
			_shininess.numberValue = .3;
			_glossiness.numberValue = .25;
			_bumpiness.numberValue = .6;
		}

		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel) : void
		{
			super.activate(view, context, canvasModel);
			if (_brushShape)
				assignBrushShape();
		}

		override protected function createBrushMesh() : IBrushMesh
		{
			return new TextureSplatMesh();
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
			TextureSplatMesh(_brushMesh).brushTexture = _brushShape.texture;
			TextureSplatMesh(_brushMesh).normalTexture = _brushShape.normalSpecularMap;
			TextureSplatMesh(_brushMesh).pixelUVOffset = 0.5 / _brushShape.size;
			_pathManager.brushAngleRange = brushShape.rotationRange;
		}

		override protected function createColorStrategy() : IColorStrategy
		{
			return new PyramidMapTdsiStrategy(_canvasModel);
		}

		override protected function onPickColor( point : SamplePoint ) : void
		{
			
			var minSize:Number = (_minBrushRenderSize + ( _maxBrushRenderSize - _minBrushRenderSize ) * _sizeFactor.lowerRangeValue);
			var maxSize:Number = (_minBrushRenderSize + ( _maxBrushRenderSize - _minBrushRenderSize ) * _sizeFactor.upperRangeValue);
			var rsize : Number = minSize + (maxSize - minSize) * point.size;
			if (rsize > maxSize) rsize = maxSize;
			else if (rsize < minSize) rsize = minSize;
			
			_colorStrategy.setBlendFactors(_firstPoint ? 1 : rng.getNumber(_colorBlend.lowerRangeValue, _colorBlend.lowerRangeValue + (_colorBlend.upperRangeValue - _colorBlend.lowerRangeValue) * (1 - Math.min(1, point.size))), rng.getNumber(_opacity.lowerRangeValue, _opacity.upperRangeValue));
			_colorStrategy.getColors(point.x, point.y, rsize * rng.getNumber(0.1, 1), rsize, point.colorsRGBA);

		}

		
		override protected function processPoint( point : SamplePoint) : void
		{
			var minSize:Number = (_minBrushRenderSize + ( _maxBrushRenderSize - _minBrushRenderSize ) * _sizeFactor.lowerRangeValue);
			var maxSize:Number = (_minBrushRenderSize + ( _maxBrushRenderSize - _minBrushRenderSize ) * _sizeFactor.upperRangeValue);
			var rsize : Number = minSize + (maxSize - minSize) * point.size;
			
			if (rsize > maxSize) rsize = maxSize;
			else if (rsize < minSize) rsize = minSize;

			//_colorStrategy.setBlendFactors(_firstPoint ? 1 : rng.getNumber(_colorBlend.lowerRangeValue, _colorBlend.lowerRangeValue + (_colorBlend.upperRangeValue - _colorBlend.lowerRangeValue) * (1 - Math.min(1, point.speed))), rng.getNumber(_opacity.lowerRangeValue, _opacity.upperRangeValue));
			//_colorStrategy.getColors(x, y, rsize * rng.getNumber(0.1, 1), rsize, point.colorsRGBA);

			appendVO.uvBounds.x = int(rng.getNumber(0, shapeVariations[0])) * shapeVariations[2];
			appendVO.uvBounds.y = int(rng.getNumber(0, shapeVariations[1])) * shapeVariations[3];
			//appendVO.x = point.normalX;
			//appendVO.y = point.normalY;
			appendVO.size = rsize * _canvasScaleW;
			//appendVO.rotation = point.angle;
			appendVO.point = point;
			_brushMesh.append(appendVO);
		}
	}
}
