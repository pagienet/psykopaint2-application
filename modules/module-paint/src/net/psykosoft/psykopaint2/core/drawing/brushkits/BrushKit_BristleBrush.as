package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterProxy;
	import net.psykosoft.psykopaint2.core.drawing.paths.AbstractPathEngine;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;

	public class BrushKit_BristleBrush extends BrushKit
	{
		
		private static const definitionXML:XML = <brush engine={BrushType.SPRAY_CAN} name="Bristle Brush">
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0" />
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="line" />
					<parameter id={AbstractBrush.PARAMETER_N_QUAD_OFFSET_RATIO} path="brush" value="0"/>
					
					<parameterMapping>
						<parameter id="Brush Style" type={PsykoParameter.IconListParameter} label="Style" list="Small,Medium,Large" index="1" showInUI="0"/>
						<proxy type={PsykoParameterProxy.TYPE_DECORATOR_ACTIVATION} src="Brush Style"
							target="pathengine.pointdecorator_4"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="1"/>

					</parameterMapping>

					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
						<parameter id={AbstractPathEngine.PARAMETER_SEND_TAPS} path="pathengine" value="0" />
						<parameter id={AbstractPathEngine.PARAMETER_SPEED_SMOOTHING} path="pathengine" value="0.02" />
						<parameter id={AbstractPathEngine.PARAMETER_OUTPUT_STEP} path="pathengine" value="4" />

						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} index={SizeDecorator.INDEX_MODE_SPEED} path="pathengine.pointdecorator_0" />
							<parameter id={SizeDecorator.PARAMETER_N_FACTOR} path="pathengine.pointdecorator_0" value="0.3" minValue="0" maxValue="2"/>
							<parameter id={SizeDecorator.PARAMETER_N_RANGE} path="pathengine.pointdecorator_0" label="Range" value="0.2" minValue="0" maxValue="1" />

							<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} index="2" path="pathengine.pointdecorator_0"/>
						</SizeDecorator>
						<SpawnDecorator>
							<parameter id={SpawnDecorator.PARAMETER_SL_OFFSET_MODE} index={SpawnDecorator.INDEX_MODE_PRESSURE_SPEED} path="pathengine.pointdecorator_1" />
							<parameter id={SpawnDecorator.PARAMETER_IR_MULTIPLES} value1="8" value2="8" path="pathengine.pointdecorator_1" />
							<parameter id={SpawnDecorator.PARAMETER_N_MAXIMUM_OFFSET} path="pathengine.pointdecorator_1" value="16" minValue="0" maxValue="50" showInUI="1"/>
							<parameter id={SpawnDecorator.PARAMETER_N_MINIMUM_OFFSET} path="pathengine.pointdecorator_1" value="1" minValue="0" maxValue="200"/>
							<parameter id={SpawnDecorator.PARAMETER_AR_OFFSET_ANGLE} path="pathengine.pointdecorator_1" value1="-1" value2="1" />
							<parameter id={SpawnDecorator.PARAMETER_AR_BRUSH_ANGLE_VARIATION} path="pathengine.pointdecorator_1" value1="-2" value2="2" />
							<parameter id={SpawnDecorator.PARAMETER_N_BRISTLE_VARIATION} path="pathengine.pointdecorator_1" value="1"/>
						</SpawnDecorator>
						<BumpDecorator>
							<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_2" index={BumpDecorator.INDEX_MODE_FIXED} />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS} path="pathengine.pointdecorator_2" value="0.5" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS_RANGE} path="pathengine.pointdecorator_2" value="1.5"/>
							<parameter id={BumpDecorator.PARAMETER_N_SHININESS} path="pathengine.pointdecorator_2" value="0.9" />
							<parameter id={BumpDecorator.PARAMETER_N_GLOSSINESS} path="pathengine.pointdecorator_2" value="0.4" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE} path="pathengine.pointdecorator_2" value="0.8" />
						</BumpDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS} path="pathengine.pointdecorator_3" value1="0.0005" value2="0.1" />
							<parameter id={ColorDecorator.PARAMETER_SL_PICK_RADIUS_MODE} path="pathengine.pointdecorator_3" index="1" />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY}  path="pathengine.pointdecorator_3" value="0.75" showInUI="2" />
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_3" value1="0.1" value2="0.3" />
							<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_3" color="0xffffff"/>
						</ColorDecorator>
						<SplatterDecorator >
							<parameter id={SplatterDecorator.PARAMETER_A_OFFSET_ANGLE_RANGE} value1="0" value2="0" path="pathengine.pointdecorator_4" />
							<parameter id={SplatterDecorator.PARAMETER_A_ANGLE_ADJUSTMENT} value="90" path="pathengine.pointdecorator_4" />
							<parameter id={SplatterDecorator.PARAMETER_N_SPLAT_FACTOR} value="5" path="pathengine.pointdecorator_4" />
							<parameter id={SplatterDecorator.PARAMETER_N_SIZE_FACTOR} value="0" path="pathengine.pointdecorator_4" />
							<parameter id={SplatterDecorator.PARAMETER_N_MINIMUM_OFFSET} value="2" path="pathengine.pointdecorator_4" />
						</SplatterDecorator>

					</pathengine>
				</brush>
		
		public function BrushKit_BristleBrush()
		{
			init(definitionXML);
		}
	}
}