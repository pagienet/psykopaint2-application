package net.psykosoft.psykopaint2.core.drawing.shaders
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationRibbonMesh;

	public class SimStepRenderer
	{
		protected var _program : Program3D;
		private var _useColor : Boolean;
		protected var _context : Context3D;

		public function SimStepRenderer(context : Context3D, useColor : Boolean = false)
		{
			_useColor = useColor;
			_context = context;
			initProgram(context);
		}

		protected function render(stroke : SimulationMesh) : void
		{
			_context.setProgram(_program);
			stroke.drawMesh(_context, SimulationRibbonMesh.CANVAS_TEXTURE_UVS, -1, _useColor);
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
