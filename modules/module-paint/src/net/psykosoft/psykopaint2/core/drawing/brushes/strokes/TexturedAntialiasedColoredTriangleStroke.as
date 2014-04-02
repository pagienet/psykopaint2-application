package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.intrinsics.FastBuffer;
	
	public class TexturedAntialiasedColoredTriangleStroke extends TriangleStroke
	{
		public function TexturedAntialiasedColoredTriangleStroke()
		{
			super();
		}

		
		override public function append( appendVO:StrokeAppendVO ) : void
		{
			//check for maximum vertex count
			if ( _numVertices >= 65531 ) return;
			
			var verticesAndUV:Vector.<Number> = appendVO.verticesAndUV;
			_maxX = Math.max( verticesAndUV[0],verticesAndUV[12],verticesAndUV[24],_maxX );
			_minX = Math.min( verticesAndUV[0],verticesAndUV[12],verticesAndUV[24],_minX );
			_maxY = Math.max( verticesAndUV[1],verticesAndUV[13],verticesAndUV[25],_maxY );
			_minY = Math.min( verticesAndUV[1],verticesAndUV[13],verticesAndUV[25],_minY );
			
			
			//used by bump map:
			var angle : Number = appendVO.point.angle;
			var rotCos : Number = Math.cos(angle);
			var rotSin : Number = Math.sin(angle);
			verticesAndUV[4] = verticesAndUV[16] = verticesAndUV[28] =  rotCos;
			verticesAndUV[5] = verticesAndUV[17] = verticesAndUV[29] = -rotSin;
			verticesAndUV[6] = verticesAndUV[18] = verticesAndUV[30] = rotSin;
			verticesAndUV[7] = verticesAndUV[19] = verticesAndUV[31] = rotCos;
			
			
			_fastBuffer.addInterleavedFloatsToVertices( verticesAndUV,_vIndex,12,8);
			_fastBuffer.addInterleavedFloatsToVertices( appendVO.point.colorsRGBA,_vIndex+48,4,16,12);
			_fastBuffer.addInterleavedFloatsToVertices( appendVO.point.bumpFactors,_vIndex+64,4,16,12);
			
			// 80 bytes per vertex
			_vIndex += 240;
			
			
			
			//_vIndex += 144;
			
			_numVertices += 3;
			_numIndices += 3;
			
			invalidateBuffers();
			invalidateBounds();
		}

		override public function drawColor(context3d : Context3D, canvas : CanvasModel, source : TextureBase = null) : void
		{
			var vertexBuffer : VertexBuffer3D = getVertexBuffer(context3d);

			context3d.setProgram(getColorProgram(context3d));
			//xy
			context3d.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			//uv
			context3d.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); 
			//triangle lengths
			context3d.setVertexBufferAt(2, vertexBuffer, 8, Context3DVertexBufferFormat.FLOAT_4); 
			//rgba
			context3d.setVertexBufferAt(3, vertexBuffer, 12, Context3DVertexBufferFormat.FLOAT_4); 
			context3d.setTextureAt(0, _brushTexture);
			context3d.drawTriangles(getIndexBuffer(context3d), 0, _numIndices/3);

			context3d.setTextureAt(0, null);
			context3d.setVertexBufferAt(0, null);
			context3d.setVertexBufferAt(1, null);
			context3d.setVertexBufferAt(2, null);
			context3d.setVertexBufferAt(3, null);
		}
		
		// default height mapping expects default vertex layout: pos=0, brush uv=1, rotation vectors = 2, bump factors = 3
		override public function drawNormalsAndSpecular(context3d : Context3D, canvas : CanvasModel, shininess : Number, glossiness : Number, bumpiness : Number, influence : Number ) : void
		{
			var vertexBuffer : VertexBuffer3D = getVertexBuffer(context3d);
			
			context3d.setProgram(getNormalSpecularProgram(context3d));
			context3d.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4);
			context3d.setVertexBufferAt(3, vertexBuffer, 16, Context3DVertexBufferFormat.FLOAT_4);
			
			context3d.setTextureAt(0, _normalTexture);
			context3d.setTextureAt(1, canvas.normalSpecularMap);
			_normalSpecularVertexData[0] = 1/512;
			_normalSpecularVertexData[1] = 1/512;
			
			_normalSpecularVertexData[8] = 1/canvas.width;
			_normalSpecularVertexData[9] = 1/canvas.height;
			
			_normalSpecularVertexData[12] = glossiness;
			_normalSpecularVertexData[13] = bumpiness;
			_normalSpecularVertexData[14] = shininess;
			_normalSpecularVertexData[15] = influence;
			
			
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _normalSpecularVertexData, 4);
			context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _normalSpecularFragmentData, 1);
			context3d.drawTriangles(getIndexBuffer(context3d), 0, _numIndices/3);
			context3d.setTextureAt(0, null);
			context3d.setTextureAt(1, null);
			
			context3d.setVertexBufferAt(0, null);
			context3d.setVertexBufferAt(1, null);
			context3d.setVertexBufferAt(2, null);
			context3d.setVertexBufferAt(3, null);
		}
		
		override protected function getColorVertexCode() : String
		{
			return 	"mov v0, va1\n"+
					"mov v1, va2\n" +
					"mov v2, va3\n" +
					"mov op, va0\n";
		}
		
		override protected function getColorFragmentCode() : String
		{
			
			return  "tex ft0, v0, fs0 <2d, clamp, linear, miplinear >\n"+
					"mul ft1, v2, ft0\n"+
					"mov oc, ft1\n";
			/*
					"min ft0.x, v1.x, v1.y\n"+
					"min ft0.x, ft0.x, v1.z\n"+
					"max ft0.y, v1.x, v1.y\n"+
					"max ft0.y, ft0.y, v1.z\n"+
					"add ft0.z, v1.x, v1.y\n"+
					"add ft0.z, ft0.z, v1.z\n"+
					"sub ft0.z, ft0.z, ft0.x\n"+
					"sub ft0.z, ft0.z, ft0.y\n"+
					"sat ft0.z, ft0.z\n"+
					"frc ft0.w, ft0.z\n" +
					"sub ft0.z, ft0.z, ft0.w\n"+
					"sat ft0.x, ft0.x\n"+
					"mul ft1, ft1, ft0.x\n"+
					"mov oc, ft1\n";
			*/
					//"mul oc, ft1, ft0.x\n";
					//
					//"mul oc, ft1, ft0.x\n";
			
		}
		
		
		/*
		override protected function getNormalSpecularVertexCode() : String
		{
			return 	"mov op, va0\n" +
					"mov v0, va1\n" +
					"mov v1, va2\n";
					
		}
		*/
		// default code expects a height map + alpha map
		// texture input is:
		// R = height
		// G = specular occlusion
		// B = influence
		// output should be (h, gloss, specular, influence(alpha))
		// analytical solutions may be more optimal if possible
		/*
		override protected function getNormalSpecularFragmentCode() : String
		{
			return 	"tex ft1, v0, fs0 <2d, clamp, linear, miplinear >\n" +
				"mul ft1.xy, ft1, fc1\n" +	// specularity strength
				"mov ft1.w, fc0.w\n" +	// gloss
				"min ft0.x, v1.x, v1.y\n"+
				"min ft0.x, ft0.x, v1.z\n"+
				"max ft0.y, v1.x, v1.y\n"+
				"max ft0.y, ft0.y, v1.z\n"+
				"add ft0.z, v1.x, v1.y\n"+
				"add ft0.z, ft0.z, v1.z\n"+
				"sub ft0.z, ft0.z, ft0.x\n"+
				"sub ft0.z, ft0.z, ft0.y\n"+
				"sat ft0.z, ft0.z\n"+
				"frc ft0.w, ft0.z\n" +
				"sub ft0.z, ft0.z, ft0.w\n"+
				"sat ft0.x, ft0.x\n"+
				"mul ft0.x, ft0.x, fc2.x\n"+
				"add ft0.x, ft0.x, fc2.x\n"+
				"mul ft0.x, ft0.x, ft0.z\n"+
				"mul ft1.z, ft1.z, ft0.x\n"+
				"mov oc, ft1.xwyz\n"; 
				//"mul oc, ft1.xwyz, ft0.x\n";
		}
		*/
		

		override protected function get numElementsPerVertex() : int
		{
			return 20;
		}

		override protected function get topologyIndexType() : int
		{
			return FastBuffer.INDEX_MODE_TRIANGLES;
		}
		
	
	}
}
