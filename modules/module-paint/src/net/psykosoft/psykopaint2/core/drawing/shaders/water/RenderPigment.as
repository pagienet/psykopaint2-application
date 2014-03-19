package net.psykosoft.psykopaint2.core.drawing.shaders.water
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DClearMask;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
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
			return 	"tex ft0, v0, fs0 <2d,linear,clamp>	\n" +
					"tex ft1, v0, fs1 <2d,linear,clamp>	\n" +
					"mul oc, ft1, ft0.y\n";
		}

		public function execute(stroke : SimulationMesh, pigment : Texture, color : Texture) : void
		{
			_context.setTextureAt(0, pigment);
			_context.setTextureAt(1, color);
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentProps, 1);
			_context.clear(0, 0, 0, 0, 0, 0, Context3DClearMask.STENCIL);
			render(stroke);
			_context.setTextureAt(0, null);
			_context.setTextureAt(1, null);
		}
	}
}