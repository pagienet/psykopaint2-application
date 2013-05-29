package net.psykosoft.psykopaint2.core.drawing.shaders
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DStencilAction;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.display3D.textures.TextureBase;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;

	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;

	public class SinglePigmentTextureTransfer
	{
		private var _program : Program3D;
		private var _context : Context3D;
		private var _triOffset : int;
		private var _vertexConstants : Vector.<Number>;

		public function SinglePigmentTextureTransfer(context3d : Context3D)
		{
			_context = context3d;
			_vertexConstants = Vector.<Number>([.5, -.5, 1, 1]);
			init();
		}

		public function dispose() : void
		{
			_program.dispose();
			_program = null;
		}

		private function init() : void
		{
			initProgram();
		}

		public function reset() : void
		{
			_triOffset = 0;
		}

		private function initProgram() : void
		{
			_program = _context.createProgram();
			var vertexCode : String;

			var fragmentCode : String
			vertexCode =
				"mov op, va0\n" +
				"mov v0, va1\n" +
				"mul vt0, va0, vc0\n" +
				"add vt0.xy, vt0.xy, vc0.xx\n" +
				"mov v1, vt0\n";
			fragmentCode =
				"tex ft0, v0, fs0 <2d, clamp, linear, mipnone>\n" +
				"tex oc, v1, fs1 <2d, clamp, linear, mipnone>\n";

			_program.upload(	new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, vertexCode),
								new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, fragmentCode)
			);
		}

		public function execute(stroke : SimulationMesh, original : TextureBase, target : TextureBase, source : TextureBase, brushTexture : TextureBase, textureRatioX : Number, textureRatioY : Number) : void
		{
			_context.setRenderToTexture(target, true);
			_context.clear();
			CopyTexture.copy(source, _context, textureRatioX, textureRatioY);
			_context.setProgram(_program);
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexConstants, 1);
			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			_context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.EQUAL, Context3DStencilAction.INCREMENT_SATURATE, Context3DStencilAction.INCREMENT_SATURATE, Context3DStencilAction.INCREMENT_SATURATE);
			_context.setStencilReferenceValue(0);

			_context.setTextureAt(1, source);

			_context.setTextureAt(0, brushTexture);
			_context.setColorMask(false, false, false, false);
			stroke.drawMesh(_context, SimulationMesh.BRUSH_TEXTURE_UVS, _triOffset/stroke.numTriangles, false, _triOffset <= 4? 0 : _triOffset-4);
			_context.setColorMask(true, true, true, true);
			stroke.drawMesh(_context, SimulationMesh.BRUSH_TEXTURE_UVS, 1, false, _triOffset <= 2? 0 : _triOffset-2);
			_context.setTextureAt(0, null);

			_context.setTextureAt(1, null);

			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			_context.setStencilActions();
			_triOffset = stroke.numTriangles;
		}
	}
}
