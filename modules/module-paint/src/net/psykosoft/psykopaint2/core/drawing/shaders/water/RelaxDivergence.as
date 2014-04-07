package net.psykosoft.psykopaint2.core.drawing.shaders.water
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DStencilAction;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationRibbonMesh;

	import net.psykosoft.psykopaint2.core.drawing.shaders.SimStepRenderer;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.utils.EmbedUtils;

	public class RelaxDivergence extends SimStepRenderer
	{
		private var _canvas : CanvasModel;
		private var _vertexProps : Vector.<Number>;
		private var _fragmentProps : Vector.<Number>;

		[Embed(source="/../shaders/agal/RelaxDivergence.agal", mimeType="application/octet-stream")]
		private var Shader : Class;


		public function RelaxDivergence(context : Context3D, canvas : CanvasModel)
		{
			super(context);
			_canvas = canvas;

			// canvas dimensions *2 because we're using a half-sized buffer (texels are bigger)
			_vertexProps = Vector.<Number>([
						4/canvas.width, -4/canvas.height, 0, 0
					]);
			_fragmentProps = Vector.<Number>([.1, 2, 0, 0]);
		}

		override protected function getVertexProgram() : String
		{
			return 	"mov v0, va1\n" +

					"sub v1, va1, vc0.xzzz\n" +
					"add v2, va1, vc0.zyzz\n" +
					"add v3, va1, vc0.xzzz\n" +
					"add v4, va1, vc0.xyzz\n" +
					"sub v5, va1, vc0.xyzz\n" +
					"sub v6, va1, vc0.xyzz\n" +

					"mov op, va0\n";
		}

		override protected function getFragmentProgram() : String
		{
			return EmbedUtils.StringFromEmbed(Shader);
		}

		public function execute(stroke : SimulationMesh, velocityDensity : TextureBase, target : TextureBase) : void
		{
			_context.setRenderToTexture(target);
			_context.setTextureAt(0, velocityDensity);
			_context.clear(.5, .5, 0, 1);
			render(stroke);
		}

		public function activate(context : Context3D) : void
		{
			if (!_program) initProgram(context);
			context.setProgram(_program);

			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentProps, 1);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexProps, 1);

		}

		public function deactivate(context : Context3D) : void
		{

		}
	}
}