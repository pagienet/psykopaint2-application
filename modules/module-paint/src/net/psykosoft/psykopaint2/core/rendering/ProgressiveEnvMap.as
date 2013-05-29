package net.psykosoft.psykopaint2.core.rendering
{
	import away3d.core.math.PoissonLookup;

	import com.adobe.utils.AGALMiniAssembler;

	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.utils.ByteArray;

	public class ProgressiveEnvMap
	{
		private var _context : Context3D;

		private var _program : Program3D;
		private var _quadVertices : VertexBuffer3D;
		private var _quadIndices : IndexBuffer3D;

		private var _inputTexture : Texture;
		private var _envMapFront : Texture;
		private var _envMapBack : Texture;
		private var _numSamplesPerFrame : int = 12;
		private var _fragmentData : Vector.<Number>;

		private var _samplePoints : Vector.<Number> = new Vector.<Number>();
		private var _sampleRange : Number = .3;
		private var _mapSize : uint;
		private var _vertexData : Vector.<Number>;
		private var _brightnessScale : Number = 1;

		public function ProgressiveEnvMap(context : Context3D, mapSize : uint = 32)
		{
			_context = context;
			_fragmentData = new <Number>[.05, 1/_numSamplesPerFrame, 0, 1,.5,.5, 0, 0];
			_vertexData = new <Number>[.5,.5, 0, 1];

			numSamplesPerFrame = 12;
			_mapSize = mapSize;

			init();
		}

		public function get timeLERPFactor() : Number
		{
			return _fragmentData[0];
		}

		public function set timeLERPFactor(value : Number) : void
		{
			_fragmentData[0] = value;
		}

		public function get sampleRange() : Number
		{
			return _sampleRange;
		}

		public function set sampleRange(value : Number) : void
		{
			_sampleRange = value;
		}

		public function get numSamplesPerFrame() : int
		{
			return _numSamplesPerFrame;
		}

		public function set numSamplesPerFrame(value : int) : void
		{
			_numSamplesPerFrame = value;
			updateDivider();
		}

		private function init() : void
		{
			initTextures();
			initProgram();
			initBuffers();
		}

		private function initBuffers() : void
		{
			_quadVertices = _context.createVertexBuffer(4,4);
			_quadIndices = _context.createIndexBuffer(6);
			_quadVertices.uploadFromVector(new <Number>[
				-1.0, -1.0, 0.0, 1.0,
				1.0, -1.0, 1.0, 1.0,
				1.0, 1.0, 1.0, 0.0,
				-1.0, 1.0, 0.0, 0.0], 0, 4);
			_quadIndices.uploadFromVector(new <uint>[0, 1, 2, 0, 2, 3], 0, 6);
		}

		private function initProgram() : void
		{
			var vertexByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, getVertexCode());
			var fragmentByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, getFragmentCode());
			_program = _context.createProgram();
			_program.upload(vertexByteCode, fragmentByteCode);
		}

		private function getVertexCode() : String
		{
			return 	"mov op, va0\n" +
					"mov v0, va1\n" +

					"sub vt0, va1, vc0\n" +
					// maybe scale by 1.5 or something?
					"dp3 vt0.z, vt0.xyw, vt0.xyw\n" + // x*x + y*y + 0*0
					"sub vt0.z, vc0.w, vt0.z\n" +	// z = 1 - x*x - y*y
					"sqt vt0.z, vt0.z\n" +
					"mov v1, vt0";// find z coord: sqrt(1 - x*x - y*y);
		}

		private function getFragmentCode() : String
		{
			var code : String = "tex ft0, v0, fs0 <2d, clamp, nearest, mipnone>\n" +
								"nrm ft7.xyz, v1\n";

			for (var i : int = 0; i < _numSamplesPerFrame; ++i) {
				var index : int = 2 + int(i / 2);
				var comps : String = i & 1? "zwzw" : "xyxy";
				var reg : String = "fc"+index +"." + comps;

				code += "add ft1, v0, " + reg +"\n";

				// ft1 is light direction
				// v0 is normal
				// dp3(ft1, v0) = lambert term
				code += "tex ft5, ft1.xyxy, fs1 <2d, clamp, nearest, mipnone>\n" +
						"sub ft6, ft1, fc1\n" +	// - .5
						"mul ft6.zw, ft6.xy, ft6.xy\n" +
						"add ft6.z, ft6.z, ft6.w\n" +
						"sub ft6.z, fc0.w, ft6.z\n" +
						"sqt ft6.z, ft6.z\n" +	// find z coord
						"dp3 ft6.x, ft6.xyz, ft7.xyz\n";

				if (i == 0) {
					code += "mul ft2, ft5, ft6.x\n";
				}
				else {
					code += "mul ft5, ft5, ft6.x\n" +
							"add ft2, ft2, ft5\n";
				}
			}

			code += "mul ft2, ft2, fc0.y\n" +
					"sub ft2, ft2, ft0\n" +
					"mul ft2, ft2, fc0.x\n" +
					"add oc, ft0, ft2";

			return code;
		}

		private function initTextures() : void
		{
			_inputTexture = _context.createTexture(_mapSize, _mapSize, Context3DTextureFormat.BGRA, false);
			_envMapFront = _context.createTexture(_mapSize, _mapSize, Context3DTextureFormat.BGRA, true);
			_envMapBack = _context.createTexture(_mapSize, _mapSize, Context3DTextureFormat.BGRA, true);
			var tempBitmap : BitmapData = new BitmapData(_mapSize, _mapSize, false, 0x808080);
			_envMapFront.uploadFromBitmapData(tempBitmap);
			tempBitmap.dispose();
		}

		public function update(bitmapData : BitmapData):void
		{
			_inputTexture.uploadFromBitmapData(bitmapData);
			_context.setRenderToTexture(_envMapBack);

			_context.clear();
			_context.setTextureAt(0, _envMapFront);
			_context.setTextureAt(1, _inputTexture);
			_context.setVertexBufferAt(0, _quadVertices, 0, Context3DVertexBufferFormat.FLOAT_2); // vertices
			_context.setVertexBufferAt(1, _quadVertices, 2, Context3DVertexBufferFormat.FLOAT_2);	// uvs

			var randomAngle : Number = Math.random()*Math.PI*2;
			var cos : Number = Math.cos(randomAngle) * _sampleRange;
			var sin : Number = Math.sin(randomAngle) * _sampleRange;

			var samplePoints : Vector.<Number> = PoissonLookup.getDistribution(_numSamplesPerFrame);
			var len : uint = _numSamplesPerFrame << 1;
			for (var i : uint = 0; i < len; i += 2) {
				var x : Number = samplePoints[i];
				var y : Number = samplePoints[i+1];
				_samplePoints[i] = cos*x - sin*y;
				_samplePoints[i+1] = sin*x + cos*y;
			}

			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexData, 1);
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentData, 2);
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, _samplePoints, _samplePoints.length/4);
			_context.setProgram(_program);

			_context.drawTriangles(_quadIndices,0,2);

			_context.setTextureAt(0, null);
			_context.setTextureAt(1, null);
			_context.setVertexBufferAt(0, null);
			_context.setVertexBufferAt(1, null);

			_context.setRenderToBackBuffer();

			swap();
		}

		private function swap() : void
		{
			var temp : Texture = _envMapBack;
			_envMapBack = _envMapFront;
			_envMapFront = temp;
		}

		public function dispose() : void
		{
			if (_program) _program.dispose();
			if (_quadVertices) _quadVertices.dispose();
			if (_quadIndices) _quadIndices.dispose();
			if (_inputTexture) _inputTexture.dispose();
			if (_envMapFront) _envMapFront.dispose();
			if (_envMapBack) _envMapBack.dispose();
			_program = null;
			_quadVertices = null;
			_quadIndices = null;
			_inputTexture = null;
			_envMapFront = null;
			_envMapBack = null;
		}

		public function get envMap() : Texture
		{
			return _envMapFront;
		}

		public function get brightnessScale() : Number
		{
			return _brightnessScale;
		}

		public function set brightnessScale(brightnessScale : Number) : void
		{
			_brightnessScale = brightnessScale;
			updateDivider();
		}

		private function updateDivider() : void
		{
			_fragmentData[1] = _brightnessScale * 2 * Math.PI / _numSamplesPerFrame;
		}
	}
}
