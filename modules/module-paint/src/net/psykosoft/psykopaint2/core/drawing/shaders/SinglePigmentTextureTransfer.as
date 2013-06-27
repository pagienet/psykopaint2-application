package net.psykosoft.psykopaint2.core.drawing.shaders
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DStencilAction;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;

	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;

	public class SinglePigmentTextureTransfer
	{
		public static const TARGET_X : String = "x";
		public static const TARGET_Y : String = "y";
		public static const TARGET_Z : String = "z";
		public static const TARGET_W : String = "w";

		private var _program : Program3D;
		private var _context : Context3D;
		private var _fragmentConstants : Vector.<Number>;
		private var _triOffset : int;

		public function SinglePigmentTextureTransfer(context3d : Context3D)
		{
			_context = context3d;
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
			_fragmentConstants = Vector.<Number>([1, 0, 0, 0]);
		}

		public function reset() : void
		{
			_triOffset = 0;
		}

		private function initProgram() : void
		{
			_program = _context.createProgram();
			var vertexCode : String = 	"mov op, va0\n" +
										"mov v0, va1\n";

			var fragmentCode : String = "tex oc, v0, fs0 <2d, clamp, linear, mipnone>\n";

			_program.upload(	new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, vertexCode),
					new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, fragmentCode)
			);
		}

		public function execute(stroke : SimulationMesh, source : TextureBase, target : TextureBase, brushTexture : TextureBase, textureRatioX : Number, textureRatioY : Number) : void
		{
			var triOffset : int = _triOffset <= 2? 0 : _triOffset-2;
			var stationaryEnd : int = stroke.numTriangles - stroke.stationaryTriangleCount;
			if (triOffset > stationaryEnd) triOffset = stationaryEnd;
			// nothing new
			if (triOffset == stroke.numTriangles) return;

			_context.setRenderToTexture(target);
			_context.clear();
			CopyTexture.copy(source, _context, textureRatioX, textureRatioY);
			_context.setProgram(_program);
			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentConstants, 1);

			_context.setTextureAt(0, brushTexture);
			stroke.drawMesh(_context, SimulationMesh.BRUSH_TEXTURE_UVS, 1, false, triOffset);
			_context.setTextureAt(0, null);

			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			_context.setStencilActions();
			_triOffset = stroke.numTriangles;
		}
	}
}
