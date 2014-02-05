package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import com.quasimondo.geom.Circle;
	import com.quasimondo.geom.LineSegment;
	import com.quasimondo.geom.LinearMesh;
	import com.quasimondo.geom.LinearPath;
	import com.quasimondo.geom.MixedPath;
	import com.quasimondo.geom.MixedPathPoint;
	import com.quasimondo.geom.PeuckerSimplification;
	import com.quasimondo.geom.Polygon;
	import com.quasimondo.geom.Triangle;
	import com.quasimondo.geom.Vector2;
	import com.quasimondo.geom.WhyattSimplification;
	import com.quasimondo.geom.utils.LinearPathUtils;
	import com.quasimondo.geom.utils.MixedPathUtils;
	import com.quasimondo.geom.utils.PolygonUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.filters.GradientGlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapIntrinsicsStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.RenderTextureBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.DrawingApiMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TextureMorphingSplatMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TextureSplatMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TexturedAntialiasedColoredTriangleStroke;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TexturedTriangleStroke;
	import net.psykosoft.psykopaint2.core.drawing.data.DelaunayMetaData;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	
	public class ClassicPsykoBrush extends AbstractBrush
	{

		private var previewShp:Shape;
		private var previewBmd:Bitmap;
		
		private var opacity:Number;
		private var drawMatrix:Matrix;
		private var fillMatrix:Matrix;
		
		protected var SourceImage : Class;
		private var _density:PsykoParameter;
		private var baseOffsets:Vector.<Point>
		private var lastPoints:Vector.<Point>

		private var drawingBmd:BitmapData;
		
		public function ClassicPsykoBrush()
		{
			super(false);
			type = BrushType.BLOB;
			
			_shininess.numberValue = .3;
			_glossiness.numberValue = .25;
			_bumpiness.numberValue = .6;
			
			_appendVO.verticesAndUV = new Vector.<Number>(36,true);
			_appendVO.point = new SamplePoint();
			_appendVO.point.colorsRGBA[3] = _appendVO.point.colorsRGBA[7] = _appendVO.point.colorsRGBA[11] = 1;
			previewShp = new Shape();
			
			baseOffsets = new Vector.<Point>()
			lastPoints = new Vector.<Point>()
				
			drawMatrix = new Matrix();
			fillMatrix = new Matrix();
			
			drawingBmd = new TrackedBitmapData( 1024 * CoreSettings.GLOBAL_SCALING,768 * CoreSettings.GLOBAL_SCALING,true,0);
			previewBmd = new Bitmap(drawingBmd,"auto",true);
			//x,y,u,v,d1,d2,d3,unused
			for ( var i:int = 0; i < 36; i++ )
			{
				_appendVO.verticesAndUV[i] = 0;
			}
			
			_density = new PsykoParameter( PsykoParameter.IntParameter, "Density", 64, 1, 64 );
			
			_parameters.push(_density);
		}

		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel, renderer:CanvasRenderer, paintSettingsModel : UserPaintSettingsModel) : void
		{
			super.activate(view, context, canvasModel, renderer, paintSettingsModel );
			if (_brushShape)
				assignBrushShape();
		}

		override protected function createBrushMesh() : IBrushMesh
		{
			return new DrawingApiMesh()
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
			DrawingApiMesh(_brushMesh).brushTexture = _brushShape.texture;
			DrawingApiMesh(_brushMesh).normalTexture = _brushShape.normalSpecularMap;
			_pathManager.brushAngleRange = brushShape.rotationRange;
		}

		override protected function createColorStrategy() : IColorStrategy
		{
			return new PyramidMapIntrinsicsStrategy(_canvasModel);
		}
		
		override protected function onPathStart() : void
		{
			super.onPathStart();
			previewShp.graphics.clear();
			//previewShp.graphics.lineStyle(2,0xff0000);
			//previewShp.graphics.drawRect(0,0,1024,768);
			
			previewShp.graphics.lineStyle(0,0,0.25);
		//	_view.stage.quality = StageQuality.HIGH;
			(_view as Sprite).addChild(previewBmd);
			(_view as Sprite).addChild(previewShp);
			
			while ( baseOffsets.length < _density.intValue )
			{
				baseOffsets.push( new Point());
				lastPoints.push( new Point());
			}
			
			for ( var i:int = 0; i <_density.intValue; i++ )
			{
				baseOffsets[i].x = (Math.random() - Math.random()) * 32;
				baseOffsets[i].y = (Math.random() - Math.random()) * 32;
			}
			
			var m:Matrix = _pathManager.canvasMatrix;
			
			previewBmd.scaleX = previewShp.scaleX = m.a / CoreSettings.GLOBAL_SCALING;
			previewBmd.scaleY = previewShp.scaleY = m.d / CoreSettings.GLOBAL_SCALING; 
			previewBmd.x = previewShp.x = m.tx * 1024,
			previewBmd.y = previewShp.y = m.ty * 768; 
			
		}
		
		override  protected function onPathPoints(points : Vector.<SamplePoint>) : void
		{
			var len : uint = points.length;
			var c:int = _density.intValue;
			var i0:int = 0;
			if (len > 0 && _firstPoint )
			{
				for ( var i:int = 0; i< c; i++ )
				{
					lastPoints[i].x = points[0].x + baseOffsets[i].x;
					lastPoints[i].y = points[0].y + baseOffsets[i].y;
				}
				i0++;
			}
			
			for ( var j:int = i0; j< len; j++ )
			{
				for (  i = 0; i< c; i++ )
				{
					previewShp.graphics.moveTo(lastPoints[i].x,lastPoints[i].y);
					lastPoints[i].x = points[j].x + baseOffsets[i].x;
					lastPoints[i].y = points[j].y + baseOffsets[i].y;
					previewShp.graphics.lineTo(lastPoints[i].x,lastPoints[i].y);
				}
			}
			
			
			if ( _firstPoint )
			{
				_firstPoint = false;
				dispatchEvent(new Event(STROKE_STARTED));
			} 
			drawingBmd.lock();
			drawingBmd.draw(previewShp);
			drawingBmd.unlock(previewShp.getBounds(previewShp));
			previewShp.graphics.clear();
			previewShp.graphics.lineStyle(0,0,0.25);
			
		}

		
		override protected function onPathEnd() : void
		{
			(_view as Sprite).removeChild(previewShp);
			(_view as Sprite).removeChild(previewBmd);
			//var bds:Rectangle = previewShp.getBounds(previewShp);
			var bds:Rectangle = drawingBmd.getColorBoundsRect(0xff000000,0x00,false);
			if ( bds.width > 0 )
			{
				var obds:Rectangle = bds.clone();
				bds.x -= 8;
				bds.y -= 8;
				bds.width += 16;
				bds.height += 16;
				var bm:BitmapData = (_brushShape as RenderTextureBrushShape)._brushMap;
				drawMatrix.tx = -bds.x + 1;
				drawMatrix.ty = -bds.y + 1;
				_appendVO.diagonalAngle = Math.atan2(bds.height,bds.width);
				_appendVO.diagonalLength = Math.sqrt(bds.width*bds.width+bds.height*bds.height); 
				_appendVO.size = _canvasScaleW; 
				_appendVO.point.x = bds.x -1 + bds.width * 0.5
				_appendVO.point.y = bds.y -1 + bds.height * 0.5;
				_appendVO.point.normalizeXY(_canvasScaleW,_canvasScaleH);
				_appendVO.uvBounds.width  = (bds.width + 1) / _brushShape.size;
				_appendVO.uvBounds.height = (bds.height +1) / _brushShape.size;
					
				bds.x = bds.y = 0;
				bds.width += 2;
				bds.height += 2;
				bm.fillRect(bds,0);
				bm.draw(drawingBmd,drawMatrix,null,"normal",null,true);
				//bm.drawWithQuality(previewShp,drawMatrix,null,"normal",null,true,StageQuality.HIGH);
				_brushShape.update(false);
				_brushMesh.append(_appendVO);
					
				drawingBmd.fillRect(obds,0);
			
				invalidateRender();
			}
			
			//_view.stage.quality = StageQuality.LOW;
			setTimeout(super.onPathEnd,1);
		}
		/*
		override protected function onPickColor( point : SamplePoint, pickRadius : Number, smoothFactor : Number ) : void
		{
			
		}
		*/
		
		override protected function processPoint( point : SamplePoint) : void
		{
		}
	}
}
