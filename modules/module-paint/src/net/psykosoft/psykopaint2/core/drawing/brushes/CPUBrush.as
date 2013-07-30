package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import com.quasimondo.geom.Circle;
	import com.quasimondo.geom.LinearMesh;
	import com.quasimondo.geom.LinearPath;
	import com.quasimondo.geom.PeuckerSimplification;
	import com.quasimondo.geom.Polygon;
	import com.quasimondo.geom.Triangle;
	import com.quasimondo.geom.Vector2;
	import com.quasimondo.geom.utils.PolygonUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapTdsiStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TextureMorphingSplatMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TexturedAntialiasedColoredTriangleStroke;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TexturedTriangleStroke;
	import net.psykosoft.psykopaint2.core.drawing.data.DelaunayMetaData;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	
	public class CPUBrush extends AbstractBrush
	{

		private var pathPoints:Vector.<Vector2>;
		private const ps:PeuckerSimplification = new PeuckerSimplification();
		
		public function CPUBrush()
		{
			super(true);
			type = BrushType.BLOB;
			
			_shininess.numberValue = .3;
			_glossiness.numberValue = .25;
			_bumpiness.numberValue = .6;
			
			_appendVO.verticesAndUV = new Vector.<Number>(36,true);
			_appendVO.point = new SamplePoint();
			_appendVO.point.colorsRGBA[3] = _appendVO.point.colorsRGBA[7] = _appendVO.point.colorsRGBA[11] = 1;
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
			return new TexturedAntialiasedColoredTriangleStroke()
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
			TexturedAntialiasedColoredTriangleStroke(_brushMesh).brushTexture = _brushShape.texture;
			TexturedAntialiasedColoredTriangleStroke(_brushMesh).normalTexture = _brushShape.normalSpecularMap;
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
			(_view as Sprite).graphics.clear();
			(_view as Sprite).graphics.lineStyle(0);
			
		}
		
		override  protected function onPathPoints(points : Vector.<SamplePoint>) : void
		{
			var len : uint = points.length;
			var i0:int = 0;
			if (len > 0 && _firstPoint )
			{
				(_view as Sprite).graphics.moveTo( points[0].x,points[0].y);
				pathPoints.push( new Vector2(points[0].x,points[0].y));
				i0++;
			}
			
			for (var i : int = i0; i < len; i++) {
				var point : SamplePoint = points[i];
				(_view as Sprite).graphics.lineTo( point.x,point.y);
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
			(_view as Sprite).graphics.clear();
			if ( pathPoints.length > 1 )
			{
				var lm:LinearMesh = new LinearMesh();
				pathPoints = ps.simplifyPath( pathPoints, 0.5);
				lm.addPathFromPoints(pathPoints);
				var polys:Vector.<Polygon> = lm.getPolygons();
				if ( polys.length == 0 )
				{
					lm.addPointConnection(pathPoints[0],pathPoints[pathPoints.length-1]);
					polys= lm.getPolygons();
				}
				
				var vertexUVData:Vector.<Number> = _appendVO.verticesAndUV;
				var colors:Vector.<Number> = _appendVO.point.colorsRGBA;
				 
				if ( polys.length > 0 )
				{
					for ( var i:int = 0; i < polys.length; i++ )
					{
						var poly:Polygon = polys[i];
						PolygonUtils.simplify( poly,2);
						PolygonUtils.blur(poly,8);
						var center:Vector2 = poly.centroid;
						var bds:Rectangle = poly.getBoundingRect();
						var size:Number = 0.5 * Math.sqrt(bds.width*bds.width + bds.height*bds.height);
						
						_colorStrategy.getColor(center.x,center.y,size,colors,7);
						
						var triangles:Vector.<Triangle> = PolygonUtils.triangulate(poly,PolygonUtils.SPLIT_SIMPLE,0,false);
						
						for ( var j:int = 0; j < triangles.length; j++ )
						{
						 	var triangle:Triangle = triangles[j].clone(true) as Triangle;
							triangle.draw((_view as Sprite).graphics);
							
							var inc:Circle = triangle.inCircle;
							//var scale:Number = (inc.r + 0.6) / inc.r;
							//triangle.scale( scale, scale, inc.c );
							var x1:Number = triangle.p1.x;
							var y1:Number = triangle.p1.y ;
							var x2:Number = triangle.p2.x;
							var y2:Number = triangle.p2.y;
							var x3:Number = triangle.p3.x;
							var y3:Number = triangle.p3.y;
							
							
							var bounds:Circle = triangle.getBoundingCircle();
							var tri_c:Vector2 = bounds.c;
							
							//vertex 1 - xy
							vertexUVData[0] = x1 * _canvasScaleW - 1.0;
							vertexUVData[1] = -(y1 * _canvasScaleH - 1.0);
							//vertex 1 - uv
							vertexUVData[2] = 0.5 + (triangle.p1.x - tri_c.x) * _canvasScaleW;
							vertexUVData[3] = 0.5 - (triangle.p1.y - tri_c.y) * _canvasScaleH;
							//vertex 1 - triangle side distance;
							vertexUVData[8]  =  triangle.p1.distanceToLine( triangle.p2, triangle.p3 );
							
							
							//vertex 2 - xy
							vertexUVData[12] = x2 * _canvasScaleW - 1.0;
							vertexUVData[13] = -(y2 * _canvasScaleH - 1.0);
							//vertex 2 - uv
							vertexUVData[14] = 0.5 + (triangle.p2.x - tri_c.x) * _canvasScaleW;
							vertexUVData[15] = 0.5 - (triangle.p2.y - tri_c.y) * _canvasScaleH;
							//vertex 2 - triangle side distance;
							vertexUVData[20] = triangle.p2.distanceToLine( triangle.p1, triangle.p3 );
							
							//vertex3 - xy
							vertexUVData[24] = x3 * _canvasScaleW - 1.0;
							vertexUVData[25] = -(y3 * _canvasScaleH - 1.0);
							//vertex 3 - uv
							vertexUVData[26] = 0.5 + (triangle.p3.x - tri_c.x) * _canvasScaleW;
							vertexUVData[27] = 0.5 - (triangle.p3.y - tri_c.y) * _canvasScaleH;
							//vertex 3 - triangle side distance;
							vertexUVData[32] = triangle.p3.distanceToLine( triangle.p1, triangle.p2 );
							
							
							_brushMesh.append( _appendVO );
						}
					}
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
