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
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	
	public class DrawingApiBrush extends AbstractBrush
	{

		private var pathPoints:Vector.<Vector2>;
		private const ps:WhyattSimplification = new WhyattSimplification();
		private var shpHolder:Sprite;
		private var previewShp:Shape;
		private var shp1:Shape;
		private var shp2:Shape;
		private var shp3:Shape;
		private var opacity:Number;
		private var drawMatrix:Matrix;
		private var fillMatrix:Matrix;
		
		private var testTexture:BitmapData;
		[Embed( source = "shapes/assets/fabric2.png", mimeType="image/png")]
		protected var SourceImage : Class;
		private var _pathSmoothing:PsykoParameter;
		private var _edgeType:PsykoParameter;
		
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
			previewShp = new Shape();
			shpHolder = new Sprite();
			shp1 = new Shape();
			shp2 = new Shape();
			shp3 = new Shape();
			shp1.alpha = 0.25;
			shp1.blendMode = "normal";
			shp3.blendMode = "multiply";
			shpHolder.addChild(shp1);
			shpHolder.addChild(shp2);
			shpHolder.addChild(shp3);
			shp1.filters = [ new BlurFilter(16,16,2)];
			
			drawMatrix = new Matrix();
			fillMatrix = new Matrix();
			//x,y,u,v,d1,d2,d3,unused
			for ( var i:int = 0; i < 36; i++ )
			{
				_appendVO.verticesAndUV[i] = 0;
			}
			testTexture = (new SourceImage() as Bitmap).bitmapData;
			
			_pathSmoothing = new PsykoParameter( PsykoParameter.NumberParameter, "Path Smoothing", 0.5, 0, 1 );
			_edgeType = new PsykoParameter( PsykoParameter.StringListParameter,"Edge Type",0,["Straight","Zig Zag","Wave","Ripped"]);
			_parameters.push(_pathSmoothing,_edgeType);
		}

		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel, renderer:CanvasRenderer, paintSettingsModel : UserPaintSettingsModel) : void
		{
			super.activate(view, context, canvasModel, renderer, paintSettingsModel);
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
			pathPoints = new Vector.<Vector2>();
			previewShp.graphics.clear();
			previewShp.graphics.lineStyle(0);
			_view.stage.quality = StageQuality.HIGH;
			(_view as Sprite).addChild(previewShp);
			previewShp.scaleX = 1 / _pathManager.canvasScaleX / CoreSettings.GLOBAL_SCALING;
			previewShp.scaleY = 1 / _pathManager.canvasScaleY / CoreSettings.GLOBAL_SCALING; 
			previewShp.x = -_pathManager.canvasOffsetX / (_pathManager.canvasScaleX / CoreSettings.GLOBAL_SCALING);
			previewShp.y = -_pathManager.canvasOffsetY / (_pathManager.canvasScaleY / CoreSettings.GLOBAL_SCALING); 
		}
		
		override  protected function onPathPoints(points : Vector.<SamplePoint>) : void
		{
			var len : uint = points.length;
			var i0:int = 0;
			if (len > 0 && _firstPoint )
			{
				previewShp.graphics.moveTo( points[0].x,points[0].y);
				pathPoints.push( new Vector2(points[0].x,points[0].y));
				i0++;
				opacity = points[0].colorsRGBA[3];
			}
			
			for (var i : int = i0; i < len; i++) {
				var point : SamplePoint = points[i];
				previewShp.graphics.lineTo( point.x,point.y);
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
			(_view as Sprite).removeChild(previewShp);
			var g1:Graphics = shp1.graphics;
			var g2:Graphics = shp2.graphics;
			var g3:Graphics = shp3.graphics;
			g1.clear();
			g1.lineStyle();
			g2.clear();
			g2.lineStyle();
			g3.clear();
			g3.lineStyle();
			
			if ( pathPoints.length > 1 )
			{
				var smoothing:Number = _pathSmoothing.numberValue;
				var edgeType:int = _edgeType.index;
				
				var colors:Vector.<Number> = _appendVO.point.colorsRGBA;
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
					
					
					for ( var i:int = 0; i < polys.length; i++ )
					{
						var poly:Polygon = polys[i];
						
						var center:Vector2 = poly.centroid;
						var polyBounds:Rectangle = poly.getBoundingRect();
						if ( poly.windingDirection == "CW" ) poly.reverse();
						//var lp1:LinearPath = PolygonUtils.getSmoothPath(poly,smoothing).toLinearPath(4,0);
						var sp:MixedPath = PolygonUtils.getSmoothPath(poly,smoothing);
					//	var poly2:Polygon = sp.toPolygon(4);
						var lp1:LinearPath = sp.toLinearPath(4,0);
						
						var l:Number = lp1.length;
					
						//var lp:LinearPath = LinearPathUtils.getFunctionPath(lp,function( t, functionFactor):Number{ return Math.random()*2-1;},1,1,0);
						var lp:LinearPath = LinearPathUtils.getFunctionPath(lp1,function( t, functionFactor):Number{ return 3 + Math.sin(t*Math.PI*2*functionFactor);},4,2,l*0.05);
						//var lp:LinearPath = PolygonUtils.getFunctionPath(poly2,function( t, functionFactor):Number{ return 3 + Math.sin(t*Math.PI*2*functionFactor);},4,3,l*0.05);
						
						//
							
						fillMatrix.identity();
						fillMatrix.rotate( (Math.random()-Math.random())*Math.PI*0.5);
						//var s:Number = 0.1 + Math.random() * 0.03;
						//fillMatrix.scale(s,s);
						fillMatrix.translate(Math.random()*1024,Math.random()*1024);
						
						/*
						var c:int = lp.pointCount * (0.1 + Math.random() * 0.4);
						var idx:int = Math.random() * lp.pointCount;
						while ( --c > -1 )
						{
							g2.lineStyle(Math.random()*5,0xffffff);
							lp.getSegment(idx++).draw(g2);
						}
						g2.lineStyle();
						*/
						
						g2.beginBitmapFill(testTexture,fillMatrix,true,true);
						lp.draw(g2);
						g2.endFill();
						
						
						
						_colorStrategy.getColor(center.x,center.y,Math.min(polyBounds.width,polyBounds.height) * 0.5,colors,1);
						g3.beginFill((int(0xff *colors[0]) << 16) | (int(0xff * colors[1]) << 8) | int(0xff * colors[2]),opacity);
						lp.draw(g3);
						g3.endFill();
						
						g3.lineStyle(2,0xffffff);
						for ( var j:int = 0; j < lp1.pointCount; j+=2 )
						{
							lp1.getSegment(j).draw(g3);
						}
						
						
						for ( j = 0; j < poly.pointCount; j++ )
						{
							if( Math.random() < 0.5 ) poly.getPointAt(j).minus(poly.getNormalAtIndex(j,16 * (Math.random()-Math.random())));
						}
						var mp:MixedPath = PolygonUtils.getSmoothPath(poly,1);
						
						g1.beginFill(0x000000);
						mp.draw(g1);
						g1.endFill();
					}
					
					
					var bds:Rectangle = shpHolder.getBounds(shpHolder);
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
					bm.drawWithQuality(shpHolder,drawMatrix,null,"normal",null,true,StageQuality.HIGH);
					//bm.drawWithQuality(shp1,drawMatrix,null,"normal",null,true,StageQuality.HIGH);
					//bm.drawWithQuality(shp2,drawMatrix,null,"multiply",null,true,StageQuality.HIGH);
					_brushShape.update(false);
					
					
					
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
