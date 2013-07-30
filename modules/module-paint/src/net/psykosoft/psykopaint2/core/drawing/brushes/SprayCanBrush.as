package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapTdsiStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TextureMorphingSplatMesh;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	
	public class SprayCanBrush extends SplatBrushBase
	{

		public function SprayCanBrush()
		{
			super(true);
			type = BrushType.SPRAY_CAN;
			
			_shininess.numberValue = .3;
			_glossiness.numberValue = .25;
			_bumpiness.numberValue = .6;
		}

		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel, renderer:CanvasRenderer) : void
		{
			super.activate(view, context, canvasModel, renderer);
			if (_brushShape)
				assignBrushShape();
		}

		override protected function createBrushMesh() : IBrushMesh
		{
			return new TextureMorphingSplatMesh();
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
			TextureMorphingSplatMesh(_brushMesh).brushTexture = _brushShape.texture;
			TextureMorphingSplatMesh(_brushMesh).normalTexture = _brushShape.normalSpecularMap;
			TextureMorphingSplatMesh(_brushMesh).pixelUVOffset = 0.5 / _brushShape.size;
			_pathManager.brushAngleRange = brushShape.rotationRange;
		}

		override protected function createColorStrategy() : IColorStrategy
		{
			return new PyramidMapTdsiStrategy(_canvasModel);
		}

		override protected function onPickColor( point : SamplePoint, pickRadius : Number, smoothFactor : Number ) : void
		{
			/*
			var minSize:Number = _maxBrushRenderSize * _sizeFactor.lowerRangeValue;
			var maxSize:Number = _maxBrushRenderSize * _sizeFactor.upperRangeValue;
			var rsize : Number = minSize + (maxSize - minSize) * point.size;
			if (rsize > maxSize) rsize = maxSize;
			else if (rsize < minSize) rsize = minSize;
			*/
			var rsize : Number = _sizeFactor.lowerRangeValue + _sizeFactor.rangeValue * point.size;
			if (rsize > 1) rsize = 1;
			else if (rsize < 0) rsize = 0;
			
			_appendVO.size = _maxBrushRenderSize * rsize * pickRadius;
			_appendVO.point = point;
			_colorStrategy.getColorsByVO( _appendVO, _appendVO.diagonalLength*_maxBrushRenderSize *rsize* 0.25 * smoothFactor);
		}

		
		override protected function processPoint( point : SamplePoint) : void
		{
			/*
			var minSize:Number = _maxBrushRenderSize * _sizeFactor.lowerRangeValue;
			var maxSize:Number = _maxBrushRenderSize * _sizeFactor.upperRangeValue;
			var rsize:Number = minSize + (maxSize - minSize) * point.size;
			
			if (rsize > maxSize) rsize = maxSize;
			else if (rsize < minSize) rsize = minSize;
			*/
			var rsize : Number = _sizeFactor.lowerRangeValue + _sizeFactor.rangeValue * point.size;
			if (rsize > 1) rsize = 1;
			else if (rsize < 0) rsize = 0;
			
			
			_appendVO.uvBounds.x = int(Math.random() * _shapeVariations[0]) * _shapeVariations[2];
			_appendVO.uvBounds.y = int(Math.random() * _shapeVariations[1]) * _shapeVariations[3];
			_appendVO.size = _maxBrushRenderSize * rsize * _canvasScaleW; 
			_appendVO.point = point;
			_brushMesh.append(_appendVO);
		}
	}
}
