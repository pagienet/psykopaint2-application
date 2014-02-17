package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.SketchBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterProxy;
	import net.psykosoft.psykopaint2.core.drawing.paths.AbstractPathEngine;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;

	public class BrushKit_Pencil extends BrushKit
	{
		
		private static const definitionXML:XML = <brush engine={BrushType.SKETCH} name="Pencil">
					<parameter id={SketchBrush.PARAMETER_N_SURFACE_INFLUENCE} path="brush" value="0.5" />
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0" />
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="pencilSketch" showInUI="0"/>
					<parameter id={AbstractBrush.PARAMETER_N_QUAD_OFFSET_RATIO} path="brush" value="0.25"/>
					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
						<parameter id={AbstractPathEngine.PARAMETER_SEND_TAPS} path="pathengine" value="0" />
						<parameter id={AbstractPathEngine.PARAMETER_SPEED_SMOOTHING} path="pathengine" value="0.02" />
						<parameter id={AbstractPathEngine.PARAMETER_OUTPUT_STEP} path="pathengine" value="4" />

						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} index={SizeDecorator.INDEX_MODE_SPEED} path="pathengine.pointdecorator_0" />
							<parameter id={SizeDecorator.PARAMETER_N_FACTOR} path="pathengine.pointdecorator_0"  value="0.2" minValue="0" maxValue="2"/>
							<parameter id={SizeDecorator.PARAMETER_N_RANGE} path="pathengine.pointdecorator_0" label="Range" value="0.05" minValue="0" maxValue="1" />
							<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} index="2" path="pathengine.pointdecorator_0"/>
						</SizeDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS}  path="pathengine.pointdecorator_1" value1="0.4" value2="0.4" />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY} path="pathengine.pointdecorator_1"  minValue="0.25" value="0.7"  showInUI="2" />
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_1" value1="0.1" value2="0.3" />
							<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_1" color="0xffffff" />
						</ColorDecorator>
						<SpawnDecorator>
							<parameter id={SpawnDecorator.PARAMETER_SL_OFFSET_MODE} index={SpawnDecorator.INDEX_MODE_PRESSURE_SPEED} path="pathengine.pointdecorator_1" />
							<parameter id={SpawnDecorator.PARAMETER_IR_MULTIPLES} value1="8" value2="8" path="pathengine.pointdecorator_1" />
							<parameter id={SpawnDecorator.PARAMETER_N_MINIMUM_OFFSET} path="pathengine.pointdecorator_2" value="0.5"/>
							
							<parameter id={SpawnDecorator.PARAMETER_N_MAXIMUM_OFFSET} path="pathengine.pointdecorator_2"  value="12" minValue="1" maxValue="24"  showInUI="1"/>
							<parameter id={SpawnDecorator.PARAMETER_AR_OFFSET_ANGLE} path="pathengine.pointdecorator_2" value1="-1" value2="1" />
							<parameter id={SpawnDecorator.PARAMETER_AR_BRUSH_ANGLE_VARIATION} path="pathengine.pointdecorator_2" value1="-2" value2="2" />
							<parameter id={SpawnDecorator.PARAMETER_NR_BRISTLE_VARIATION} path="pathengine.pointdecorator_2" value="1"/>
						</SpawnDecorator>

					</pathengine>
				</brush>
		
		public function BrushKit_Pencil()
		{
			init(definitionXML);
		}
	}
}