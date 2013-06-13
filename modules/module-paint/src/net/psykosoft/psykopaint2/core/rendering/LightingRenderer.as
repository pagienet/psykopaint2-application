package net.psykosoft.psykopaint2.core.rendering
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	import net.psykosoft.psykopaint2.core.model.LightingModel;

	public class LightingRenderer
	{
		private var _globalVertexData : Vector.<Number>;
		private var _globalFragmentData : Vector.<Number>;
		private var _lightingModel : LightingModel;

		private var _diffuseModel : BDRFModel;
		private var _ambientModel : BDRFModel;
		private var _specularModel : BDRFModel;
		private var _shadowModel : BDRFModel;

		private var _program : Program3D;
		private var _context3d : Context3D;

		private var _quadVertices : VertexBuffer3D;
		private var _quadIndices : IndexBuffer3D;
		private var _sourceTextureAlpha : Number = 0;

		private var _needBake : Boolean;
		private var _freezeRender : Boolean = false;
		private var _renderRect : Rectangle;

		public function LightingRenderer(lightingModel : LightingModel, context3d : Context3D)
		{
			_lightingModel = lightingModel;
			_lightingModel.onChange.add(onLightingModelChanged);
			_globalVertexData = new Vector.<Number>();
			_context3d = context3d;
			_globalVertexData = new <Number>[0, 0, 0, 1, -1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
			_globalFragmentData = new <Number>[.5, 0, 1, 0, 0, -1, 0, 0];
			initBuffers();
			onLightingModelChanged();
		}

		public function get renderRect() : Rectangle
		{
			return _renderRect;
		}

		public function set renderRect(value : Rectangle) : void
		{
			_renderRect = value;
		}

		public function get freezeRender() : Boolean
		{
			return _freezeRender;
		}

		public function set freezeRender(value : Boolean) : void
		{
			if (_freezeRender == value) return;
			_freezeRender = value;

			if (_freezeRender) _needBake = true;
		}

		public function render(canvas : CanvasModel) : void
		{
			if (!_program) initProgram();

			if (_freezeRender) {
				if (_needBake)
					renderToBaked(canvas);

				copyBakedRender(canvas);
			}
			else {
				var scale : Number = _renderRect.height/canvas.height;
				var offsetX : Number = (1 - scale)*.5;
				renderLighting(offsetX, scale, scale, canvas);
			}
		}

		private function renderToBaked(canvas : CanvasModel) : void
		{
			// as long as there's no rendering, we assume noone is using the canvas back buffer
			_context3d.setRenderToTexture(canvas.fullSizeBackBuffer);
			_context3d.clear(1, 1, 1, 1);

			renderLighting(0, canvas.usedTextureWidthRatio, canvas.usedTextureHeightRatio, canvas);

			_context3d.setRenderToBackBuffer();
			_context3d.clear(1, 1, 1, 1);

			_needBake = false;
		}

		private function copyBakedRender(canvas : CanvasModel) : void
		{
			var scale : Number = _renderRect.height/canvas.height;
			var offsetX : Number = 1 - scale*.5;
			var sourceRect : Rectangle = new Rectangle(0, 0, canvas.usedTextureWidthRatio, canvas.usedTextureHeightRatio);
			var destRect : Rectangle = new Rectangle(offsetX, 0, scale, scale);
			CopySubTexture.copy(canvas.fullSizeBackBuffer, sourceRect, destRect, _context3d);
		}

		private function renderLighting(offsetX : Number, widthRatio : Number, heightRatio : Number, canvas : CanvasModel) : void
		{
			updateGlobalVertexData(offsetX, widthRatio, heightRatio, canvas);
			updateGlobalFragmentData(canvas);

			_diffuseModel.setRenderState(_context3d);
			_ambientModel.setRenderState(_context3d);
			_specularModel.setRenderState(_context3d);
			if (_shadowModel) _shadowModel.setRenderState(_context3d);

			_context3d.setDepthTest(false, Context3DCompareMode.ALWAYS);
			_context3d.setProgram(_program);
			_context3d.setTextureAt(0, canvas.colorTexture);
			if (_sourceTextureAlpha > 0)
				_context3d.setTextureAt(1, canvas.sourceTexture);
			_context3d.setTextureAt(2, canvas.normalSpecularMap);
			_context3d.setVertexBufferAt(0, _quadVertices, 0, Context3DVertexBufferFormat.FLOAT_2); // vertices
			_context3d.setVertexBufferAt(1, _quadVertices, 2, Context3DVertexBufferFormat.FLOAT_2);	// uvs
			_context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _globalVertexData, 6);
			_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _globalFragmentData, 2);
			_context3d.drawTriangles(_quadIndices, 0, 2);
			_context3d.setTextureAt(0, null);
			_context3d.setTextureAt(1, null);
			_context3d.setTextureAt(2, null);
			_context3d.setVertexBufferAt(0, null);
			_context3d.setVertexBufferAt(1, null);

			_diffuseModel.clearRenderState(_context3d);
			_ambientModel.clearRenderState(_context3d);
			_specularModel.clearRenderState(_context3d);
			if (_shadowModel) _shadowModel.clearRenderState(_context3d);
		}

		private function updateGlobalVertexData(offsetX : Number, widthRatio : Number, heightRatio : Number, canvas : CanvasModel) : void
		{
			_globalVertexData[0] = widthRatio*2;
			_globalVertexData[1] = heightRatio*2;
			_globalVertexData[4] = offsetX*2 - 1;

			_globalVertexData[8] = canvas.usedTextureWidthRatio;
			_globalVertexData[9] = canvas.usedTextureHeightRatio;
		}

		private function updateGlobalFragmentData(canvas : CanvasModel) : void
		{
			var textureRatioX : Number  = canvas.usedTextureWidthRatio;
			var textureRatioY : Number  = canvas.usedTextureHeightRatio;

			_globalVertexData[20] = 1/canvas.textureWidth;
			_globalVertexData[21] = 1/canvas.textureHeight;

			// light position
			_globalVertexData[12] = (_lightingModel.lightPosition.x + 1) * .5 * textureRatioX;
			_globalVertexData[13] = (-_lightingModel.lightPosition.y + 1) * .5 * textureRatioY;
			_globalVertexData[14] = _lightingModel.lightPosition.z * .5;

			// eye position in uv space
			_globalVertexData[16] = (_lightingModel.eyePosition.x + 1) * .5 * textureRatioX;
			_globalVertexData[17] = (-_lightingModel.eyePosition.y + 1) * .5 * textureRatioY;
			_globalVertexData[18] = _lightingModel.eyePosition.z * .5;
		}

		private function initProgram() : void
		{
			var vertexCode : String = getVertexShader();
			var fragmentCode : String = getFragmentShader();
			_program = _context3d.createProgram();
			_program.upload(new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, vertexCode),
					new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, fragmentCode));
		}

		private function getFragmentShader() : String
		{
			var code : String = getInitFragmentCode();

			if (_shadowModel)
				code += _shadowModel.getFragmentCode() + "\n";

			code += _diffuseModel.getFragmentCode() + "\n";
			code += applyDiffuseLight();
			code += _specularModel.getFragmentCode() + "\n";
			code += applySpecularLight();

			code += "mov oc, ft3\n";
//			code += "mul ft0.xy, ft0.xy, fc0.x\n" +
//					"add ft0.xy, ft0.xy, fc0.x\n" +
//					"mov ft0.w, ft7.w\n" +
//					"mov oc, ft0\n";



			return code;
		}

		// REGISTERS:
		// VC0 = canvas scale (NDC scale)
		// VC1 = canvas offset (NDC offset)
		// VC2 = canvas ratio (UV scale)
		// VC3 = light position
		// VC4 = eye position
		// VC5 = (texelWidth, texelHeight, 0, 0)
		// V0 = UV COORD
		// V1 = INVERSE LIGHT VECTOR
		// V2 = INVERSE EYE VECTOR
		// V3 = UV COORD RIGHT
		// V4 = UV COORD BOTTOM
		// V5 = half vector
		// V6 = anything provided by shadow method

		// VT0 = UV coords
		// VT4 = light direction

		// FS0 = PAINT TEXTURE
		// FS1 = SOURCE TEXTURE
		// FS2 = NORMAL/HEIGHT TEXTURE

		// FT0 = NORMAL
		// FT1 = HEIGHT GRADIENT X, Y (unscaled)
		// FT3 = LIGHT ACCUMULATION
		// FT4 = MODEL OUTPUT (x for strength)
		// FT7 = PACKED NORMAL X, NORMAL Y, SPECULAR STRENGTH + GLOSS (4 bits each), SHADOW STRENGTH (if used)

		// FC0 = (0.5, 0, 1, bumpiness)
		// FC1 = SOURCE BLEND ALPHA, -1, ?, ?

		// FC5-9 = DIFFUSE STATE
		// FC10-14 = AMBIENT STATE
		// FC15-19 = SPECULAR STATE
		// FC20-27 = SHADOW STATE

		private function getVertexShader() : String
		{
			var code : String =
					"mul vt0, va0, vc0\n" +
					"add op, vt0, vc1\n" +
					"mul vt0, vc2, va1\n" +
					"mov v0, vt0\n" +

					"sub vt4, vc3, vt0\n" +
					"nrm vt4.xyz, vt4\n" +
					"mov v1, vt4\n" +

					"sub vt2, vc4, vt0\n" +
					"nrm vt2.xyz, vt2\n" +
					"mov v2, vt2\n" +

					"add vt1, vt4, vt2\n" +
					"nrm vt1.xyz, vt1.xyz\n" +
					"mov v5, vt1\n";

			if (_shadowModel)
				code += _shadowModel.getVertexCode();

			return code;
		}

		private function getInitFragmentCode() : String
		{
			return 	"tex ft7, v0, fs2 <2d, clamp, linear, mipnone>\n" +
					"sub ft0.xy, ft7.xy, fc0.x\n" +
					"mul ft0.xy, ft0.xy, fc0.w\n" +	// multiply by bumpiness

					"mov ft0.z, fc1.y\n" +
					"nrm ft0.xyz, ft0.xyz\n";
		}

		private function applyDiffuseLight() : String
		{
			var code : String = "";

			if (_shadowModel)
				code += "mul ft3.xyz, ft3.xyz, ft7.w\n";

			code += _ambientModel.getFragmentCode() + "\n";
			code += "add ft3.xyz, ft3.xyz, " + _ambientModel.outputRegister + ".xyz\n";

			code += "tex ft6, v0, fs0 <2d, clamp, nearest, mipnone>\n";

			if (_sourceTextureAlpha > 0) {
				code += "tex ft5, v0, fs1 <2d, clamp, nearest, mipnone>\n" +
						"sub ft0.w, fc0.z, ft6.w\n" +
						"mul ft5, ft5, ft0.w\n" +
						"add ft6, ft6, ft5\n";
			}
			else {
				// blend against white because the white needs to be shaded too
				code += "sub ft5.x, fc0.z, ft6.w\n" + // 1-a
						"add ft6, ft6, ft5.xxxx\n";
			}

			code += "mul ft3.xyz, ft3.xyz, ft6.xyz\n" +
					"mov ft3.w, ft6.w\n";


			return code;
		}

		private function applySpecularLight() : String
		{
			var code : String = "";

			if (_shadowModel)
				code += "mul ft4.xyz, ft4.xyz, ft7.w\n";

			code += "add ft3.xyz, ft3, ft4\n";

			return code;
		}

		private function onLightingModelChanged() : void
		{
			if (_diffuseModel != _lightingModel.diffuseModel || _specularModel != _lightingModel.specularModel || _ambientModel != _lightingModel.ambientModel) {
				invalidateProgram();
				_diffuseModel = _lightingModel.diffuseModel;
				_specularModel = _lightingModel.specularModel;
				_ambientModel = _lightingModel.ambientModel;
				_shadowModel = _lightingModel.shadowModel;
			}

			_diffuseModel.updateLightingModel(_lightingModel);
			_ambientModel.updateLightingModel(_lightingModel);
			_specularModel.updateLightingModel(_lightingModel);
			if (_shadowModel) _shadowModel.updateLightingModel(_lightingModel);

			// bumpiness
			_globalFragmentData[3] = _lightingModel.surfaceBumpiness;

		}

		private function invalidateProgram() : void
		{
			if (_program) {
				_program.dispose();
				_program = null;
			}
		}

		private function initBuffers() : void
		{
			_quadVertices = _context3d.createVertexBuffer(4,4);
			_quadIndices = _context3d.createIndexBuffer(6);
			_quadVertices.uploadFromVector(new <Number>[	0.0, -1.0, 0.0, 1.0,
				1.0, -1.0, 1.0, 1.0,
				1.0, 0.0, 1.0, 0.0,
				0.0, 0.0, 0.0, 0.0], 0, 4);
			_quadIndices.uploadFromVector(new <uint>[0, 1, 2, 0, 2, 3], 0, 6);
		}

		public function dispose() : void
		{
			if (_program) _program.dispose();
			_quadIndices.dispose();
			_quadVertices.dispose();
		}

		public function get sourceTextureAlpha() : Number
		{
			return _sourceTextureAlpha;
		}

		public function set sourceTextureAlpha(value : Number) : void
		{
			if (_sourceTextureAlpha == value) return;
			_sourceTextureAlpha = value;
			if (_sourceTextureAlpha == 0 || value == 0)
				invalidateProgram();

			_globalFragmentData[4] = value*2;
		}
	}
}
