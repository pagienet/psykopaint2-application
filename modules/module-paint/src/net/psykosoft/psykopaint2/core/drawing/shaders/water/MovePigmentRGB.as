package net.psykosoft.psykopaint2.core.drawing.shaders.water
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;

	import net.psykosoft.psykopaint2.core.drawing.shaders.SimStepRenderer;

	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;

	public class MovePigmentRGB extends SimStepRenderer
	{
		private var _canvas : CanvasModel;
		private var _vertextProps : Vector.<Number>;
		private var _fragmentProps : Vector.<Number>;

		public function MovePigmentRGB(canvas : CanvasModel, scale : Number = 1)
		{
			_canvas = canvas;
			_vertextProps = Vector.<Number>([2/canvas.textureWidth, 2/canvas.textureHeight, 0, 0]);
			_fragmentProps = Vector.<Number>([.5, 2, 1, 0, 1/canvas.textureWidth/scale, 1/canvas.textureHeight/scale, 0, 0]);
		}

		override protected function getVertexProgram() : String
		{
			return	"mov v0, va1\n" +
					"mov op, va0\n" +
					"add v1, va1, vc0.xzzw\n" +
					"add v2, va1, vc0.zyzw\n";
		}

		override protected function getFragmentProgram() : String
		{
			return 	"tex ft1, v0, fs0 <2d,linear,clamp>	\n" +

					// calculate divergence to affect alpha (positive divergence means more paint is moving out than is coming in):

					"tex ft2, v1, fs0 <2d,linear,clamp>	\n" +
					"tex ft3, v2, fs0 <2d,linear,clamp>	\n" +
					"sub ft6.x, ft1.x, ft2.x\n" +			// = du/dx
					"sub ft6.y, ft1.y, ft3.y\n" +			// = dv/dy
					"add ft6.x, ft6.x, ft6.y\n" +			// = 2*(du/dx+dv/dy)
					"max ft6.x, ft6.x, fc1.z\n" +
					"mul ft6.x, ft6.x, fc0.z\n" +		// = du/dx + dv/dy = div(vel)*paintDrain
//
					"sub ft1.xy, ft1.xy, fc0.xx			\n" +
					"mul ft1.xy, ft1.xy, fc1.xy			\n" +
					"sub ft1, v0, ft1					\n" +
					"tex ft0, ft1, fs1 <2d,linear,wrap>	\n" +
					"mul ft6.x, ft0.w, ft6.x\n" +		// less drainage as alpha decreases
					"sub ft0.w, ft0.w, ft6.x\n" +
					"mov oc, ft0"
		}

		public function execute(context : Context3D, stroke : SimulationMesh, pigment : Texture, target : Texture, velocityDensity : Texture, flow : Number, bleaching : Number, textureRatioX : Number, textureRatioY : Number) : void
		{
			_fragmentProps[2] = bleaching;
			_fragmentProps[4] = 2*flow/_canvas.textureWidth;
			_fragmentProps[5] = 2*flow/_canvas.textureHeight;
			context.setRenderToTexture(target, true);
			context.clear();
			CopyTexture.copy(pigment, context, textureRatioX, textureRatioY);
			context.setTextureAt(0, velocityDensity);
			context.setTextureAt(1, pigment);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertextProps, 1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentProps, 2);
			render(context, stroke);
			context.setTextureAt(1, null);
		}
	}
}