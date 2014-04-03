package net.psykosoft.psykopaint2.core.drawing.shaders.water
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DClearMask;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Point;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationRibbonMesh;

	import net.psykosoft.psykopaint2.core.drawing.shaders.SimStepRenderer;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class RenderPigment extends SimStepRenderer
	{
		private var _canvas : CanvasModel;
		private var _fragmentProps : Vector.<Number>;

		public function RenderPigment(context : Context3D, canvas : CanvasModel)
		{
			super(context, false);
			_canvas = canvas;
			_fragmentProps = Vector.<Number>([.5, 1, 0, 0]);
		}

		override protected function getFragmentProgram() : String
		{
			// something wrong with blending:
			return 	"tex ft0, v0, fs0 <2d,linear,clamp>	\n" +
					"tex ft1, v0, fs1 <2d,linear,clamp>	\n" +
					"tex ft2, v0, fs2 <2d,linear,clamp>	\n" +

					// "mul oc, ft1, ft0.y\n";

					"sub ft3, ft1, ft2\n" +
					"mul ft3, ft3, ft0.y\n" +
					"add oc, ft2, ft3";
		}

		public function execute(stroke : SimulationMesh, pigment : TextureBase, color : TextureBase, canvas : TextureBase) : void
		{
			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			_context.setTextureAt(0, pigment);
			_context.setTextureAt(1, color);
			_context.setTextureAt(2, canvas);
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentProps, 1);
			render(stroke);
			_context.setTextureAt(0, null);
			_context.setTextureAt(1, null);
			_context.setTextureAt(2, null);
		}
	}
}