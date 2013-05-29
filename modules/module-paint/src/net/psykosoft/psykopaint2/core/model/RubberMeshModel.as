package net.psykosoft.psykopaint2.core.model
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Stage3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.core.signals.RequestRenderRubberMeshSignal;
	
	public class RubberMeshModel
	{
		[Inject]
		public var stage3D : Stage3D;

		[Inject]
		public var requestRenderRubberMeshSignal : RequestRenderRubberMeshSignal;

		private var _sourceBitmapData : BitmapData;
		private var _sourceHeightBitmapData : BitmapData;
		private var _triangleBitmapData : BitmapData;
		
		private var _sourceTexture : Texture;
		private var _cachedComposite : Texture;
		private var _triangleTexture : Texture;
		
		private var _canvasWidth : Number;
		private var _canvasHeight : Number;
		
		private var _textureWidth : Number;
		private var _textureHeight : Number;

		public var meshPoints:Vector.<Pin>;
		private var meshx:int;
		private var meshy:int;
		private var meshCount:int;
		private var _gridSize:Number;
		private var _numVertices:int;
		private var _numIndices:int;
		private var verticesHorizontal1:int;
		private var verticesHorizontal2:int;

		private var _indexData:Vector.<uint>;
		
		private var pinGrid:PinGrid;
		private var _vertexData:Vector.<Number>;
		
		public function RubberMeshModel()
		{

		}

		public function get width() : Number
		{
			return _canvasWidth;
		}

		public function get height() : Number
		{
			return _canvasHeight;
		}
		
		
		public function get textureWidth() : Number
		{
			return _textureWidth;
		}
		
		public function get textureHeight() : Number
		{
			return _textureHeight;
		}

		public function get sourceBitmapData() : BitmapData
		{
			return _sourceBitmapData;
		}

		public function set sourceBitmapData(sourceBitmapData : BitmapData) : void
		{
			if (_sourceBitmapData && _sourceBitmapData != sourceBitmapData) _sourceBitmapData.dispose();

			_sourceBitmapData = sourceBitmapData;
			_sourceTexture.uploadFromBitmapData(_sourceBitmapData);

			requestRenderRubberMeshSignal.dispatch();
		}

		
		public function get sourceTexture() : Texture
		{
			return _sourceTexture;
		}

		public function get triangleTexture() : Texture
		{
			return _triangleTexture;
		}

		
		public function init(textureWidth : uint, textureHeight : uint, canvasWidth : uint, canvasHeight : uint) : void
		{
			if (canvasWidth == _canvasWidth && canvasHeight == _canvasHeight)
				return;

			dispose();
			_canvasWidth = canvasWidth;
			_canvasHeight = canvasHeight;
			
			_textureWidth = textureWidth;
			_textureHeight = textureHeight;

			_cachedComposite = createCanvasTexture(true);
			_sourceTexture = createCanvasTexture(false);
			
			_sourceBitmapData = new BitmapData(textureWidth, textureHeight, false, 0xffffffff);
			_sourceTexture.uploadFromBitmapData(_sourceBitmapData);

			
			_triangleTexture = createCanvasTexture(false);
			_triangleBitmapData  = new BitmapData(textureWidth, textureHeight, true, 0); 
			var shp:Shape = new Shape();
			shp.graphics.lineStyle(64,0xffffff,0.5);
			shp.graphics.moveTo(0,0);
			shp.graphics.lineTo(textureWidth,textureHeight);
			shp.graphics.drawRect(0,0,textureWidth,textureHeight);
			_triangleBitmapData.draw(shp);
			_triangleBitmapData.applyFilter(_triangleBitmapData,_triangleBitmapData.rect,new Point(), new BlurFilter(32,32,2));
			_triangleTexture.uploadFromBitmapData(_triangleBitmapData);
			
			_gridSize = 16;
			//initSquareMesh(_gridSize);
			
			initTriangularMesh(_gridSize);
		}

		public function createCanvasTexture(isRenderTarget : Boolean, scale : Number = 1) : Texture
		{
			return stage3D.context3D.createTexture(_textureWidth*scale, _textureHeight*scale, Context3DTextureFormat.BGRA, isRenderTarget);
		}

		public function dispose() : void
		{
			_canvasWidth = 0;
			_canvasHeight = 0;
			if (!_sourceBitmapData) return;
			_sourceBitmapData.dispose();
			_sourceHeightBitmapData.dispose();
			_sourceTexture.dispose();
			
			
			_sourceBitmapData = null;
			_sourceHeightBitmapData = null;
			_sourceTexture = null;
		}

		
		public function get cachedComposite() : Texture
		{
			return _cachedComposite;
		}
		
		private function initTriangularMesh(  gridSize:Number  ):void
		{
			
			pinGrid = new PinGrid(-1,1,-1,1,0.02 );
			
			var hstep:Number = gridSize;
			var vstep:Number = Math.sin(60 / 180 * Math.PI )*hstep;
			
			var x:Number = 0;
			var y:Number = 0;
			var alter:Boolean = false;
			var lastLine:Boolean = false;
			var hCount:int = Math.ceil(_canvasWidth / hstep) + 1;
			var px:Number = 0;
			var py:Number = 0;
			var pin:Pin;
			meshCount = 0;
			var mp:Vector.<Pin> = meshPoints = new Vector.<Pin>();
			while ( true )
			{
				px = Math.max(0,Math.min(x,_canvasWidth)) / _canvasWidth;
				
				mp[meshCount++] = pin = new Pin(2*(px - 0.5),-2*(py - 0.5),px,py,px==0 || py==0 || px == 1 || py ==1);
				pin.index = meshCount-1;
				pinGrid.addPin( pin );
				x += hstep;
				if ( x >= _canvasWidth )
				{
					px = Math.max(0,Math.min(x,_canvasWidth)) / _canvasWidth;
					mp[meshCount++] = pin = new Pin(2*(px - 0.5),-2*(py - 0.5),px,py,px==0 || py==0 || px == 1 || py ==1);
					pin.index = meshCount-1;
					pinGrid.addPin( pin );
					alter = !alter;
					x = ( alter ? -hstep * 0.5 : 0 );
					y += vstep;
					py = Math.max(0,Math.min(y,_canvasHeight)) / _canvasHeight;
					if ( lastLine ) break;
					if ( y > _canvasHeight ) lastLine = true;
				}
			}
			
			_indexData = new Vector.<uint>();
			var hs:Number = 2 * (hstep / _canvasWidth);
			var l:int = 0;
			
			alter = false;
			for ( var i:int = 0; i < meshCount; i++ )
			{
				if ( i <meshCount -1 )
				{
					var indices:Array = [];
					var ip:int =  i + hCount + ( alter ? 1 : 0 );
					if (ip < meshCount -1 )
					{
						if ( Math.abs( mp[ip].x - mp[i].x ) < hs )
						{
							indices.push(ip); 
						} else if ( Math.abs( mp[ip-1].x - mp[i].x ) < hs )
						{
							ip-=1;
							indices.push(ip); 
						}
					}
					ip += ( alter ? -1 : 1);
					if (ip < meshCount -1 )
					{
						indices.push(ip);
					}
					if ( mp[i].y == mp[i+1].y )
					{
						indices.push(i+1);
					} else {
						
						alter = !alter;
					}
					
					if ( indices.length == 3 )
					{
						_indexData.push(i,indices[0]);
						mp[i].setConnection(mp[indices[0]]);
						if ( alter )
						{
							_indexData.push(indices[2]);
							mp[i].setConnection(mp[indices[2]]);
							mp[indices[0]].setConnection(mp[indices[2]]);
							
						} else {
							_indexData.push(indices[1]);
							mp[i].setConnection(mp[indices[1]]);
							mp[indices[0]].setConnection(mp[indices[1]]);
							
						}
						if ( !alter )
						{
							_indexData.push(i,indices[0]+1,indices[2]);
							mp[i].setConnection(mp[indices[0]+1]);
							mp[i].setConnection(mp[indices[2]]);
							mp[indices[0]+1].setConnection(mp[indices[2]]);
						} else {
							if ( mp[indices[0]].y == mp[indices[0]-1].y )
							{
								_indexData.push(i,indices[0],indices[0]-1);
								mp[i].setConnection(mp[indices[0]]);
								mp[i].setConnection(mp[indices[0]-1]);
								mp[indices[0]].setConnection(mp[indices[0]-1]);
							}
						}
					} else if ( !alter && indices.length == 2 ) {
						if ( mp[i-1].x > mp[indices[1]-1].x && mp[i-1].x < mp[indices[1]].x )
						{
							
							_indexData.push(indices[1],indices[1]-1,i-1);
							mp[indices[1]].setConnection(mp[indices[1]-1]);
							mp[indices[1]].setConnection(mp[i-1]);
							mp[indices[1]-1].setConnection(mp[i-1]);
							
						
						}
					}
				}
			}
			_numVertices = meshCount;
			_numIndices = _indexData.length;
		}
		
		public function get numIndices():int
		{
			return _numIndices;
		}
		
		public function get numVertices():int
		{
			return _numVertices;
		}
		
		public function updateMesh():void
		{
			var ap:Object = Pin.activePins;
			var vd:Vector.<Number> = _vertexData;
			for each ( var pin:Pin in ap )
			{
				pin.calculate();
				var v:Number = Math.sqrt( pin.vx * pin.vx + pin.vy * pin.vy) ;
				if ( v > 0 ) pin.average( v / 0.3);
				pinGrid.updatePin(pin);
				vd[int(pin.index * 4)] = pin.x;
				vd[int(pin.index * 4+1)] = pin.y;
			}
			/*
			for each (  pin in ap )
			{
				
			}
			*/
			
			
			ap = Pin.affectedPins
			for each (  pin in ap )
			{
				pin.average();
				pinGrid.updatePin(pin);
				vd[int(pin.index*4)] = pin.x;
				vd[int(pin.index*4+1)] = pin.y;
			}
			
			Pin.currentIteration++;
			Pin.activePins = {};
			Pin.affectedPins = {};
		}
		
		public function getPinsInRect(rect:Rectangle):Vector.<Pin>
		{
			return pinGrid.getPinsInRect( rect );
		}
		
		public function getPinsAroundLine(x1:Number, y1:Number, x2:Number, y2:Number, radius:Number):Vector.<Pin>
		{
			return pinGrid.getPinsAroundLine( x1, y1, x2, y2, radius );
		}
		
		public function getPinsInCircle(x:Number, y:Number, radius:Number):Vector.<Pin>
		{
			return pinGrid.getPinsInCircle( x, y, radius );
		}
		
		public function get indexData():Vector.<uint>
		{
			return _indexData;
		}
		
		public function initVertexData( vertexData:Vector.<Number> ):void
		{
			var c:int = 0;
			var pin:Pin;
			var j:int = 0;
			var mp:Vector.<Pin> = meshPoints;
			for (var i:int=0;i<meshCount;i++)
			{
				pin = mp[i];
				vertexData[c++] = pin.x;
				vertexData[c++] = pin.y;
				vertexData[c++] = pin.sx;
				vertexData[c++] = pin.sy;
			}	
			_vertexData = vertexData;
		}
		
		/*
		public function updateVertexData( vertexData:Vector.<Number> ):void
		{
			var c:int = 0;
			var pin:Pin;
			var j:int = 0;
			var mp:Vector.<Pin> = meshPoints;
			for (var i:int=0;i<meshCount;i++)
			{
				pin = mp[i];
				vertexData[c++] = pin.x;
				vertexData[c++] = pin.y;
				vertexData[c++] = pin.sx;
				vertexData[c++] = pin.sy;
			}	
		}
		*/
		/*
		public function updateVertexData( vertexData:Vector.<Number> ):void
		{
			var c:int = 0;
			var pin:Pin;
			var idx:int = 0;
			for (var iy:int=0;iy<meshy-1;iy++)
			{
				for (var ix:int=0;ix<meshx-1;ix++)
				{
					idx=ix+iy*meshx;
					
					pin = meshPoints[idx];
					vertexData[c++] = pin.x;
					vertexData[c++] = pin.y;
					vertexData[c++] = pin.sx;
					vertexData[c++] = pin.sy;
					vertexData[c++] = 0;
					vertexData[c++] = 0;
					
					pin = meshPoints[idx+1];
					vertexData[c++] = pin.x;
					vertexData[c++] = pin.y; 
					vertexData[c++] = pin.sx;
					vertexData[c++] = pin.sy;
					vertexData[c++] = 1;
					vertexData[c++] = 0;
					
					pin = meshPoints[idx+meshx+1];
					vertexData[c++] = pin.x;
					vertexData[c++] = pin.y;
					vertexData[c++] = pin.sx;
					vertexData[c++] = pin.sy;
					vertexData[c++] = 1;
					vertexData[c++] = 1;
					
					pin = meshPoints[idx+meshx];
					vertexData[c++] = pin.x;
					vertexData[c++] = pin.y;
					vertexData[c++] = pin.sx;
					vertexData[c++] = pin.sy;
					vertexData[c++] = 0;
					vertexData[c++] = 1;
					
				}
				
			}	
		
		}
		*/
	}
}
