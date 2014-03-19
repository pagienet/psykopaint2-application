package net.psykosoft.psykopaint2.core.drawing.shaders.water
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DClearMask;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import flash.geom.Point;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationRibbonMesh;

	import net.psykosoft.psykopaint2.core.drawing.shaders.SimStepRenderer;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	import robotlegs.bender.framework.impl.Context;

	public class RenderPigmentRGB extends SimStepRenderer
	{
		private var _canvas : CanvasModel;

		public function RenderPigmentRGB(context : Context3D, canvas : CanvasModel)
		{
			super(context, false);
			_canvas = canvas;
//			_fragmentData = Vector.<Number>([0, 0, 0, .1]);
		}

		override protected function getFragmentProgram() : String
		{
			return 	"tex oc, v0, fs0 <2d,linear,clamp>	\n"/* +
					"add oc, ft0, fc0";                      */
		}

		public function execute(stroke : SimulationRibbonMesh, pigment : Texture) : void
		{
			_context.setTextureAt(0, pigment);
			_context.clear(0, 0, 0, 0, 0, 0, Context3DClearMask.STENCIL);
//			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentData, 1);
			render(stroke, false);
			_context.setTextureAt(0, null);
		}
	}
}