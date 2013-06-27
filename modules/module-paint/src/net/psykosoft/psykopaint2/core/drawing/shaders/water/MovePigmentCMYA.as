package net.psykosoft.psykopaint2.core.drawing.shaders.water
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;

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

		public function MovePigmentCMYA(canvas : CanvasModel)
		{
			_canvas = canvas;
			_vertexProps = Vector.<Number>([2/canvas.textureWidth, 2/canvas.textureHeight, 0, 0]);
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

		public function execute(context : Context3D, stroke : SimulationMesh, pigment : Texture, velocityDensity : Texture, width : Number, height : Number, pigmentFlow : Number) : void
		{
			context.setRenderToTexture(_canvas.halfSizeBackBuffer, true);
			context.clear(0, 0, 0, 0);
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			CopyTexture.copy(pigment, context, width, height);
			context.setTextureAt(0, velocityDensity);
			context.setTextureAt(1, pigment);
			_fragmentProps[0] = 2 * pigmentFlow;
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexProps, 1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentProps, 3);
			render(context, stroke);
			context.setTextureAt(1, null);
		}
	}
}