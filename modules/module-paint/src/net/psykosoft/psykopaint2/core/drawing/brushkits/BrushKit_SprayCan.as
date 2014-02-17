package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterProxy;
	import net.psykosoft.psykopaint2.core.drawing.paths.AbstractPathEngine;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;

	public class BrushKit_SprayCan extends BrushKit
	{
		
		private static const definitionXML:XML = <brush engine={BrushType.SPRAY_CAN} name="Spraycan">
			<parameter id={AbstractBrush.PARAMETER_NR_SIZE_FACTOR} path="brush" value1="0" value2="1" />
			<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0"/>
			<parameter id={AbstractBrush.PARAMETER_N_BUMP_INFLUENCE} path="brush" value=".8"/>
			<parameter id={AbstractBrush.PARAMETER_N_QUAD_OFFSET_RATIO} path="brush" value=".4"/>

			<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="paint1,basic,splat,line,sumi" showInUI="0"/>
			
			<parameterMapping>
				<parameter id="Precision" label="Precision" value="0.25" minValue="0" maxValue="1" showInUI="1"/>
				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Precision"
					target={"pathengine.pointdecorator_0."+SizeDecorator.PARAMETER_N_FACTOR}
					targetProperties="value"
					targetOffsets="0.03"
					targetFactors="0.25"
					targetMappings="1"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Precision"
					target={"pathengine.pointdecorator_0."+SizeDecorator.PARAMETER_N_RANGE}
					targetProperties="value"
					targetOffsets="0.01"
					targetFactors="0.12"
					targetMappings="1"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Precision"
					target={"pathengine.pointdecorator_3."+SpawnDecorator.PARAMETER_N_MAXIMUM_SIZE}
					targetProperties="value"
					targetOffsets="0.05"
					targetFactors="0.36"
					targetMappings="1"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Precision"
					target={"pathengine.pointdecorator_3."+SpawnDecorator.PARAMETER_N_MAXIMUM_OFFSET}
					targetProperties="value"
					targetOffsets="16"
					targetFactors="40"
					targetMappings="1"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Precision"
					target={"pathengine.pointdecorator_3."+SpawnDecorator.PARAMETER_AR_OFFSET_ANGLE}
					targetProperties="lowerDegreesValue,upperDegreesValue"
					targetOffsets="-120,120"
					targetFactors="-60,60"
					targetMappings="1,1"
					/>
				
				<parameter id="Intensity" value="0.9" minValue="0" maxValue="1" showInUI="2"/>
				
				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Intensity"
					target={"pathengine.pointdecorator_4."+ColorDecorator.PARAMETER_N_OPACITY}
					targetProperties="value"
					targetOffsets="0"
					targetFactors="1"
					targetMappings="0"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Intensity"
					target={"pathengine.pointdecorator_2."+BumpDecorator.PARAMETER_N_BUMP_INFLUENCE}
					targetProperties="value"
					targetOffsets="0"
					targetFactors="1"
					targetMappings="0"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Intensity"
					target={"pathengine.pointdecorator_2."+BumpDecorator.PARAMETER_N_GLOSSINESS}
					targetProperties="value"
					targetOffsets="0.1"
					targetFactors="0.3"
					targetMappings="0"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Intensity"
					target={"pathengine.pointdecorator_2."+BumpDecorator.PARAMETER_N_BUMPINESS}
					targetProperties="value"
					targetOffsets="0"
					targetFactors="0.5"
					targetMappings="0"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Intensity"
					target={"pathengine.pointdecorator_2."+BumpDecorator.PARAMETER_N_BUMPINESS_RANGE}
					targetProperties="value"
					targetOffsets="0"
					targetFactors="0.5"
					targetMappings="0"
					/>

			</parameterMapping>
			<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>

				<parameter id={AbstractPathEngine.PARAMETER_SPEED_SMOOTHING} path="pathengine" value="0.02" />

				<SizeDecorator>
					<parameter id={SizeDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MODE_PRESSURE_SPEED} />
					<parameter id={SizeDecorator.PARAMETER_N_FACTOR} path="pathengine.pointdecorator_0" label="Size" value="0.08" minValue="0" maxValue="1" />
					<parameter id={SizeDecorator.PARAMETER_N_RANGE} path="pathengine.pointdecorator_0" label="Range" value="0.04" minValue="0" maxValue="1" />
					<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MAPPING_CIRCQUAD}/>
				</SizeDecorator>
				
				<SplatterDecorator>
					<parameter id={SplatterDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_1" index={SplatterDecorator.INDEX_MODE_SIZE_INV} />
					<parameter id={SplatterDecorator.PARAMETER_N_MAX_SIZE} path="pathengine.pointdecorator_1" value="1" />
					<parameter id={SplatterDecorator.PARAMETER_SL_OFFSET_MAPPING} path="pathengine.pointdecorator_1" index={SplatterDecorator.INDEX_MAPPING_LINEAR}   />
					<parameter id={SplatterDecorator.PARAMETER_N_SPLAT_FACTOR}  path="pathengine.pointdecorator_1" value="20" maxValue="80" />
					<parameter id={SplatterDecorator.PARAMETER_N_MINIMUM_OFFSET} path="pathengine.pointdecorator_1" value="0" />
					<parameter id={SplatterDecorator.PARAMETER_A_OFFSET_ANGLE_RANGE} path="pathengine.pointdecorator_1" value="360" />
					<parameter id={SplatterDecorator.PARAMETER_N_SIZE_FACTOR} path="pathengine.pointdecorator_1" value="0" />
				</SplatterDecorator>

				<BumpDecorator>
					<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_2" index={BumpDecorator.INDEX_MODE_RANDOM2} />
					<parameter id={BumpDecorator.PARAMETER_B_INVERT_MAPPING} path="pathengine.pointdecorator_2" value="1" />
					<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS} path="pathengine.pointdecorator_2" value="0.5" minValue="0" maxValue="1"  />
					<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS_RANGE} path="pathengine.pointdecorator_2" value="0.5"/>
					<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE} path="pathengine.pointdecorator_2" value=".8"   />
					<parameter id={BumpDecorator.PARAMETER_N_NO_BUMP_PROB} path="pathengine.pointdecorator_2" value=".8"   />
				</BumpDecorator>
				
				<SpawnDecorator>
					<parameter id={SpawnDecorator.PARAMETER_IR_MULTIPLES} path="pathengine.pointdecorator_3" value1="0" value2="20" />
					<parameter id={SpawnDecorator.PARAMETER_SL_MULTIPLE_MODE} path="pathengine.pointdecorator_3" index={SpawnDecorator.INDEX_MODE_SIZE_INV} />
					<parameter id={SpawnDecorator.PARAMETER_SL_OFFSET_MODE} path="pathengine.pointdecorator_3" index={SpawnDecorator.INDEX_MODE_RANDOM} />
					<parameter id={SpawnDecorator.PARAMETER_AR_OFFSET_ANGLE} path="pathengine.pointdecorator_3" value1="-180" value2="180" />
					<parameter id={SpawnDecorator.PARAMETER_N_MAXIMUM_SIZE} path="pathengine.pointdecorator_3" value="0.12"  />
					<parameter id={SpawnDecorator.PARAMETER_N_MINIMUM_OFFSET} path="pathengine.pointdecorator_3" value="0"  />
					<parameter id={SpawnDecorator.PARAMETER_N_MAXIMUM_OFFSET} path="pathengine.pointdecorator_3" value="16"  />
				</SpawnDecorator>
				
				<ColorDecorator>
					<parameter id={ColorDecorator.PARAMETER_N_OPACITY}  path="pathengine.pointdecorator_4" value="0.9"/>
					<parameter id={ColorDecorator.PARAMETER_N_OPACITY_RANGE}  path="pathengine.pointdecorator_4" value="0.2" />
					<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_4" value1="0.95" value2="1" />
					<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS}  path="pathengine.pointdecorator_4" value1="0.25" value2="0.33" />
					<parameter id={ColorDecorator.PARAMETER_NR_SMOOTH_FACTOR}  path="pathengine.pointdecorator_4" value1="0.8" value2="1" />
				</ColorDecorator>

				
			</pathengine>
		</brush>
		
		public function BrushKit_SprayCan()
		{
			init(definitionXML);
		}
	}
}