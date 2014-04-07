package net.psykosoft.psykopaint2.core.drawing.shaders.water
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationRibbonMesh;

	import net.psykosoft.psykopaint2.core.drawing.shaders.SimStepRenderer;

	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;
	import net.psykosoft.psykopaint2.core.utils.EmbedUtils;

	public class MovePigmentCMYA extends SimStepRenderer
	{
		private var _canvas : CanvasModel;
		private var _vertexProps : Vector.<Number>;
		private var _fragmentProps : Vector.<Number>;

		[Embed(source="/../shaders/agal/MovePigmentCMYA_fixed.agal", mimeType="application/octet-stream")]
		private var Shader : Class;

		public function MovePigmentCMYA(context : Context3D, canvas : CanvasModel)
		{
			super(context);
			_canvas = canvas;
			_vertexProps = Vector.<Number>([2/canvas.width, 2/canvas.height, 0, 0]);
			_fragmentProps = Vector.<Number>([0, 0, 0, 0, -0.5, 0, 1 , 0, 0, 0, 0, 0]);
		}

		override protected function getVertexProgram() : String
		{
			return	"mov v0, va1\n" +
					"add v1, va1, vc0.xzzz\n" +
					"sub v2, va1, vc0.xzzz\n" +
					"add v3, va1, vc0.zyzz\n" +
					"sub v4, va1, vc0.zyzz\n" +
					"mov op, va0\n";
		}

		override protected function getFragmentProgram() : String
		{
			return EmbedUtils.StringFromEmbed(Shader);
		}

		public function execute(stroke : SimulationMesh, pigment : TextureBase, velocityDensity : TextureBase, backBuffer : TextureBase, pigmentFlow : Number) : void
		{
			_context.setRenderToTexture(backBuffer);
			_context.clear(0, 0, 0, 0);
			CopyTexture.copy(pigment, _context);
			_context.setTextureAt(0, velocityDensity);
			_context.setTextureAt(1, pigment);
			_fragmentProps[0] = 2 * pigmentFlow;
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexProps, 1);
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentProps, 3);
			render(stroke);
			_context.setTextureAt(1, null);
		}
	}
}