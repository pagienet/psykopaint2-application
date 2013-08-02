package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import com.quasimondo.geom.Circle;
	import com.quasimondo.geom.LinearMesh;
	import com.quasimondo.geom.LinearPath;
	import com.quasimondo.geom.PeuckerSimplification;
	import com.quasimondo.geom.Polygon;
	import com.quasimondo.geom.Triangle;
	import com.quasimondo.geom.Vector2;
	import com.quasimondo.geom.WhyattSimplification;
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
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapTdsiStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.RenderTextureBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.DrawingApiMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TextureMorphingSplatMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TextureSplatMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TexturedAntialiasedColoredTriangleStroke;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TexturedTriangleStroke;
	import net.psykosoft.psykopaint2.core.drawing.data.DelaunayMetaData;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	
	public class DrawingApiBrush extends AbstractBrush
	{

		private var pathPoints:Vector.<Vector2>;
		private const ps:WhyattSimplification = new WhyattSimplification();
		private var shp:Shape;
		
		public function DrawingApiBrush()
		{
			super(true);
			type = BrushType.BLOB;
			
			_shininess.numberValue = .3;
			_glossiness.numberValue = .25;
			_bumpiness.numberValue = .6;
			
			_appendVO.verticesAndUV = new Vector.<Number>(36,true);
			_appendVO.point = new SamplePoint();
			_appendVO.point.colorsRGBA[3] = _appendVO.point.colorsRGBA[7] = _appendVO.point.colorsRGBA[11] = 1;
			shp = new Shape();
			
			//x,y,u,v,d1,d2,d3,unused
			for ( var i:int = 0; i < 36; i++ )
			{
				_appendVO.verticesAndUV[i] = 0;
			}
			
		}

		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel, renderer:CanvasRenderer) : void
		{
			super.activate(view, context, canvasModel, renderer);
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
			return new PyramidMapTdsiStrategy(_canvasModel);
		}
		
		override protected function onPathStart() : void
		{
			super.onPathStart();
			pathPoints = new Vector.<Vector2>();
			shp.graphics.clear();
			shp.graphics.lineStyle(0);
			_view.stage.quality = StageQuality.HIGH;
			(_view as Sprite).addChild(shp);
			
		}
		
		override  protected function onPathPoints(points : Vector.<SamplePoint>) : void
		{
			var len : uint = points.length;
			var i0:int = 0;
			if (len > 0 && _firstPoint )
			{
				shp.graphics.moveTo( points[0].x,points[0].y);
				pathPoints.push( new Vector2(points[0].x,points[0].y));
				i0++;
			}
			
			for (var i : int = i0; i < len; i++) {
				var point : SamplePoint = points[i];
				shp.graphics.lineTo( point.x,point.y);
				pathPoints.push( new Vector2(point.x,point.y));
			}
			
			if ( _firstPoint )
			{
				_firstPoint = false;
				dispatchEvent(new Event(STROKE_STARTED));
			} 
		}

		
		override protected function onPathEnd() : void
		{
			(_view as Sprite).removeChild(shp);
			var g:Graphics = shp.graphics;
		
			g.clear();
			if ( pathPoints.length > 1 )
			{
				var lm:LinearMesh = new LinearMesh();
				pathPoints = ps.simplifyPath( pathPoints, 100);
				lm.addPathFromPoints(pathPoints);
				var polys:Vector.<Polygon> = lm.getPolygons();
				if ( polys.length == 0 )
				{
					lm.addPointConnection(pathPoints[0],pathPoints[pathPoints.length-1]);
					polys= lm.getPolygons();
				}
				
				if ( polys.length > 0 )
				{
					g.beginFill(0);
					
					for ( var i:int = 0; i < polys.length; i++ )
					{
						var poly:Polygon = polys[i];
						poly.draw(g);
					}
					g.endFill();
					
					var bds:Rectangle = shp.getBounds(shp);
					trace(bds);
					var bm:BitmapData = (_brushShape as RenderTextureBrushShape)._brushMap;
					bm.fillRect(bm.rect,0);
					var m:Matrix = new Matrix( 1,0,0,1,-bds.x + 1, -bds.y +1);
					bm.drawWithQuality(shp,m,null,"normal",null,true,StageQuality.HIGH);
					_brushShape.update(false);
					
					
					
					_appendVO.size =  _canvasScaleW; 
					_appendVO.point.x = bds.x -1 + _brushShape.size * 0.5
					_appendVO.point.y = bds.y -1 + _brushShape.size * 0.5;
					_appendVO.point.normalizeXY(_canvasScaleW,_canvasScaleH);
					_brushMesh.append(_appendVO);
					
					
				}
				invalidateRender();
			}
			setTimeout(super.onPathEnd,1);
		}
		override protected function onPickColor( point : SamplePoint, pickRadius : Number, smoothFactor : Number ) : void
		{
			
		}

		
		override protected function processPoint( point : SamplePoint) : void
		{
		}
	}
}
