package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quint;
	
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.UncoloredTextureSplatMesh;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.resources.ITextureManager;

	public class UncoloredSprayCanBrush extends SplatBrushBase
	{
		private var rng : LCG;

		private var _yuvMatchingWeights : Vector.<Number>;

		public function UncoloredSprayCanBrush()
		{
			super(false);
			rng = new LCG(Math.random() * 0xffffff);
			type = BrushType.UNCOLORED_SPRAY_CAN;
			_maxBrushRenderSize = 64;
			_minBrushRenderSize = 1;

			_yuvMatchingWeights = Vector.<Number>([1, 1, 1]);
		}


		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel) : void
		{
			super.activate(view, context, canvasModel);
		}

		override protected function createBrushMesh() : IBrushMesh
		{
			var stroke : UncoloredTextureSplatMesh = new UncoloredTextureSplatMesh();
			stroke.luminanceFactor = 1;
			return stroke;
		}

		override protected function set brushShape(brushShape : AbstractBrushShape) : void
		{
			super.brushShape = brushShape;
			UncoloredTextureSplatMesh(_brushMesh).brushTexture = _brushShape.texture;
		}

		override protected function onPathPoints(points : Vector.<SamplePoint>) : void
		{
			if (points.length > 1)
				points = points.sort(function (a : SamplePoint, b : SamplePoint) : int
				{
					return rng.getChance(0.5) ? -1 : 1
				});

			super.onPathPoints(points);
		}
		
		
		override protected function onPickColor( point : SamplePoint, colorsRGBA:Vector.<Number> ) : void
		{
			
			var minSize:Number = (_minBrushRenderSize + ( _maxBrushRenderSize - _minBrushRenderSize ) * _sizeFactor.lowerRangeValue);
			var maxSize:Number = (_minBrushRenderSize + ( _maxBrushRenderSize - _minBrushRenderSize ) * _sizeFactor.upperRangeValue);
			var rsize : Number = minSize + (maxSize - minSize) * point.size;
			if (rsize > maxSize) rsize = maxSize;
			else if (rsize < minSize) rsize = minSize;
			
			
			//_colorStrategy.setBlendFactors(_firstPoint ? 1 : rng.getNumber(_colorBlend.lowerRangeValue, _colorBlend.lowerRangeValue + (_colorBlend.upperRangeValue - _colorBlend.lowerRangeValue) * (1 - Math.min(1, point.size))), rng.getNumber(_opacity.lowerRangeValue, _opacity.upperRangeValue));
			_colorStrategy.getColors(point, rsize, rsize * 0.5, colorsRGBA);
			
		}
		

		override protected function processPoint(point : SamplePoint) : void
		{
			var minSize:Number = (_minBrushRenderSize + ( _maxBrushRenderSize - _minBrushRenderSize ) * _sizeFactor.lowerRangeValue);
			var maxSize:Number = (_minBrushRenderSize + ( _maxBrushRenderSize - _minBrushRenderSize ) * _sizeFactor.upperRangeValue);
			var rsize : Number = minSize + (maxSize - minSize) * point.size;
			if (rsize > maxSize) rsize = maxSize;
			else if (rsize < minSize) rsize = minSize;

			/*
			_colorStrategy.setBlendFactors(_firstPoint ? 1 : rng.getNumber(_colorBlend.lowerRangeValue, _colorBlend.lowerRangeValue + (_colorBlend.upperRangeValue - _colorBlend.lowerRangeValue) * (1 - Math.min(1, point.speed))), rng.getNumber(_opacity.lowerRangeValue, _opacity.upperRangeValue));
			_colorStrategy.getColors(x, y, rsize, rsize * 0.5, point.colorsRGBA);
			*/
			_brushShape.getClosestColorMatchYUV(point.colorsRGBA, appendVO.uvBounds, 0.06, _yuvMatchingWeights);
			
			//appendVO.x = point.normalX;
			//appendVO.y = point.normalY;
			appendVO.size = rsize * _canvasScaleW;
			//appendVO.rotation = point.angle;
			appendVO.point = point;
			_brushMesh.append(appendVO);
		}


	}

}
