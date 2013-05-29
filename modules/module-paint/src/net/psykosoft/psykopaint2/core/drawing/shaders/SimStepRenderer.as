package net.psykosoft.psykopaint2.core.drawing.shaders
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DClearMask;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DStencilAction;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;

	public class SimStepRenderer
	{
		protected var _program : Program3D;
		private var _useColor : Boolean;

		public function SimStepRenderer(useColor : Boolean = false)
		{
			_useColor = useColor;
		}

		protected function render(context : Context3D, stroke : SimulationMesh, stencil : Boolean = true) : void
		{
			if (!_program) initProgram(context);
			context.setProgram(_program);

			if (stencil) {
				context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.EQUAL, Context3DStencilAction.INCREMENT_SATURATE, Context3DStencilAction.INCREMENT_SATURATE, Context3DStencilAction.INCREMENT_SATURATE);
				context.setStencilReferenceValue(0);
			}
			stroke.drawMesh(context, SimulationMesh.CANVAS_TEXTURE_UVS, 1, _useColor);
			context.setStencilActions();
		}

		protected function initProgram(context : Context3D) : void
		{
			var vertexAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			var fragmentAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			_program = context.createProgram();
			_program.upload(	vertexAssembler.assemble(Context3DProgramType.VERTEX, getVertexProgram()),
								fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, getFragmentProgram())
							);
		}

		protected function getVertexProgram() : String
		{
			var code : String =
					"mov v0, va1\n" +
					"mov op, va0\n";
			if (_useColor)
				code += "mov v1, va2\n";
			return code;
		}

		protected function getFragmentProgram() : String
		{
			throw new Error("Abstract Method");
		}

		public function dispose() : void
		{
			if ( _program ) _program.dispose();
			_program = null;
		}
	}
}
