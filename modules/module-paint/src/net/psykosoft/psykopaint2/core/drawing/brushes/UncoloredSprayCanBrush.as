package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.UncoloredTextureSplatMesh;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	
	public class UncoloredSprayCanBrush extends SplatBrushBase
	{
		private var _yuvMatchingWeights : Vector.<Number>;

		public function UncoloredSprayCanBrush()
		{
			super(false);
			type = BrushType.UNCOLORED_SPRAY_CAN;
			_yuvMatchingWeights = Vector.<Number>([1, 1, 1]);
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
					return Math.random() < 0.5  ? -1 : 1
				});

			super.onPathPoints(points);
		}
		
		
		override protected function onPickColor( point : SamplePoint, pickRadius:Number, smoothFactor:Number ) : void
		{
			if ( _paintSettingsModel.colorMode == PaintMode.PHOTO_MODE )
			{
				var minSize:Number = _maxBrushRenderSize * _sizeFactor.lowerRangeValue;
				var maxSize:Number = _maxBrushRenderSize * _sizeFactor.upperRangeValue;
				var rsize : Number = minSize + (maxSize - minSize) * point.size;
				if (rsize > maxSize) rsize = maxSize;
				else if (rsize < minSize) rsize = minSize;
				
				_appendVO.size = rsize * pickRadius;
				_appendVO.point = point;
				_colorStrategy.getColorsByVO( _appendVO, rsize* 0.5 * smoothFactor);
			} else {
				var target:Vector.<Number> = _appendVO.point.colorsRGBA;
				target[0] = target[4] = target[8] = target[12] = _paintSettingsModel.current_r;
				target[1] = target[5] = target[9] = target[13] = _paintSettingsModel.current_g;
				target[2] = target[6] = target[10] = target[14] = _paintSettingsModel.current_b;
			}
		}
		

		override protected function processPoint(point : SamplePoint) : void
		{
			var minSize:Number = _maxBrushRenderSize * _sizeFactor.lowerRangeValue;
			var maxSize:Number = _maxBrushRenderSize * _sizeFactor.upperRangeValue;
			var rsize : Number = minSize + (maxSize - minSize) * point.size;
			if (rsize > maxSize) rsize = maxSize;
			else if (rsize < minSize) rsize = minSize;

			_brushShape.getClosestColorMatchYUV(point.colorsRGBA, _appendVO.uvBounds, 0.06, _yuvMatchingWeights);
			
			_appendVO.size = rsize * _canvasScaleW;
			_appendVO.point = point;
			_brushMesh.append(_appendVO);
		}


	}

}
