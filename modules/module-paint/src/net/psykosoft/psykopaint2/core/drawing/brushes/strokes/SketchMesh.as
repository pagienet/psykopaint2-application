package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.tdsi.FastBuffer;

	public class SketchMesh extends AbstractBrushMesh
	{
		protected static var _tmpData:Vector.<Number>;

		protected var fragmentConstants:Vector.<Number>;
		private var _vertexData : Vector.<Number>;
		private var _fragmentData : Vector.<Number>;

		public function SketchMesh()
		{
			super();

			if (!_tmpData )
			{
				_tmpData = new Vector.<Number>(32,true);
			}

			_vertexData = Vector.<Number>([0, 0, 0, 0]);
			_fragmentData = Vector.<Number>([0,.1, 0, 0]);
			fragmentConstants = Vector.<Number>([0,0,0.1,1,0,0,0,0]);
		}

		public function setSurfaceRelief(value : Number) : void
		{
			_fragmentData[0] = value;
		}

		override public function append( appendVO:StrokeAppendVO ):void
		{
			//check for maximum vertex count
			if ( _numVertices >= 65531 ) return;

			var uvBounds:Rectangle = appendVO.uvBounds;
			var baseAngle:Number = appendVO.diagonalAngle; //Math.atan2(uvBounds.height,uvBounds.width);
			//var halfSize : Number = appendVO.size * Math.SQRT1_2;
			var halfSize : Number = appendVO.size * appendVO.diagonalLength * 0.5;//appendVO.size * Math.SQRT1_2;
			
			var angle : Number = appendVO.point.angle;
			var cos1 : Number =   halfSize * Math.cos(  baseAngle + angle);
			var sin1 : Number =  -halfSize * Math.sin(  baseAngle + angle);
			var cos2 : Number =   halfSize * Math.cos( -baseAngle + angle);
			var sin2 : Number =  -halfSize * Math.sin( -baseAngle + angle);

			
			var ox:Number = appendVO.quadOffsetRatio * (-cos1 - cos2);
			var oy:Number = appendVO.quadOffsetRatio * (-sin1 - sin2);
			
			var point:SamplePoint = appendVO.point;
			var pnx:Number = point.normalX;
			var pny:Number = point.normalY;

			var v : Number;
			var m:Number = Math.max( cos1, -cos1, cos2, -cos2 );
			if ((v = pnx + m) > _maxX) _maxX = v;
			if ((v = pnx - m) < _minX) _minX = v;
			m = Math.max( sin1, -sin1, sin2, -sin2 );
			if ((v = pny + m) > _maxY) _maxY = v;
			if ((v = pny - m) < _minY) _minY = v;

			var data:Vector.<Number> = _tmpData;
			var vx : Number = pnx - cos1;
			var vy : Number = pny - sin1;
			data[0] = vx + ox;
			data[1] = vy + oy;
			data[6] = vx*.5 + .5;
			data[7] = .5 - vy * .5;

			vx = pnx + cos2;
			vy = pny + sin2;
			data[8]  = vx + ox;
			data[9]  = vy + oy;
			data[14] = vx*.5 + .5;
			data[15] = .5 - vy * .5;

			vx = pnx + cos1;
			vy = pny + sin1;
			data[16] = vx + ox;
			data[17] = vy + oy;
			data[22] = vx*.5 + .5;
			data[23] = .5 - vy * .5;

			vx = pnx - cos2;
			vy = pny - sin2;
			data[24] = vx + ox;
			data[25] = vy + oy;
			data[30] = vx*.5 + .5;
			data[31] = .5 - vy * .5;

			data[2]  = data[26] = uvBounds.left;
			data[3]  = data[11] = uvBounds.top;
			data[10] = data[18] = uvBounds.right;
			data[19] = data[27] = uvBounds.bottom;

			fragmentConstants[4] = Math.random(); //blending ratio
			fragmentConstants[5] = 1 - fragmentConstants[4];

			fragmentConstants[0] = uvBounds.width  * int( Math.random() * 10 ); //texture column offset
			fragmentConstants[1] = uvBounds.height * int( Math.random() * 10 );//texture row offset
			fragmentConstants[2] = 0.1  + Math.random() * 0.4 ; // blending treshold
			fragmentConstants[3] = 1 / (1 - fragmentConstants[2]);// blending normalization factor

			//used by bump map:
			var rotCos : Number = Math.cos(angle);
			var rotSin : Number = Math.sin(angle);
			data[4] = data[12] = data[20] = data[28] = rotCos;
			data[5] = data[13] = data[21] = data[29] = rotSin;


			//_fastBuffer.addInterleavedFloatsToVertices( data,_vIndex,8,4);
			//_fastBuffer.addInterleavedFloatsToVertices( point.colorsRGBA,_vIndex+32,4,8);
			_fastBuffer.addInterleavedFloatsToVertices( data,_vIndex,8,8);
			_fastBuffer.addInterleavedFloatsToVertices( point.colorsRGBA,_vIndex+32,4,12);
			_fastBuffer.addInterleavedFloatsToVertices( point.bumpFactors,_vIndex+48,4,12);

			//_vIndex += 192;
			_vIndex += 256;

			_numVertices += 4;
			_numIndices += 6;

			invalidateBuffers();
			invalidateBounds();
		}


		override protected function getColorVertexCode() : String
		{
			return 	"mov v0, va1\n"+
					"mov v1, va2\n" +
					"mov v2, va3\n" +
					"add v3, va3, vc0.xzzz\n" +
					"add v4, va3, vc0.zyzz\n" +
					"mov v5, va4\n" +
					"mov op, va0\n";
		}

		override protected function getColorFragmentCode() : String
		{
			// todo: perhaps add a vertex property for "paint amount", so we can fade out over time?
			// this is for example used by pencil for pressure
			return 	"tex ft0, v0, fs0 <2d, clamp, nearest, nomip>\n" +  // brush "amount"
					"tex ft2, v2, fs1 <2d, clamp, nearest, nomip>\n" +  // canvas height (center)
					"tex ft3, v3, fs1 <2d, clamp, nearest, nomip>\n" +  // canvas height (right)
					"tex ft4, v4, fs1 <2d, clamp, nearest, nomip>\n" +  // canvas height (left)

					"sub ft1.x, ft3.x, ft2.x\n" +
					"sub ft1.y, ft4.x, ft2.x\n" +
					"mov ft1.z, fc0.w\n" +    // 0
					"nrm ft1.xyz, ft1.xyz\n" +
					"dp3 ft1.x, ft1.xyz, v5\n" +    // match with stroke direction (1 = opposite directions -> no deposit)
					"add ft1.x, ft1.x, fc0.y\n" +
					"mul ft1.x, ft1.x, fc0.x\n" +
					"sat ft1.x, ft1.x\n" +   // don't allow all this negativism!

					"sub ft0.x, ft0.x, ft1.x\n" +
					"max ft0.x, ft0.x, fc0.w\n" +
					"mul oc, v1, ft0.x\n";
		}

		override public function drawColor(context3d : Context3D, canvas : CanvasModel, source : TextureBase = null) : void
		{
			if (_numIndices < 3) return;

			var vertexBuffer : VertexBuffer3D = getVertexBuffer(context3d);

			_vertexData[0] = 1/canvas.textureWidth;
			_vertexData[1] = 1/canvas.textureHeight;

			context3d.setProgram(getColorProgram(context3d));
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexData, 1);
			context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentData, 1);
			context3d.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setVertexBufferAt(2, vertexBuffer, 8, Context3DVertexBufferFormat.FLOAT_4);
			context3d.setVertexBufferAt(3, vertexBuffer, 6, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setVertexBufferAt(4, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_2);  // stroke direction

			context3d.setTextureAt(0, _brushTexture);
			context3d.setTextureAt(1, canvas.normalSpecularMap);
			context3d.drawTriangles(getIndexBuffer(context3d), 0, _numIndices/3);

			context3d.setTextureAt(0, null);
			context3d.setTextureAt(1, null);

			context3d.setVertexBufferAt(0, null);
			context3d.setVertexBufferAt(1, null);
			context3d.setVertexBufferAt(2, null);
			context3d.setVertexBufferAt(3, null);
			context3d.setVertexBufferAt(4, null);
		}

		override protected function get numElementsPerVertex() : int
		{
			return 16;
		}

		override protected function get topologyIndexType() : int
		{
			return FastBuffer.INDEX_MODE_QUADS;
		}
	}
}
