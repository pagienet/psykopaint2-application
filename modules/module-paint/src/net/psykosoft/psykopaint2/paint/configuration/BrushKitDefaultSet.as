package net.psykosoft.psykopaint2.paint.configuration
{
	
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit;
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit_BristleBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit_Cosmetics;
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit_Paintgun;
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit_Pencil;
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit_SprayCan;
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit_WaterColor;

	public class BrushKitDefaultSet
	{
		
		public static const brushKits:Vector.<BrushKit> = Vector.<BrushKit>([
			new BrushKit_SprayCan(),
			new BrushKit_BristleBrush(),
			new BrushKit_Pencil(),
			new BrushKit_WaterColor(),
			new BrushKit_Paintgun()
			//new BrushKit_Cosmetics()
		]);
		
		/*
		public static const brushKitData:XML =
			<brushkits>
				<brush engine={BrushType.SPRAY_CAN} name="Spraycan">
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
							<parameter id={SplatterDecorator.PARAMETER_N_SPLAT_FACTOR}  path="pathengine.pointdecorator_1" value="20" maxValue="80" previewID={PreviewIconFactory.PREVIEW_SIZE} />
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

<!--
				<brush engine={BrushType.SPRAY_CAN} name="test">
					<parameter id={AbstractBrush.PARAMETER_NR_SIZE_FACTOR} path="brush" value1="0" value2="1" />
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0"/>
					<parameter id={AbstractBrush.PARAMETER_N_BUMP_INFLUENCE} path="brush" value=".8"/>
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="paint1"/>
					<parameterMapping>
						<parameter id="Size" label="Size" previewID={PreviewIconFactory.PREVIEW_SIZE} value="0.25" minValue="0.1" maxValue="1" showInUI="0"/>
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
							src="Size"
							target={"pathengine.pointdecorator_0."+SizeDecorator.PARAMETER_N_FACTOR}
							targetProperties="value"
							targetOffsets="0.05"
							targetFactors="0.2"
							targetMappings="1"
							/>
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
							src="Size"
							target={"pathengine.pointdecorator_0."+SizeDecorator.PARAMETER_N_RANGE}
							targetProperties="value"
							targetOffsets="-0.05"
							targetFactors="0.2"
							/>
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
							src="Size"
							target={"pathengine.pointdecorator_1."+SplatterDecorator.PARAMETER_N_SPLAT_FACTOR}
							targetProperties="value"
							targetOffsets="0"
							targetFactors="50"
							/>

					</parameterMapping>
					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>

						<parameter id={AbstractPathEngine.PARAMETER_SPEED_SMOOTHING} path="pathengine" value="0.02" />

						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MODE_PRESSURE_SPEED} />
							<parameter id={SizeDecorator.PARAMETER_N_FACTOR} path="pathengine.pointdecorator_0" label="Size" value="0.16" minValue="0" maxValue="1" />
							<parameter id={SizeDecorator.PARAMETER_N_RANGE} path="pathengine.pointdecorator_0" label="Range" value="0.1" minValue="0" maxValue="1" />
							<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MAPPING_CIRCQUAD}/>
						</SizeDecorator>

						<SplatterDecorator>
							<parameter id={SplatterDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_1" index={SplatterDecorator.INDEX_MODE_PRESSURE_SPEED} />
							<parameter id={SplatterDecorator.PARAMETER_SL_OFFSET_MAPPING} path="pathengine.pointdecorator_1" index={SplatterDecorator.INDEX_MAPPING_CIRCQUAD}   />
							<parameter id={SplatterDecorator.PARAMETER_N_SPLAT_FACTOR}  path="pathengine.pointdecorator_1" value="20" />
							<parameter id={SplatterDecorator.PARAMETER_N_MINIMUM_OFFSET} path="pathengine.pointdecorator_1" value="1" />
							<parameter id={SplatterDecorator.PARAMETER_A_OFFSET_ANGLE_RANGE} path="pathengine.pointdecorator_1" value="15" />
							<parameter id={SplatterDecorator.PARAMETER_N_SIZE_FACTOR} path="pathengine.pointdecorator_1" value="0.2" />
						</SplatterDecorator>

						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_2" index={ColorDecorator.INDEX_MODE_PICK_COLOR} />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY}  path="pathengine.pointdecorator_2" value="0.9" />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY_RANGE}  path="pathengine.pointdecorator_2" value="0.2" />
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_2" value1="0.5" value2="0.9" />
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS}  path="pathengine.pointdecorator_2" value1="0.25" value2="0.33" />
							<parameter id={ColorDecorator.PARAMETER_NR_SMOOTH_FACTOR}  path="pathengine.pointdecorator_2" value1="0.8" value2="1" />
							<parameter id={ColorDecorator.PARAMETER_B_COLORMATRIX}  path="pathengine.pointdecorator_2" value="1" />
							<parameter id={ColorDecorator.PARAMETER_NR_BRIGHTNESS}  path="pathengine.pointdecorator_2" value1="-15" value2="15" />
						</ColorDecorator>

						<BumpDecorator>
							<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_3" index={BumpDecorator.INDEX_MODE_RANDOM} />
							<parameter id={BumpDecorator.PARAMETER_B_INVERT_MAPPING} path="pathengine.pointdecorator_3" value="1" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS} path="pathengine.pointdecorator_3"  value="0" minValue="0" maxValue="3" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS_RANGE} path="pathengine.pointdecorator_3" value="3"/>
							<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE} path="pathengine.pointdecorator_3" value=".8"   />
						</BumpDecorator>
					</pathengine>
				</brush>
				<brush engine={BrushType.SPRAY_CAN} name="Spray Can">
					<parameter id={AbstractBrush.PARAMETER_NR_SIZE_FACTOR} path="brush" value1="0" value2="1" />
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0"/>
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="splat,paint1,splotch,noisy"/>

					<parameterMapping>
						<parameter id="Style" type={PsykoParameter.IconListParameter} label="Style" list="Fat Brush,Speed Brush,Van Gogh,Sprinkle,Smear Brush,Air Brush" showInUI="0"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE}
							src="Style"
							target="pathengine.pointdecorator_0.Factor"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="1,2,3"
							value1="0.12" value2="0.7"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE}
							src="Style"
							target="pathengine.pointdecorator_0.Factor"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="0,4"
							value1="0.47" value2="0.5"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE}
							src="Style"
							target="pathengine.pointdecorator_0.Factor"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="5"
							value1="0.4" value2="1"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE}
							src="Style"
							target="pathengine.pointdecorator_2.Color Blending"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="0,1,2,3,5"
							value1="0.5" value2="0.9"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE}
							src="Style"
							target="pathengine.pointdecorator_2.Color Blending"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="4"
							value1="0.0001" value2="0.001"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE}
							src="Style"
							target="pathengine.pointdecorator_1.Splat Factor"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="0,1,2,3"
							value="40"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE}
							src="Style"
							target="pathengine.pointdecorator_1.Splat Factor"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="4"
							value="10"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE}
							src="Style"
							target="brush.Shapes"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="0,3"
							index="0"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE}
							src="Style"
							target="brush.Shapes"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="1,2,4"
							index="1"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE}
							src="Style"
							target="brush.Shapes"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="5"
							index="3"/>

						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE}
							src="Style"
							target="pathengine.pointdecorator_2.Opacity"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="5"
							value="0.175"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE}
							src="Style"
							target="pathengine.pointdecorator_2.Opacity"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="0,1,2,3,4"
							value="0.9" />

						<proxy type={PsykoParameterProxy.TYPE_DECORATOR_ACTIVATION}
							src="Style"
							target="pathengine.pointdecorator_4"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="2,3"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE}
							src="Style"
							target="pathengine.pointdecorator_4.Angle Adjustment"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="2"
							value="90"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE}
							src="Style"
							target="pathengine.pointdecorator_4.Angle Adjustment"
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="3"
							value="0"/>

					</parameterMapping>

					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
					<parameter id={AbstractPathEngine.PARAMETER_SPEED_SMOOTHING} path="pathengine" value="0.02" />

						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MODE_PRESSURE_SPEED} />
							<parameter id={SizeDecorator.PARAMETER_N_FACTOR} path="pathengine.pointdecorator_0" value="0.48" minValue="0" maxValue="1" showInUI="1"/>
							<parameter id={SizeDecorator.PARAMETER_N_RANGE} path="pathengine.pointdecorator_0" label="Range" value="0.2" minValue="0" maxValue="1" />
							<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MAPPING_CIRCQUAD}/>
						</SizeDecorator>
						<SplatterDecorator>
							<parameter id={SplatterDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_1" index={SplatterDecorator.INDEX_MODE_PRESSURE_SPEED} />
							<parameter id={SplatterDecorator.PARAMETER_SL_OFFSET_MAPPING} path="pathengine.pointdecorator_1" index="1"  />
							<parameter id={SplatterDecorator.PARAMETER_N_SPLAT_FACTOR}  path="pathengine.pointdecorator_1" value="40" />
							<parameter id={SplatterDecorator.PARAMETER_N_MINIMUM_OFFSET} path="pathengine.pointdecorator_1" value="0" />
							<parameter id={SplatterDecorator.PARAMETER_A_OFFSET_ANGLE_RANGE} path="pathengine.pointdecorator_1" value="15" />
							<parameter id={SplatterDecorator.PARAMETER_N_SIZE_FACTOR} path="pathengine.pointdecorator_1" value="0.2" />
						</SplatterDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_2" index={ColorDecorator.INDEX_MODE_PICK_COLOR} />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY}  path="pathengine.pointdecorator_2" value="0.9"/>
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_2" value1="0.5" value2="0.9" />
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS}  path="pathengine.pointdecorator_2" value1="0.25" value2="0.33" />
							<parameter id={ColorDecorator.PARAMETER_NR_SMOOTH_FACTOR}  path="pathengine.pointdecorator_2" value1="0.8" value2="1" />
							<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_2" color="0xffffff"/>
						</ColorDecorator>
						<BumpDecorator>
							<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_3" index={BumpDecorator.INDEX_MODE_SPEED} />
							<parameter id={BumpDecorator.PARAMETER_B_INVERT_MAPPING} path="pathengine.pointdecorator_3" value="1" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS} path="pathengine.pointdecorator_3" value="0.5" minValue="0" maxValue="1"  />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS_RANGE} path="pathengine.pointdecorator_3" value="0.5"/>
						</BumpDecorator>
						<CircularRotationDecorator active="0">
							<parameter id={CircularRotationDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_4" index="1" />
							<parameter id={CircularRotationDecorator.PARAMETER_I_RANDOM_POINT_COUNT} path="pathengine.pointdecorator_4" value="40" />
							<parameter id={CircularRotationDecorator.PARAMETER_A_ANGLE_ADJUSTMENT} path="pathengine.pointdecorator_4" value="90" />
						</CircularRotationDecorator>
					</pathengine>
				</brush>

-->
				<brush engine={BrushType.SPRAY_CAN} name="Bristle Brush">
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
							<parameter id={SpawnDecorator.PARAMETER_NR_BRISTLE_VARIATION} path="pathengine.pointdecorator_1" value="1"/>
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



				<!-- 
				<brush engine={BrushType.CLASSIC_PSYKO} name="PsykoClassic">
					<parameter id={AbstractBrush.PARAMETER_NR_SIZE_FACTOR} path="brush" value1="0" value2="1" />
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0"/>
					<parameter id={AbstractBrush.PARAMETER_N_BUMP_INFLUENCE} path="brush" value="1"/>
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="render"/>
					
					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
						<parameter id={AbstractPathEngine.PARAMETER_SPEED_SMOOTHING} path="pathengine" value="0.02" />
					</pathengine>
				</brush>

				<brush engine={BrushType.PENCIL} name="Pencil">
					<parameterMapping>
						<parameter id="Custom Color" type={PsykoParameter.BooleanParameter}  value="0"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} src="Custom Color"
							target="pathengine.pointdecorator_1.Color Mode"
							condition={PsykoParameterProxy.CONDITION_TRUE }

							index={ColorDecorator.INDEX_MODE_FIXED_COLOR}/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} src="Custom Color"
							target="pathengine.pointdecorator_1.Color Mode"
							condition={PsykoParameterProxy.CONDITION_FALSE }

							index={ColorDecorator.INDEX_MODE_PICK_COLOR}/>

						<parameter id="Size" type={PsykoParameter.NumberParameter} value=".3" minValue="0" maxValue="1" />
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} src="Size"
							target="pathengine.pointdecorator_0.Factor"
							targetMappings="0,0"
							targetOffsets="0,0"
							targetFactors="1,1"
							targetProperties="lowerRangeValue,upperRangeValue"/>

						<parameter id="Intensity" type={PsykoParameter.NumberParameter} value=".4" minValue="0" maxValue="1" />
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} src="Intensity"
							target="pathengine.pointdecorator_1.Opacity"
							targetMappings="0"
							targetOffsets="0"
							targetFactors="1"
							targetProperties="value"/>
					</parameterMapping>
					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_0" index="1" />
							<parameter id={SizeDecorator.PARAMETER_NR_FACTOR} label="Size" path="pathengine.pointdecorator_0" value1=".3" value2=".3"/>
							<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} path="pathengine.pointdecorator_0" value="2" />
						</SizeDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_1" index={ColorDecorator.INDEX_MODE_PICK_COLOR} />
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS}  path="pathengine.pointdecorator_1" value1="0.4" value2="0.4" />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY} label="Intensity" path="pathengine.pointdecorator_1" value=".4"/>
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_1" value1="0.7" value2="0.9" />
							<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_1" color="0xffffff" />

						</ColorDecorator>
					</pathengine>
					<parameter id="Shapes" path="brush" index="0" list="pencil" />
				</brush>        -->

				<brush engine={BrushType.SKETCH} name="Pencil">
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


				<brush engine={BrushType.WATER_COLOR} name="Water Color">
					<!--<parameter id={WaterColorBrush.PARAMETER_N_SURFACE_INFLUENCE} path="brush" value="0.75" showInUI="0"/>-->
					<parameter id={WaterColorBrush.PARAMETER_N_PIGMENT_STAINING} type={PsykoParameter.NumberParameter} path="brush" value=".4" />
					<parameter id={WaterColorBrush.PARAMETER_N_PIGMENT_DENSITY} type={PsykoParameter.NumberParameter} path="brush" value=".4" />
					<!--<parameter id={WaterColorBrush.PARAMETER_N_PIGMENT_GRANULATION} path="brush" value="1.5" />-->
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES}  path="brush" index="0" list="basic,wet" showInUI="0"/>

					<parameterMapping>
						<parameter id="WaterColorSize" showInUI="1" minValue="0" maxValue="1" value=".77"/>
						<proxy 	type={PsykoParameterProxy.TYPE_VALUE_MAP} src="WaterColorSize"
								target={"brush."+AbstractBrush.PARAMETER_NR_SIZE_FACTOR}
								targetProperties="lowerRangeValue,upperRangeValue"
								targetOffsets="0.0,0.0"
								targetFactors="1.0,1.0"/>

						<parameter id="WaterColorOpacity" showInUI="2" minValue="0" maxValue="1" value=".33"/>
						<proxy 	type={PsykoParameterProxy.TYPE_VALUE_MAP} src="WaterColorOpacity"
								target={"brush."+WaterColorBrush.PARAMETER_N_PIGMENT_DENSITY}
								targetOffsets="0"
								targetFactors="0.25"/>
						<proxy 	type={PsykoParameterProxy.TYPE_VALUE_MAP} src="WaterColorOpacity"
								target={"brush."+WaterColorBrush.PARAMETER_N_PIGMENT_STAINING}
								targetOffsets="0.1"
								targetFactors="0.6"/>
					</parameterMapping>

					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}/>
				</brush>

				<brush engine={BrushType.SPRAY_CAN} name="Eraser">
					<parameter id={AbstractBrush.PARAMETER_NR_SIZE_FACTOR} path="brush" value1="0" value2="1"/>
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0"/>
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="splotch,basic smooth,splat,basic,noisy" showInUI="0"/>
					<parameter id={AbstractBrush.PARAMETER_SL_BLEND_MODE} path="brush" index="1"/>
					
					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MODE_FIXED} />
							<parameter id={SizeDecorator.PARAMETER_N_FACTOR} path="pathengine.pointdecorator_0" value="0.55" minValue="0" maxValue="2" showInUI="1"/>
							<parameter id={SizeDecorator.PARAMETER_N_RANGE} path="pathengine.pointdecorator_0" value="0.15" minValue="0" maxValue="1" />
							<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} path="pathengine.pointdecorator_0" index="1"/>
						</SizeDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY} value="0.5" path="pathengine.pointdecorator_1" showInUI="2" />
							<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_1" color="0xffffffff" />
						</ColorDecorator>
						<BumpDecorator>
							<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_2" index={BumpDecorator.INDEX_MODE_FIXED} />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS} path="pathengine.pointdecorator_2" value="0" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS_RANGE} path="pathengine.pointdecorator_2" value="0"/>
							<parameter id={BumpDecorator.PARAMETER_N_SHININESS} path="pathengine.pointdecorator_2" value="0" />
							<parameter id={BumpDecorator.PARAMETER_N_GLOSSINESS} path="pathengine.pointdecorator_2" value="0" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE}  path="pathengine.pointdecorator_2" value="1" minValue="0" maxValue="1" />
						</BumpDecorator>
					</pathengine>
				</brush>
				<brush engine={BrushType.BLOB} name="Cutout">
						<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="render" showInUI="0"/>

						<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
							
							<ColorDecorator>
								<parameter id={ColorDecorator.PARAMETER_N_OPACITY} label="Intensity" path="pathengine.pointdecorator_0" value="0.9" showInUI="2"/>
								<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING} path="pathengine.pointdecorator_0" value1="1" value2="1" />
							</ColorDecorator>
						<SplatterDecorator >
							<parameter id={SplatterDecorator.PARAMETER_A_OFFSET_ANGLE_RANGE} value1="0" value2="0" path="pathengine.pointdecorator_1" />
							<parameter id={SplatterDecorator.PARAMETER_A_ANGLE_ADJUSTMENT} value="90" path="pathengine.pointdecorator_1" />
							<parameter id={SplatterDecorator.PARAMETER_N_SPLAT_FACTOR} value="0" minValue="0" maxValue="5" path="pathengine.pointdecorator_1" showInUI="1"/>
							<parameter id={SplatterDecorator.PARAMETER_N_SIZE_FACTOR} value="0" path="pathengine.pointdecorator_1" />
							<parameter id={SplatterDecorator.PARAMETER_N_MINIMUM_OFFSET} value="0" path="pathengine.pointdecorator_1" />
						</SplatterDecorator>	
						</pathengine>
				</brush>
				<!--<brush engine={BrushType.WATER_DAMAGE} name="Water Damage">
					<parameter id={WaterDamageBrush.PARAMETER_N_SURFACE_INFLUENCE} path="brush" value="0.5"/>
					<parameter id={WaterDamageBrush.PARAMETER_N_PIGMENT_FLOW} path="brush" value="0.25" />
					<parameter id={WaterDamageBrush.PARAMETER_N_PIGMENT_FLOW} path="brush" value="0.25" />
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES}  path="brush" index="0" list="wet"/>
					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}/>
				</brush>-->
		</brushkits>;

/*
		public static const brushKitDataColorMode:XML = 
			<brushkits>
				<brush engine={BrushType.SPRAY_CAN} name="Quill">
					<parameter id={AbstractBrush.PARAMETER_NR_SIZE_FACTOR} path="brush" value1="0" value2="1" />
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="basic smooth"/>
					
					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>

						<parameter id={AbstractPathEngine.PARAMETER_SPEED_SMOOTHING} path="pathengine" value="0.99" />
						<parameter id={AbstractPathEngine.PARAMETER_OUTPUT_STEP} path="pathengine" value="0.75" />
						
						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MODE_PRESSURE_SPEED} />
							<parameter id={SizeDecorator.PARAMETER_N_FACTOR} path="pathengine.pointdecorator_0" label="Size" value="0.12" minValue="0" maxValue="1" />
							<parameter id={SizeDecorator.PARAMETER_N_RANGE} path="pathengine.pointdecorator_0" label="Range" value="0.11" minValue="0" maxValue="1" />
							<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MAPPING_LINEAR}/>
						</SizeDecorator>

						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_1" index={ColorDecorator.INDEX_MODE_FIXED_COLOR} />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY} label="Intensity" path="pathengine.pointdecorator_1" value="1" />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY_RANGE}  path="pathengine.pointdecorator_1" value="0" />
						</ColorDecorator>

						<BumpDecorator>
							<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_2" index={BumpDecorator.INDEX_MODE_FIXED} />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS} path="pathengine.pointdecorator_2" value="0.5" minValue="0" maxValue="1" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS_RANGE} path="pathengine.pointdecorator_2" value="0"/>
							<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE} path="pathengine.pointdecorator_2" value="0.5"   />

						</BumpDecorator>
					</pathengine>
				</brush>
				<brush engine={BrushType.SPRAY_CAN} name="Splatter Brush">
					<parameter id={AbstractBrush.PARAMETER_NR_SIZE_FACTOR} path="brush" value1="0" value2="1" />
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0"/>
					<parameter id={AbstractBrush.PARAMETER_N_BUMP_INFLUENCE} path="brush" value=".8"/>
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="paint1,basic,splat,line,sumi" showInUI="0"/>
					<parameterMapping>
						<parameter id="Precision"  value="0.25" minValue="0" maxValue="1" showInUI="1"/>
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
						
						<parameter id="Color Precision" value="100" minValue="0" maxValue="100" />
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
							src="Color Precision"
							target={"pathengine.pointdecorator_4."+ColorDecorator.PARAMETER_N_PICK_RANDOM_OFFSET_FACTOR}
							targetProperties="value"
							targetOffsets="100"
							targetFactors="-1"
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
							<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_2" index={BumpDecorator.INDEX_MODE_RANDOM} />
							<parameter id={BumpDecorator.PARAMETER_B_INVERT_MAPPING} path="pathengine.pointdecorator_2" value="1" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS} path="pathengine.pointdecorator_2" value="0.7" minValue="0" maxValue="1"  />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS_RANGE} path="pathengine.pointdecorator_2" value="0.2"/>
							<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE} path="pathengine.pointdecorator_2" value=".8"   />
						</BumpDecorator>
						
						<SpawnDecorator>
							<parameter id={SpawnDecorator.PARAMETER_IR_MULTIPLES} path="pathengine.pointdecorator_3" value1="0" value2="20" />
							<parameter id={SpawnDecorator.PARAMETER_SL_MULTIPLE_MODE} path="pathengine.pointdecorator_3" index={SpawnDecorator.INDEX_MODE_SIZE_INV} />
							<parameter id={SpawnDecorator.PARAMETER_SL_OFFSET_MODE} path="pathengine.pointdecorator_3" index={SpawnDecorator.INDEX_MODE_RANDOM} />
							<parameter id={SpawnDecorator.PARAMETER_AR_OFFSET_ANGLE} path="pathengine.pointdecorator_3" value1="-180" value2="180" />
							<parameter id={SpawnDecorator.PARAMETER_N_MAXIMUM_SIZE} path="pathengine.pointdecorator_3" value="0.12"  />
						</SpawnDecorator>
						
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_4" index={ColorDecorator.INDEX_MODE_FIXED_COLOR} />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY}  path="pathengine.pointdecorator_4"  value="0.9" showInUI="2"/>
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY_RANGE}  path="pathengine.pointdecorator_4" value="0.2" />
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_4" value1="0.95" value2="1" />
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS}  path="pathengine.pointdecorator_4" value1="0.25" value2="0.33" />
							<parameter id={ColorDecorator.PARAMETER_NR_SMOOTH_FACTOR}  path="pathengine.pointdecorator_4" value1="0.8" value2="1" />
						</ColorDecorator>

						
					</pathengine>
				</brush>
<!--
				<brush engine={BrushType.SPRAY_CAN} name="Default">
					<parameter id={AbstractBrush.PARAMETER_NR_SIZE_FACTOR} path="brush" value1="0" value2="1" />
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0"/>
					<parameter id={AbstractBrush.PARAMETER_N_BUMP_INFLUENCE} path="brush" value=".8"/>
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="paint1" showInUI="0"//>
					<parameterMapping>
						<parameter id="Size" label="Size" value="0.55" minValue="0.1" maxValue="1" showInUI="1"/>
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} 
							src="Size" 
							target={"pathengine.pointdecorator_0."+SizeDecorator.PARAMETER_N_FACTOR}
							targetProperties="value"
							targetOffsets="0.05"
							targetFactors="0.2"
							targetMappings="1"
							/>
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} 
							src="Size" 
							target={"pathengine.pointdecorator_0."+SizeDecorator.PARAMETER_N_RANGE}
							targetProperties="value"
							targetOffsets="-0.05"
							targetFactors="0.2"
							/>
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} 
							src="Size" 
							target={"pathengine.pointdecorator_1."+SplatterDecorator.PARAMETER_N_SPLAT_FACTOR}
							targetProperties="value"
							targetOffsets="0"
							targetFactors="40"
							/>
						
						<parameter id="Quantity" label="Quantity" value="0.5" minValue="0" maxValue="1" />
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} 
							src="Quantity" 
							target={"pathengine.pointdecorator_2."+ColorDecorator.PARAMETER_N_OPACITY}
							targetProperties="value"
							targetOffsets="0.1"
							targetFactors="0.9"
							targetMappings="2"
							/>
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} 
							src="Quantity" 
							target={"pathengine.pointdecorator_2."+ColorDecorator.PARAMETER_N_OPACITY_RANGE}
							targetProperties="value"
							targetOffsets="0"
							targetFactors="0.25"
							targetMappings="0"
							/>
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} 
							src="Quantity" 
							target={"pathengine.pointdecorator_3."+BumpDecorator.PARAMETER_N_BUMPINESS}
							targetProperties="value"
							targetOffsets="0"
							targetFactors="1"
							targetMappings="0"
							/>
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} 
							src="Quantity" 
							target={"pathengine.pointdecorator_3."+BumpDecorator.PARAMETER_N_BUMPINESS_RANGE}
							targetProperties="value"
							targetOffsets="0"
							targetFactors="0.25"
							targetMappings="0"
							/>
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} 
							src="Quantity" 
							target={"pathengine.pointdecorator_3."+BumpDecorator.PARAMETER_N_BUMP_INFLUENCE}
							targetProperties="value"
							targetOffsets="0.8"
							targetFactors="-0.3"
							targetMappings="0"
							/>

						<parameter id="Wetness" value="0.5" minValue="0" maxValue="1" />
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} 
							src="Wetness" 
							target={"pathengine.pointdecorator_3."+BumpDecorator.PARAMETER_N_SHININESS}
							targetProperties="value"
							targetOffsets="0"
							targetFactors="1"
							targetMappings="0"
							/>
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} 
							src="Wetness" 
							target={"pathengine.pointdecorator_3."+BumpDecorator.PARAMETER_N_GLOSSINESS}
							targetProperties="value"
							targetOffsets="0"
							targetFactors="1"
							targetMappings="0"
							/>
						

					</parameterMapping>
					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>

						<parameter id={AbstractPathEngine.PARAMETER_SPEED_SMOOTHING} path="pathengine" value="0.02" />
						
						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MODE_PRESSURE_SPEED} />
							<parameter id={SizeDecorator.PARAMETER_N_FACTOR} path="pathengine.pointdecorator_0" label="Size" value="0.16" minValue="0" maxValue="1" />
							<parameter id={SizeDecorator.PARAMETER_N_RANGE} path="pathengine.pointdecorator_0" label="Range" value="0.1" minValue="0" maxValue="1" />
							<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MAPPING_CIRCQUAD}/>
						</SizeDecorator>

						<SplatterDecorator>
							<parameter id={SplatterDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_1" index={SplatterDecorator.INDEX_MODE_PRESSURE_SPEED} />
							<parameter id={SplatterDecorator.PARAMETER_SL_OFFSET_MAPPING} path="pathengine.pointdecorator_1" index={SplatterDecorator.INDEX_MAPPING_CIRCQUAD}   />
							<parameter id={SplatterDecorator.PARAMETER_N_SPLAT_FACTOR}  path="pathengine.pointdecorator_1" value="20" />
							<parameter id={SplatterDecorator.PARAMETER_N_MINIMUM_OFFSET} path="pathengine.pointdecorator_1" value="1" />
							<parameter id={SplatterDecorator.PARAMETER_A_OFFSET_ANGLE_RANGE} path="pathengine.pointdecorator_1" value="15" />
							<parameter id={SplatterDecorator.PARAMETER_N_SIZE_FACTOR} path="pathengine.pointdecorator_1" value="0.2" />
						</SplatterDecorator>

						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_2" index={ColorDecorator.INDEX_MODE_FIXED_COLOR} />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY} label="Intensity" path="pathengine.pointdecorator_2" value="0.9" />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY_RANGE}  path="pathengine.pointdecorator_2" value="0.2" />
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_2" value1="0.5" value2="0.9" />
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS}  path="pathengine.pointdecorator_2" value1="0.25" value2="0.33" />
							<parameter id={ColorDecorator.PARAMETER_NR_SMOOTH_FACTOR}  path="pathengine.pointdecorator_2" value1="0.8" value2="1" />
							<parameter id={ColorDecorator.PARAMETER_B_COLORMATRIX}  path="pathengine.pointdecorator_2" value="1" />
							<parameter id={ColorDecorator.PARAMETER_NR_BRIGHTNESS}  path="pathengine.pointdecorator_2" value1="-5" value2="5" />
						</ColorDecorator>

						<BumpDecorator>
							<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_3" index={BumpDecorator.INDEX_MODE_RANDOM} />
							<parameter id={BumpDecorator.PARAMETER_B_INVERT_MAPPING} path="pathengine.pointdecorator_3" value="1" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS} path="pathengine.pointdecorator_3" value="0.5" minValue="0.5" maxValue="0.5" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS_RANGE} path="pathengine.pointdecorator_3" value="0.05"/>
							<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE} path="pathengine.pointdecorator_3" value="0.8"   />

						</BumpDecorator>
					</pathengine>
				</brush>
-->



				
				<brush engine={BrushType.SPRAY_CAN} name="Spray Can">
					<parameter id={AbstractBrush.PARAMETER_NR_SIZE_FACTOR} path="brush" value1="0" value2="1" />
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0"/>
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="splat,paint1,splotch,noisy"/>

					<parameterMapping>
						<parameter id="Style" type={PsykoParameter.IconListParameter} list="Fat Brush,Speed Brush,Van Gogh,Sprinkle,Smear Brush,Air Brush" showInUI="0"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="pathengine.pointdecorator_0.Factor" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="1,2,3"
							value1="0.12" value2="0.7"/>
						
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="pathengine.pointdecorator_0.Factor" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="0,4"
							value1="0.47" value2="0.5"/>	
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="pathengine.pointdecorator_0.Factor" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="5"
							value1="0.4" value2="1"/>


						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="pathengine.pointdecorator_2.Color Blending" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="0,1,2,3,5"
							value1="0.5" value2="0.9"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="pathengine.pointdecorator_2.Color Blending" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="4"
							value1="0.0001" value2="0.001"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="pathengine.pointdecorator_1.Splat Factor" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="0,1,2,3"
							value="40"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="pathengine.pointdecorator_1.Splat Factor" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="4"
							value="10"/>	
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="brush.Shapes" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="0,3"
							index="0"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="brush.Shapes" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="1,2,4"
							index="1"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="brush.Shapes" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="5"
							index="3"/>


						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="pathengine.pointdecorator_2.Opacity" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="5"
							value="0.175"/>			

						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="pathengine.pointdecorator_2.Opacity" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="0,1,2,3,4"
							value="0.9" 
							/>	

						<proxy type={PsykoParameterProxy.TYPE_DECORATOR_ACTIVATION} 
							src="Style" 
							target="pathengine.pointdecorator_4" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="2,3"/>	
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="pathengine.pointdecorator_4.Angle Adjustment" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="2"
							value="90"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="pathengine.pointdecorator_4.Angle Adjustment" 

							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="3"
							value="0"/>

					</parameterMapping>

					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
					<parameter id={AbstractPathEngine.PARAMETER_SPEED_SMOOTHING} path="pathengine" value="0.02" />

						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MODE_PRESSURE_SPEED} />
							<parameter id={SizeDecorator.PARAMETER_N_FACTOR} path="pathengine.pointdecorator_0" label="Size" value="0.49" minValue="0" maxValue="1" showInUI="1"/>
							<parameter id={SizeDecorator.PARAMETER_N_RANGE} path="pathengine.pointdecorator_0" label="Range" value="0.1" minValue="0" maxValue="1" />
														
							<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MAPPING_CIRCQUAD}/>
						</SizeDecorator>
						<SplatterDecorator>
							<parameter id={SplatterDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_1" index={SplatterDecorator.INDEX_MODE_PRESSURE_SPEED} />
							<parameter id={SplatterDecorator.PARAMETER_SL_OFFSET_MAPPING} path="pathengine.pointdecorator_1" index="1"  />
							<parameter id={SplatterDecorator.PARAMETER_N_SPLAT_FACTOR}  path="pathengine.pointdecorator_1" value="40" />
							<parameter id={SplatterDecorator.PARAMETER_N_MINIMUM_OFFSET} path="pathengine.pointdecorator_1" value="0" />
							<parameter id={SplatterDecorator.PARAMETER_A_OFFSET_ANGLE_RANGE} path="pathengine.pointdecorator_1" value="15" />
							<parameter id={SplatterDecorator.PARAMETER_N_SIZE_FACTOR} path="pathengine.pointdecorator_1" value="0.2" />
						</SplatterDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_2" index={ColorDecorator.INDEX_MODE_FIXED_COLOR} />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY} label="Intensity" path="pathengine.pointdecorator_2" value="0.9" showInUI="1"/>
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_2" value1="0.5" value2="0.9" />
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS}  path="pathengine.pointdecorator_2" value1="0.25" value2="0.33" />
							<parameter id={ColorDecorator.PARAMETER_NR_SMOOTH_FACTOR}  path="pathengine.pointdecorator_2" value1="0.8" value2="1" />
							<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_2" color="0xffffff" showInUI="1"/>
						</ColorDecorator>
						<BumpDecorator>
							<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_3" index={BumpDecorator.INDEX_MODE_SPEED} />
							<parameter id={BumpDecorator.PARAMETER_B_INVERT_MAPPING} path="pathengine.pointdecorator_3" value="1" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS} path="pathengine.pointdecorator_3" previewID={PreviewIconFactory.PREVIEW_DEPTH} value="0.5" minValue="0" maxValue="1" showInUI="1" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS_RANGE} path="pathengine.pointdecorator_3" value="0.5"/>
						</BumpDecorator>
						<CircularRotationDecorator active="0">
							<parameter id={CircularRotationDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_4" index="1" />
							<parameter id={CircularRotationDecorator.PARAMETER_I_RANDOM_POINT_COUNT} path="pathengine.pointdecorator_4" value="40" />
							<parameter id={CircularRotationDecorator.PARAMETER_A_ANGLE_ADJUSTMENT} path="pathengine.pointdecorator_4" value="90" />
						</CircularRotationDecorator>
					</pathengine>
				</brush>

				<brush engine={BrushType.SPRAY_CAN} name="Bristle Brush">
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0" />
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="line" />
					<parameter id={AbstractBrush.PARAMETER_N_QUAD_OFFSET_RATIO} path="brush" value="0"/>
					
					<parameterMapping>
						<parameter id="Brush Style" type={PsykoParameter.IconListParameter} label="Style" list="Small,Medium,Large" index="1" showInUI="1"/>
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
							<parameter id={SpawnDecorator.PARAMETER_N_MAXIMUM_OFFSET} path="pathengine.pointdecorator_1"  label="Size" value="16" minValue="0" maxValue="50" showInUI="1"/>
							<parameter id={SpawnDecorator.PARAMETER_N_MINIMUM_OFFSET} path="pathengine.pointdecorator_1" value="1" minValue="0" maxValue="200"/>
							<parameter id={SpawnDecorator.PARAMETER_AR_OFFSET_ANGLE} path="pathengine.pointdecorator_1" value1="-1" value2="1" />
							<parameter id={SpawnDecorator.PARAMETER_AR_BRUSH_ANGLE_VARIATION} path="pathengine.pointdecorator_1" value1="-2" value2="2" />
							<parameter id={SpawnDecorator.PARAMETER_NR_BRISTLE_VARIATION} path="pathengine.pointdecorator_1" value="1"/>
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
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_3" index={ColorDecorator.INDEX_MODE_FIXED_COLOR} />
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS} path="pathengine.pointdecorator_3" value1="0.0005" value2="0.1" />
							<parameter id={ColorDecorator.PARAMETER_SL_PICK_RADIUS_MODE} path="pathengine.pointdecorator_3" index="1" />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY} label="Intensity"  previewID={PreviewIconFactory.PREVIEW_ALPHA} path="pathengine.pointdecorator_3" value="0.75" showInUI="1" />
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_3" value1="0.1" value2="0.3" />
							<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_3" color="0xffffff" showInUI="1"/>
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
				
				<brush engine={BrushType.SKETCH} name="Pencil">
					<parameter id={SketchBrush.PARAMETER_N_SURFACE_INFLUENCE} path="brush" previewID={PreviewIconFactory.PREVIEW_SURFACE_INFLUENCE} value="0.5" showInUI="1"/>
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0" />
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="pencilSketch" />
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
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_1" index={ColorDecorator.INDEX_MODE_FIXED_COLOR} />
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS}  path="pathengine.pointdecorator_1" value1="0.4" value2="0.4" />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY} label="Intensity"  previewID={PreviewIconFactory.PREVIEW_ALPHA} path="pathengine.pointdecorator_1"  minValue="0.25" value="0.7"  showInUI="1" />
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_1" value1="0.1" value2="0.3" />
							<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_1" color="0xffffff" showInUI="1"/>
						</ColorDecorator>
						<SpawnDecorator>
							<parameter id={SpawnDecorator.PARAMETER_SL_OFFSET_MODE} index={SpawnDecorator.INDEX_MODE_PRESSURE_SPEED} path="pathengine.pointdecorator_1" />
							<parameter id={SpawnDecorator.PARAMETER_IR_MULTIPLES} value1="8" value2="8" path="pathengine.pointdecorator_1" />
							<parameter id={SpawnDecorator.PARAMETER_N_MINIMUM_OFFSET} path="pathengine.pointdecorator_2" value="0.5"/>
							
							<parameter id={SpawnDecorator.PARAMETER_N_MAXIMUM_OFFSET} path="pathengine.pointdecorator_2" label="Size" value="12" minValue="1" maxValue="24"  showInUI="1"/>
							<parameter id={SpawnDecorator.PARAMETER_AR_OFFSET_ANGLE} path="pathengine.pointdecorator_2" value1="-1" value2="1" />
							<parameter id={SpawnDecorator.PARAMETER_AR_BRUSH_ANGLE_VARIATION} path="pathengine.pointdecorator_2" value1="-2" value2="2" />
							<parameter id={SpawnDecorator.PARAMETER_NR_BRISTLE_VARIATION} path="pathengine.pointdecorator_2" value="1"/>
						</SpawnDecorator>

					</pathengine>
				</brush>

				<brush engine={BrushType.SPRAY_CAN} name="Eraser">
					<parameter id={AbstractBrush.PARAMETER_NR_SIZE_FACTOR} path="brush" value1="0" value2="1"/>
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0"/>
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="splotch,basic smooth,splat,basic,noisy" showInUI="1"/>
					<parameter id={AbstractBrush.PARAMETER_SL_BLEND_MODE} path="brush" index="1"/>
					<parameterMapping>
						<parameter id="Brush Style" type={PsykoParameter.IconListParameter} label="Style" previewID={PreviewIconFactory.PREVIEW_ERASER_STYLE} list="Color & Relief, Color Only, Relief Only" showInUI="1"/>
						<proxy type={PsykoParameterProxy.TYPE_DECORATOR_ACTIVATION} src="Brush Style" 
							target="pathengine.pointdecorator_2" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="0,2"/>
						<proxy type={PsykoParameterProxy.TYPE_DECORATOR_ACTIVATION} src="Brush Style" 
							target="pathengine.pointdecorator_1" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="0,1"/>

						<parameter id="Strength" type={PsykoParameter.NumberParameter} value="0.5" minValue="0" maxValue="1" showInUI="1"/>
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} src="Strength" 
							target="pathengine.pointdecorator_1.Opacity" 
							targetMappings="0"
							targetOffsets="0"
							targetFactors="0.05"
							targetProperties="value"/>	
						
					</parameterMapping>
					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MODE_FIXED} />
							<parameter id={SizeDecorator.PARAMETER_N_FACTOR} path="pathengine.pointdecorator_0" label="Size" value="0.55" minValue="0" maxValue="1" showInUI="1"/>
							<parameter id={SizeDecorator.PARAMETER_N_RANGE} path="pathengine.pointdecorator_0" label="Range" value="0.15" minValue="0" maxValue="1" />
						</SizeDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_1" index={ColorDecorator.INDEX_MODE_FIXED_COLOR} />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY} label="Strength" value="0.07"  path="pathengine.pointdecorator_1" />
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY_RANGE} value="0"  path="pathengine.pointdecorator_1" />
							<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_1" color="0xffffffff" />
						</ColorDecorator>
						<BumpDecorator>
							<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_2" index={BumpDecorator.INDEX_MODE_FIXED} />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS} path="pathengine.pointdecorator_2" value="0"/>
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS_RANGE} path="pathengine.pointdecorator_2" value="0"/>
							<parameter id={BumpDecorator.PARAMETER_N_SHININESS} path="pathengine.pointdecorator_2" value="0" />
							<parameter id={BumpDecorator.PARAMETER_N_GLOSSINESS} path="pathengine.pointdecorator_2" value="0" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE} label="Depth Removal" path="pathengine.pointdecorator_2" value="1" minValue="0" maxValue="1" showInUI="1"/>
						</BumpDecorator>
					</pathengine>
				</brush>

				<!--<brush engine={BrushType.WATER_DAMAGE} name="Water Damage">
					<parameter id={WaterDamageBrush.PARAMETER_N_SURFACE_INFLUENCE} previewID={PreviewIconFactory.PREVIEW_SURFACE_INFLUENCE} path="brush" value="0.5" showInUI="1"/>
					<parameter id={WaterDamageBrush.PARAMETER_N_PIGMENT_FLOW} path="brush" value="0.25" showInUI="1"/>
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES}  path="brush" index="0" list="wet" showInUI="0"/>
					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}/>
				</brush>-->

		</brushkits>;
		*/
	}
}