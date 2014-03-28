package away3d.hacks
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.lights.PointLight;
	import away3d.materials.passes.MaterialPassBase;
	import away3d.textures.Texture2DBase;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;

	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DStencilAction;
	import flash.display3D.Context3DTriangleFace;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	use namespace arcane;

	public class PaintingMaterialPass extends MaterialPassBase
	{
		private var _albedoTexture : RectTextureBase;
		private var _normalSpecularTexture : RectTextureBase;
		private var _vertexData : Vector.<Number>;
		private var _fragmentData : Vector.<Number>;
		private var _matrix : Matrix3D;
		private var _enableStencil : Boolean;
		private var _stencilReferenceValue : int = 0;
		private var _stencilCompareMode : String = Context3DCompareMode.ALWAYS;
		private var _bumpiness : Number = 20;
		private var _ambientColor : uint = 0xffffff;
		private var _specular : Number = 1;
		private var _gloss : Number = 50;
		private var _ambientR : Number;
		private var _ambientG : Number;
		private var _ambientB : Number;

		public function PaintingMaterialPass()
		{
			_numUsedStreams = 2;
			_numUsedTextures = 2;
			_matrix = new Matrix3D();
			_vertexData = Vector.<Number>([0, 0, 0, 1, 0, 0, 0, 1]);
			_fragmentData = Vector.<Number>([.5, 0, 0, 1, _bumpiness, _gloss, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0]);
		}

		public function get ambientColor() : uint
		{
			return _ambientColor;
		}

		public function set ambientColor(value : uint) : void
		{
			_ambientColor = value;
			_ambientR = (value & 0xff0000) / 0xff0000;
			_ambientG = (value & 0x00ff00) / 0x00ff00;
			_ambientB = (value & 0x0000ff) / 0x0000ff;
		}

		public function get specular() : Number
		{
			return _specular;
		}

		public function set specular(value : Number) : void
		{
			_specular = value;
		}

		public function get gloss() : Number
		{
			return _gloss;
		}

		public function set gloss(value : Number) : void
		{
			_gloss = value;
			_fragmentData[5] = value;
		}

		public function get bumpiness() : Number
		{
			return _bumpiness;
		}

		public function set bumpiness(value : Number) : void
		{
			_bumpiness = value;
			_fragmentData[4] = value;
		}

		public function get enableStencil() : Boolean
		{
			return _enableStencil;
		}

		public function set enableStencil(enableStencil : Boolean) : void
		{
			_enableStencil = enableStencil;
		}

		public function get stencilReferenceValue() : int
		{
			return _stencilReferenceValue;
		}

		public function set stencilReferenceValue(stencilReferenceValue : int) : void
		{
			_stencilReferenceValue = stencilReferenceValue;
		}

		public function get stencilCompareMode() : String
		{
			return _stencilCompareMode;
		}

		public function set stencilCompareMode(stencilCompareMode : String) : void
		{
			_stencilCompareMode = stencilCompareMode;
		}

		public function get albedoTexture() : RectTextureBase
		{
			return _albedoTexture;
		}

		public function set albedoTexture(value : RectTextureBase) : void
		{
			if (Boolean(_albedoTexture) != Boolean(value))
				invalidateShaderProgram();

			_albedoTexture = value;
		}

		public function get normalSpecularTexture() : RectTextureBase
		{
			return _normalSpecularTexture;
		}

		public function set normalSpecularTexture(value : RectTextureBase) : void
		{
			_normalSpecularTexture = value;
		}

		/**
		 * Get the vertex shader code for this shader
		 */
		override arcane function getVertexCode() : String
		{
			return  "m44 op, va0, vc0\n" +          // transform to view space

				// light direction in object space
					"sub vt0, va0, vc4\n" +
					"neg vt0.x, vt0.x\n" +			// negate x due to rotation (won't rotate normals)
					"mov v1, vt0\n" +

				// view vector in obect space
					"sub vt0, va0, vc5\n" +
					"neg vt0.x, vt0.x\n" +
					"mov v2, vt0\n" +

					"mov v0, va1\n";                 // pass on uvs
		}

		/**
		 * Get the fragment shader code for this shader
		 * @param fragmentAnimatorCode Any additional fragment animation code imposed by the framework, used by some animators. Ignore this for now, since we're not using them.
		 */
		override arcane function getFragmentCode(fragmentAnimatorCode : String) : String
		{
				// albedo in ft0
			var code : String;

			if (_albedoTexture) {
				code = "tex ft0, v0, fs0 <2d, clamp, linear, nomip>\n" +
						"sub ft1.w, fc0.w, ft0.w\n" +
						"add ft0, ft0, ft1.w\n";
			}
			else {
				code = "mov ft0, fc0.w";
			}

				// normal in ft2, specular data in ft6
			code += "tex ft6, v0, fs1 <2d, clamp, linear, nomip>\n" +
					"sub ft2.xy, ft6.xy, fc0.x	\n" +
					"mul ft2.xy, ft2.xy, fc1.x\n" +	// apply bumpiness
					"mov ft2.z, fc0.w\n" +
					"nrm ft2.xyz, ft2.xyz\n" +

				// light dir in ft3
					"nrm ft3.xyz, v1.xyz\n" +

				// diffuse in ft0
					"dp3 ft4.x, ft2.xyz, ft3.xyz\n" +
					"max ft4.x, ft4.x, fc0.y\n" +
					"mul ft4, ft4.x, fc3\n" +
					"add ft4, ft4, fc2\n" +
					"mul ft0, ft0, ft4\n" +

				// view dir in ft5
					"nrm ft5.xyz, v2.xyz\n" +

					"add ft4.xyz, ft3.xyz, ft5.xyz\n" +
					"nrm ft4.xyz, ft4.xyz\n" +
					"dp3 ft4.x, ft2.xyz, ft4.xyz\n" +
					"max ft4.x, ft4.x, fc0.y\n" +

					"mul ft7.x, fc1.y, ft6.w\n" +
					"pow ft4.x, ft4.x, ft7.x\n" +
					"mul ft4, ft4.x, fc4.xyz\n" +
					"mul ft4, ft4, ft6.z\n" +

					"add oc, ft4, ft0\n";

			return code;
		}

		/**
		 * Sets the render state which is constant for this pass
		 * @param stage3DProxy The stage3DProxy used for the current render pass
		 * @param camera The camera currently used for rendering
		 */
		override arcane function activate(stage3DProxy : Stage3DProxy, camera : Camera3D) : void
		{
			super.activate(stage3DProxy, camera);

			// retrieve the actual texture object, and assign it to slot 0 (fs0)
			// we set this in activate, not in render, because the texture is constant for this pass
			var context : Context3D = stage3DProxy._context3D;
			if (_albedoTexture) context.setTextureAt(0, _albedoTexture.getTextureForStage3D(stage3DProxy));
			context.setTextureAt(1, _normalSpecularTexture.getTextureForStage3D(stage3DProxy));

			var light : PointLight = _lightPicker.pointLights[0];
			_fragmentData[8] = _ambientR * light._ambientR;
			_fragmentData[9] = _ambientG * light._ambientG;
			_fragmentData[10] = _ambientB * light._ambientR;
			_fragmentData[12] = light._diffuseR;
			_fragmentData[13] = light._diffuseG;
			_fragmentData[14] = light._diffuseB;
			_fragmentData[16] = light._specularR * _specular;
			_fragmentData[17] = light._specularG * _specular;
			_fragmentData[18] = light._specularB * _specular;

			if (_enableStencil) {
				context.setStencilReferenceValue(_stencilReferenceValue);
				context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, _stencilCompareMode, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP);
			}
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentData, 5);
		}

		/**
		 * Set render state for the current renderable and draw the triangles.
		 * @param renderable The renderable that needs to be drawn.
		 * @param stage3DProxy The stage3DProxy used for the current render pass.
		 * @param camera The camera currently used for rendering.
		 * @param viewProjection The matrix that transforms world space to screen space.
		 */
		override arcane function render(renderable : IRenderable, stage3DProxy : Stage3DProxy, camera : Camera3D, viewProjection : Matrix3D) : void
		{
			var context : Context3D = stage3DProxy._context3D;

			// expect a directional light to be assigned
			var light : PointLight = _lightPicker.pointLights[0];

			// upload the world-view-projection matrix
			_matrix.copyFrom(renderable.sceneTransform);
			_matrix.append(viewProjection);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _matrix, true);

			// the light position relative to the renderable object (model space)
			var objectSpacePos : Vector3D = renderable.inverseSceneTransform.transformVector(light.scenePosition);
			// passing on inverse light direction to simplify shader code (it expects the direction _to_ the light)
			_vertexData[0] = objectSpacePos.x;
			_vertexData[1] = objectSpacePos.y;
			_vertexData[2] = objectSpacePos.z;

			objectSpacePos = renderable.inverseSceneTransform.transformVector(camera.scenePosition);

			_vertexData[4] = objectSpacePos.x;
			_vertexData[5] = objectSpacePos.y;
			_vertexData[6] = objectSpacePos.z;

			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, _vertexData, 2);

			renderable.activateVertexBuffer(0, stage3DProxy);
			renderable.activateUVBuffer(1, stage3DProxy);

			context.drawTriangles(renderable.getIndexBuffer(stage3DProxy), 0, renderable.numTriangles);
		}

		override arcane function deactivate(stage3DProxy : Stage3DProxy) : void
		{
			super.deactivate(stage3DProxy);

			if (_enableStencil)
				stage3DProxy._context3D.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.ALWAYS, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP);
		}
	}
}
