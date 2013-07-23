package net.psykosoft.psykopaint2.paint.configuration
{
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterProxy;
	import net.psykosoft.psykopaint2.core.drawing.paths.AbstractPathEngine;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.CircularRotationDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;

	public class BrushKitDefaultSet
	{
		public static const brushKitData:XML = 
			<brushkits>
			<!--
				<brush engine={BrushType.SPRAY_CAN} name="Sample Test">
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="dot"/>
					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
					</pathengine>
				</brush>
			-->
				<brush engine={BrushType.SPRAY_CAN} name="Spray Can">
					<parameter id={AbstractBrush.PARAMETER_NR_SIZE_FACTOR} path="brush" value1="0" value2="1" />
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0"/>
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="splat,splotch,noisy"/>

					<parameterMapping>
						<parameter id="Style" type={PsykoParameter.IconListParameter} label="Style" list="Fat Brush,Speed Brush,Van Gogh,Sprinkle,Smear Brush" showInUI="1"/>
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
							target="pathengine.pointdecorator_1.Color Blending" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="0,1,2,3"
							value1="0.5" value2="0.9"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="pathengine.pointdecorator_1.Color Blending" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="4"
							value1="0.0001" value2="0.001"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="pathengine.pointdecorator_2.Splat Factor" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="0,1,2,3"
							value="40"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} 
							src="Style" 
							target="pathengine.pointdecorator_2.Splat Factor" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="4"
							value="10"/>	
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

						<parameter id="Custom Color" type={PsykoParameter.BooleanParameter}  value="0" showInUI="1"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} src="Custom Color" 
							target="pathengine.pointdecorator_1.Color Mode" 
							condition={PsykoParameterProxy.CONDITION_TRUE }
							
							index={ColorDecorator.INDEX_MODE_FIXED_COLOR}/>	
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} src="Custom Color" 
							target="pathengine.pointdecorator_1.Color Mode" 
							condition={PsykoParameterProxy.CONDITION_FALSE }
							
							index={ColorDecorator.INDEX_MODE_PICK_COLOR}/>	
						
					</parameterMapping>

					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
					<parameter id={AbstractPathEngine.PARAMETER_SPEED_SMOOTHING} path="pathengine" value="0.02" />
						
						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MODE_PRESSURE_SPEED} />
							<parameter id={SizeDecorator.PARAMETER_NR_FACTOR} path="pathengine.pointdecorator_0" label="Size" value1="0.47" value2="0.5" minValue="0" maxValue="1" showInUI="1"/>
							<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MAPPING_CIRCQUAD}/>
						</SizeDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_1" index={ColorDecorator.INDEX_MODE_PICK_COLOR} />
							<parameter id={ColorDecorator.PARAMETER_NR_OPACITY} label="Intensity" path="pathengine.pointdecorator_1" showInUI="1"/>
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_1" value1="0.5" value2="0.9" />
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS}  path="pathengine.pointdecorator_1" value1="0.25" value2="0.33" />
							<parameter id={ColorDecorator.PARAMETER_NR_SMOOTH_FACTOR}  path="pathengine.pointdecorator_1" value1="0.8" value2="1" />
							<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_1" color="0xffffff" showInUI="1"/>
						</ColorDecorator>
						<SplatterDecorator>
							<parameter id={SplatterDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_2" index={SplatterDecorator.INDEX_MODE_PRESSURE_SPEED} />
							<parameter id={SplatterDecorator.PARAMETER_SL_OFFSET_MAPPING} path="pathengine.pointdecorator_2" index="1"  />
							<parameter id={SplatterDecorator.PARAMETER_N_SPLAT_FACTOR}  path="pathengine.pointdecorator_2" value="40" />
							<parameter id={SplatterDecorator.PARAMETER_N_MINIMUM_OFFSET} path="pathengine.pointdecorator_2" value="0" />
							<parameter id={SplatterDecorator.PARAMETER_A_OFFSET_ANGLE_RANGE} path="pathengine.pointdecorator_2" value="15" />
							<parameter id={SplatterDecorator.PARAMETER_N_SIZE_FACTOR} path="pathengine.pointdecorator_2" value="0.2" />
						</SplatterDecorator>
						<BumpDecorator>
							<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_3" index={BumpDecorator.INDEX_MODE_SPEED} />
							<parameter id={BumpDecorator.PARAMETER_B_INVERT_MAPPING} path="pathengine.pointdecorator_3" value="1" />
							<parameter id={BumpDecorator.PARAMETER_NR_BUMPINESS} path="pathengine.pointdecorator_3" value1="0" value2="1" minValue="0" maxValue="1" showInUI="1" />
						</BumpDecorator>
						<CircularRotationDecorator active="0">
							<parameter id={CircularRotationDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_4" index="1" />
							<parameter id={CircularRotationDecorator.PARAMETER_I_RANDOM_POINT_COUNT} path="pathengine.pointdecorator_4" value="40" />
							<parameter id={CircularRotationDecorator.PARAMETER_A_ANGLE_ADJUSTMENT} path="pathengine.pointdecorator_4" value="90" />
						</CircularRotationDecorator>
					</pathengine>
				</brush>


				<brush engine={BrushType.SPRAY_CAN} name="Paint Brush">
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0" />
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="line" />
					<parameterMapping>
						<parameter id="Brush Style" type={PsykoParameter.IconListParameter} label="Style" list="Small,Medium,Large" index="1" showInUI="1"/>
						<proxy type={PsykoParameterProxy.TYPE_DECORATOR_ACTIVATION} src="Brush Style" 
							target="pathengine.pointdecorator_4" 
							condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
							indices="1"/>
						

						<parameter id="Custom Color" type={PsykoParameter.BooleanParameter}  value="0" showInUI="1"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} src="Custom Color" 
							target="pathengine.pointdecorator_3.Color Mode" 
							condition={PsykoParameterProxy.CONDITION_TRUE }
							index={ColorDecorator.INDEX_MODE_FIXED_COLOR}/>	
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} src="Custom Color" 
							target="pathengine.pointdecorator_3.Color Mode" 
							condition={PsykoParameterProxy.CONDITION_FALSE }
							index={ColorDecorator.INDEX_MODE_PICK_COLOR}/>	
					</parameterMapping>

					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
						<parameter id={AbstractPathEngine.PARAMETER_SEND_TAPS} path="pathengine" value="0" />
						<parameter id={AbstractPathEngine.PARAMETER_SPEED_SMOOTHING} path="pathengine" value="0.02" />
						<parameter id={AbstractPathEngine.PARAMETER_OUTPUT_STEP} path="pathengine" value="4" />
					
						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} index={SizeDecorator.INDEX_MODE_SPEED} path="pathengine.pointdecorator_1" />
							<parameter id={SizeDecorator.PARAMETER_NR_FACTOR} label="Size" value1="0.3" value2="0.8" minValue="0" maxValue="2" showInUI="1" path="pathengine.pointdecorator_1" />
							<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} index="2" path="pathengine.pointdecorator_1"/>
						</SizeDecorator>
						<SpawnDecorator>
							<parameter id={SpawnDecorator.PARAMETER_SL_OFFSET_MODE} index={SpawnDecorator.INDEX_MODE_PRESSURE_SPEED} path="pathengine.pointdecorator_1" />
							<parameter id={SpawnDecorator.PARAMETER_IR_MULTIPLES} value1="8" value2="8" path="pathengine.pointdecorator_1" />
							<parameter id={SpawnDecorator.PARAMETER_N_MAXIMUM_OFFSET} path="pathengine.pointdecorator_1" value="16" minValue="0" maxValue="200"/>
							<parameter id={SpawnDecorator.PARAMETER_AR_OFFSET_ANGLE} path="pathengine.pointdecorator_1" value1="-1" value2="1" />
							<parameter id={SpawnDecorator.PARAMETER_AR_BRUSH_ANGLE_VARIATION} path="pathengine.pointdecorator_1" value1="-2" value2="2" />
							<parameter id={SpawnDecorator.PARAMETER_NR_BRISTLE_VARIATION} path="pathengine.pointdecorator_1" value="1"/>
						</SpawnDecorator>
						<BumpDecorator>
							<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_2" index={BumpDecorator.INDEX_MODE_FIXED} />
							<parameter id={BumpDecorator.PARAMETER_NR_BUMPINESS} path="pathengine.pointdecorator_2" value1="-1" value2="2" />
							<parameter id={BumpDecorator.PARAMETER_N_SHININESS} path="pathengine.pointdecorator_2" value="0.9" />
							<parameter id={BumpDecorator.PARAMETER_N_GLOSSINESS} path="pathengine.pointdecorator_2" value="0.4" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE} path="pathengine.pointdecorator_2" value="0.7" />
						</BumpDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_3" index={ColorDecorator.INDEX_MODE_PICK_COLOR} />
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS} path="pathengine.pointdecorator_3" value1="0.0005" value2="0.1" />
							<parameter id={ColorDecorator.PARAMETER_SL_PICK_RADIUS_MODE} path="pathengine.pointdecorator_3" index="1" />
							<parameter id={ColorDecorator.PARAMETER_NR_OPACITY} label="Intensity" path="pathengine.pointdecorator_3" value1="0.6" value2="0.9" showInUI="1" />
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



				<!-- <brush engine={BrushType.PENCIL} name="Pencil">
					<parameterMapping>
						<parameter id="Custom Color" type={PsykoParameter.BooleanParameter}  value="0" showInUI="1"/>
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} src="Custom Color" 
							target="pathengine.pointdecorator_1.Color Mode" 
							condition={PsykoParameterProxy.CONDITION_TRUE }
							
							index={ColorDecorator.INDEX_MODE_FIXED_COLOR}/>	
						<proxy type={PsykoParameterProxy.TYPE_PARAMETER_CHANGE} src="Custom Color" 
							target="pathengine.pointdecorator_1.Color Mode" 
							condition={PsykoParameterProxy.CONDITION_FALSE }
							
							index={ColorDecorator.INDEX_MODE_PICK_COLOR}/>	
						
						<parameter id="Size" type={PsykoParameter.NumberParameter} value=".3" minValue="0" maxValue="1" showInUI="1"/>
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} src="Size" 
							target="pathengine.pointdecorator_0.Factor" 
							targetMappings="0,0"
							targetOffsets="0,0"
							targetFactors="1,1"
							targetProperties="lowerRangeValue,upperRangeValue"/>	
						
						<parameter id="Intensity" type={PsykoParameter.NumberParameter} value=".4" minValue="0" maxValue="1" showInUI="1"/>
						<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP} src="Intensity" 
							target="pathengine.pointdecorator_1.Opacity" 
							targetMappings="0,0"
							targetOffsets="0,0"
							targetFactors="1,1"
							targetProperties="lowerRangeValue,upperRangeValue"/>	
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
							<parameter id={ColorDecorator.PARAMETER_NR_OPACITY} label="Intensity" path="pathengine.pointdecorator_1" value1=".4" value2=".4" />
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_1" value1="0.7" value2="0.9" />
							<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_1" color="0xffffff" showInUI="1"/>
						
						</ColorDecorator>
					</pathengine>
					<parameter id="Shapes" path="brush" index="0" list="pencil" showInUI="0"/>
				</brush>        -->

				<brush engine={BrushType.SKETCH} name="Pencil">
					<parameter id="Surface influence" path="brush" value="0.5" showInUI="1"/>
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0" />
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="pencilSketch" />

					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
						<parameter id={AbstractPathEngine.PARAMETER_SEND_TAPS} path="pathengine" value="0" />
						<parameter id={AbstractPathEngine.PARAMETER_SPEED_SMOOTHING} path="pathengine" value="0.02" />
						<parameter id={AbstractPathEngine.PARAMETER_OUTPUT_STEP} path="pathengine" value="4" />

						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} index={SizeDecorator.INDEX_MODE_SPEED} path="pathengine.pointdecorator_1" />
							<parameter id={SizeDecorator.PARAMETER_NR_FACTOR} label="Size" value1="0.3" value2="0.8" minValue="0" maxValue="2" showInUI="1" path="pathengine.pointdecorator_1" />
							<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} index="2" path="pathengine.pointdecorator_1"/>
						</SizeDecorator>
						<SpawnDecorator>
							<parameter id={SpawnDecorator.PARAMETER_SL_OFFSET_MODE} index={SpawnDecorator.INDEX_MODE_PRESSURE_SPEED} path="pathengine.pointdecorator_1" />
							<parameter id={SpawnDecorator.PARAMETER_IR_MULTIPLES} value1="8" value2="8" path="pathengine.pointdecorator_1" />
							<parameter id={SpawnDecorator.PARAMETER_N_MAXIMUM_OFFSET} path="pathengine.pointdecorator_1" value="8" minValue="0" maxValue="200"/>
							<parameter id={SpawnDecorator.PARAMETER_AR_OFFSET_ANGLE} path="pathengine.pointdecorator_1" value1="-1" value2="1" />
							<parameter id={SpawnDecorator.PARAMETER_AR_BRUSH_ANGLE_VARIATION} path="pathengine.pointdecorator_1" value1="-2" value2="2" />
							<parameter id={SpawnDecorator.PARAMETER_NR_BRISTLE_VARIATION} path="pathengine.pointdecorator_1" value="1"/>
						</SpawnDecorator>
						<BumpDecorator>
							<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_2" index={BumpDecorator.INDEX_MODE_FIXED} />
							<parameter id={BumpDecorator.PARAMETER_NR_BUMPINESS} path="pathengine.pointdecorator_2" value1="-1" value2="2" />
							<parameter id={BumpDecorator.PARAMETER_N_SHININESS} path="pathengine.pointdecorator_2" value="0.9" />
							<parameter id={BumpDecorator.PARAMETER_N_GLOSSINESS} path="pathengine.pointdecorator_2" value="0.4" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE} path="pathengine.pointdecorator_2" value="0.7" />
						</BumpDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_3" index={ColorDecorator.INDEX_MODE_PICK_COLOR} />
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS}  path="pathengine.pointdecorator_3" value1="0.4" value2="0.4" />
							<parameter id={ColorDecorator.PARAMETER_NR_OPACITY} label="Intensity" path="pathengine.pointdecorator_3" value1="0.1" value2="0.2" showInUI="1" />
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_3" value1="0.1" value2="0.3" />
							<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_3" color="0xffffff" showInUI="1"/>
						</ColorDecorator>

					</pathengine>
				</brush>


				<brush engine={BrushType.WATER_COLOR} name="Water Color">
					<parameter id="Surface influence" path="brush" value="0.5" showInUI="1"/>
					<parameter id="Pigment staining" path="brush" value=".5" showInUI="1"/>
					<parameter id="Pigment granulation" path="brush" value=".3" showInUI="1"/>
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES}  path="brush" index="0" list="wet,basic" showInUI="1"/>
					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}/>
				</brush>

				<brush engine={BrushType.SPRAY_CAN} name="Eraser">
					<parameter id={AbstractBrush.PARAMETER_NR_SIZE_FACTOR} path="brush" value1="0" value2="1"/>
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0"/>
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="splotch,basic smooth,splat,basic,noisy" showInUI="1"/>
					<parameter id={AbstractBrush.PARAMETER_SL_BLEND_MODE} path="brush" index="1"/>
					<parameterMapping>
						<parameter id="Brush Style" type={PsykoParameter.IconListParameter} label="Style" list="Color & Relief, Color Only, Relief Only" showInUI="1"/>
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
							targetMappings="0,0"
							targetOffsets="0,0"
							targetFactors="0.05,0.05"
							targetProperties="lowerRangeValue,upperRangeValue"/>	
						
					</parameterMapping>
					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MODE_FIXED} />
							<parameter id={SizeDecorator.PARAMETER_NR_FACTOR} path="pathengine.pointdecorator_0" label="Size" value1="0.4" value2="0.7" minValue="0" maxValue="1" showInUI="1" />
							<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} path="pathengine.pointdecorator_0" index="1"/>
						</SizeDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_1" index={ColorDecorator.INDEX_MODE_FIXED_COLOR} />
							<parameter id={ColorDecorator.PARAMETER_NR_OPACITY} label="Strength" value1="0.07" value2="0.07"  path="pathengine.pointdecorator_1" />
							<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_1" color="0xffffffff" />
						</ColorDecorator>
						<BumpDecorator>
							<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_2" index={BumpDecorator.INDEX_MODE_FIXED} />
							<parameter id={BumpDecorator.PARAMETER_NR_BUMPINESS} path="pathengine.pointdecorator_2" value1="0" value2="0" />
							<parameter id={BumpDecorator.PARAMETER_N_SHININESS} path="pathengine.pointdecorator_2" value="0" />
							<parameter id={BumpDecorator.PARAMETER_N_GLOSSINESS} path="pathengine.pointdecorator_2" value="0" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE} label="Depth Removal" path="pathengine.pointdecorator_2" value="1" minValue="0" maxValue="1" showInUI="1"/>
						</BumpDecorator>
					</pathengine>
				</brush>
				
		</brushkits>	
	/*
		public static const brushKitData:XML = 
			<brushkits>
			<brush engine={BrushType.SPRAY_CAN} name="Gravure Pen">
			<parameter id="Shapes" path="brush" index="0" list="sphere,splat,splotch,line,basic,noisy" showInUI="1"/>
			<parameter id={AbstractBrush.PARAMETER_N_BUMPYNESS} path="brush" value="0"/>
			
			<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
			<SizeDecorator>
			<parameter id="Mode" path="pathengine.pointdecorator_0" index="1" />
			<parameter id="Factor" path="pathengine.pointdecorator_0" value1="0" value2="0.4" minValue="0" maxValue="1" showInUI="1"/>
			</SizeDecorator>
			<ColorDecorator>
			<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_2" index="1" />
			<parameter id={ColorDecorator.PARAMETER_IL_COLOR}  path="pathengine.pointdecorator_2" index="1" />
			<parameter id={ColorDecorator.PARAMETER_NR_OPACITY}  path="pathengine.pointdecorator_2" value1="1" value2="1" />
			</ColorDecorator>
			<ConditionalDecorator>
			<!-- if pen button 1 pressed -->
			<parameter id={ConditionalDecorator.PARAMETER_SL_TEST_PROPERTY}  path="pathengine.pointdecorator_3" index={ConditionalDecorator.PROPERTY_INDEX_PEN_BUTTON_1} />
			</ConditionalDecorator>
			<BumpDecorator>
			<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_4" index="3" />
			<parameter id={BumpDecorator.PARAMETER_NR_BUMPYNESS} path="pathengine.pointdecorator_4" value1="0" value2="4"/>
			<parameter id={BumpDecorator.PARAMETER_N_GLOSSINESS} path="pathengine.pointdecorator_4"  value="0.5" />
			<parameter id={BumpDecorator.PARAMETER_N_SHININESS} path="pathengine.pointdecorator_4"  value="0.5" />
			<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE} path="pathengine.pointdecorator_4"  value="0.6" />
			</BumpDecorator>
			<EndConditionalDecorator/>
			<BumpDecorator>
			<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_6" index="3" />
			<parameter id={BumpDecorator.PARAMETER_NR_BUMPYNESS} path="pathengine.pointdecorator_6" value1="-4" value2="0" />
			<parameter id={BumpDecorator.PARAMETER_N_GLOSSINESS} path="pathengine.pointdecorator_6"  value="0.5" />
			<parameter id={BumpDecorator.PARAMETER_B_INVERT_MAPPING} path="pathengine.pointdecorator_6"  value="1" />
			<parameter id={BumpDecorator.PARAMETER_N_SHININESS} path="pathengine.pointdecorator_6"  value="0.5" />
			<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE} path="pathengine.pointdecorator_6"  value="0.6" />
			</BumpDecorator>
			<EndConditionalDecorator/>
			</pathengine>
			</brush>
				<brush engine={BrushType.WATER_DAMAGE} name="Water Damage">
					<parameter id="Surface influence" path="brush" value="0.5" showInUI="1"/>
					<parameter id="Pigment flow" path="brush" value="0.5" showInUI="1"/>
					<parameter id="Pigment bleaching" path="brush" value="0.07" showInUI="1"/>
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES}  path="brush" index="0" list="wet" showInUI="0"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}/>
				</brush>
				
				<brush engine={BrushType.SPRAY_CAN} name="Gravity Spray">
					<parameter id="Shapes" path="brush" index="0" list="noisy"/>
					<parameter id={AbstractBrush.PARAMETER_N_BUMPYNESS} path="brush" value="0.12" showInUI="1"/>
					
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<SizeDecorator>
							<!-- Mapping drawing speed to size -->
							<parameter id="Mode"  path="pathengine.pointdecorator_0" index="1" />
							<parameter id="Factor"  path="pathengine.pointdecorator_0" value1="0.01" value2="0.05"/>
							<parameter id="Mapping" path="pathengine.pointdecorator_0" value="2" />
						</SizeDecorator>
						<StationaryDecorator>
							<!-- if not moving for 150ms start splattering around current position -->
							<parameter id="Delay"  path="pathengine.pointdecorator_1" value="150"  />
							<parameter id="Size"  path="pathengine.pointdecorator_1" value1="0.1" value2="0.3"  />
							<parameter id="Maximum Offset"  path="pathengine.pointdecorator_1" value="30" />
						</StationaryDecorator>
						<ColorDecorator>
							<!-- pick color at current point -->
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_2" index="0" />
						</ColorDecorator>
						<SplatterDecorator>
							<!-- randomize position -->
							<parameter id="Splat Factor"  path="pathengine.pointdecorator_3" value="2" />
							<parameter id="Minimum Offset" path="pathengine.pointdecorator_3" value="1" />
							<parameter id="Offset Angle Range" path="pathengine.pointdecorator_3" value="360" />
						</SplatterDecorator>
						<ConditionalDecorator>
							<!-- if speed < 0.1 add dripping particles -->
							<parameter id="Test Property"  path="pathengine.pointdecorator_4" index="0" />
							<parameter id="Speed Threshold"  path="pathengine.pointdecorator_4" value="0.15" showInUI="1"/>
						</ConditionalDecorator>
						<SizeDecorator>
							<parameter id="Mode"  path="pathengine.pointdecorator_5" index="0" />
							<parameter id="Factor" path="pathengine.pointdecorator_5" value1="0.02" value2="0.15"/>
						</SizeDecorator>
						<ParticleDecorator>
							<parameter id="Use Accelerometer"  path="pathengine.pointdecorator_6" value={1} />
							<parameter id="Curl Angle"  path="pathengine.pointdecorator_6" value={0} />
							<parameter id="Lifespan"  path="pathengine.pointdecorator_6" value1={150} value2={500}/>
							<parameter id="Render Steps per Frame" path="pathengine.pointdecorator_6" value={10}/>
							<parameter id="Update Probability" path="pathengine.pointdecorator_6" value1={1} value2={1}/>
							<parameter id="Spawn Probability" path="pathengine.pointdecorator_6" value={0.3}/>
							<parameter id="Minimum Spawn Distance" path="pathengine.pointdecorator_6" value={0}/>
							<parameter id="Max Concurrent Particles" path="pathengine.pointdecorator_6" value={20}/>
						</ParticleDecorator>
						<EndConditionalDecorator/>
						<EndConditionalDecorator/>
					</pathengine>
				</brush>
				<brush engine={BrushType.SPRAY_CAN} name="Tree Brush">
					<parameter id="Shapes" path="brush" index="0" list="inkdots1,test,splat,line,noisy" showInUI="1"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_0" index="0" />
						</ColorDecorator>
						<ConditionalDecorator>
							<parameter id="Test Property"  path="pathengine.pointdecorator_1" index="0" />
							<parameter id="Speed Threshold"  path="pathengine.pointdecorator_1" value="0.75" showInUI="1"/>
						</ConditionalDecorator>
						<EndConditionalDecorator/>
							<ParticleDecorator>
								<parameter id="Lifespan"  path="pathengine.pointdecorator_3" value1={50} value2={200}/>
								<parameter id="Render Steps per Frame" path="pathengine.pointdecorator_3" value={4}/>
								<parameter id="Update Probability" path="pathengine.pointdecorator_3" value1={1} value2={1}/>
								<parameter id="Spawn Probability" path="pathengine.pointdecorator_3" value={0.2}/>
								<parameter id="Minimum Spawn Distance" path="pathengine.pointdecorator_3" value={1}/>
								<parameter id="Max Concurrent Particles" path="pathengine.pointdecorator_3" value={20}/>
							</ParticleDecorator>
						<EndConditionalDecorator/>
						<SplatterDecorator>
							<parameter id="Splat Factor"  path="pathengine.pointdecorator_5" value="3" />
							<parameter id="Minimum Offset" path="pathengine.pointdecorator_5" value="1" />
							<parameter id="Offset Angle Range" path="pathengine.pointdecorator_5" value="360" />
						</SplatterDecorator>
						<SizeDecorator>
								<parameter id="Mode"  path="pathengine.pointdecorator_6" index="1"/>
								<parameter id="Factor" path="pathengine.pointdecorator_6" value1="0.01" value2="0.05"/>
								<parameter id="Mapping" path="pathengine.pointdecorator_6" value="2" />
						</SizeDecorator>
					</pathengine>
				</brush>
				<brush engine={BrushType.SPRAY_CAN} name="Precision Test">
					<parameter id={AbstractBrush.PARAMETER_N_BUMPYNESS} path="brush" value="0" />
					<parameter id="Size Factor" path="brush" value1="0" value2="1"/>
					<parameter id="Shapes" path="brush" index="0" list="basic"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<GridDecorator active="0" > 
							<parameter id={GridDecorator.PARAMETER_N_CELL_WIDTH}  path="pathengine.pointdecorator_0" value="64" />
							<parameter id={GridDecorator.PARAMETER_N_CELL_HEIGHT}  path="pathengine.pointdecorator_0" value="64"/>
							<parameter id={GridDecorator.PARAMETER_A_ANGLE_STEP}  path="pathengine.pointdecorator_0" value="0"/>
							<parameter id={GridDecorator.PARAMETER_A_ANGLE_OFFSET}  path="pathengine.pointdecorator_0" value="0" showInUI="1"/>
						</GridDecorator>
						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_1" index="0" />
							<parameter id={SizeDecorator.PARAMETER_NR_FACTOR} path="pathengine.pointdecorator_1" value1="0" value2="1" showInUI="1"/>

						</SizeDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_2" index="0" />
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_2" value1="1" value2="1" showInUI="1" />
							<parameter id={ColorDecorator.PARAMETER_NR_OPACITY}  path="pathengine.pointdecorator_2" value1="1" value2="1" showInUI="1" />
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS}  path="pathengine.pointdecorator_2" value1="1" value2="1" showInUI="1" />
						</ColorDecorator>
					</pathengine>
				</brush>

				<brush engine={BrushType.SPRAY_CAN} name="Pressure Pen">
					<parameter id={AbstractBrush.PARAMETER_N_BUMPYNESS} path="brush" value="0.02" showInUI="1"/>
					<parameter id="Shapes" path="brush" index="0" list="splotch,splat,line,basic,noisy" showInUI="1"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<OrderDecorator>
						</OrderDecorator>
						<SizeDecorator>
							<parameter id="Mode" path="pathengine.pointdecorator_0" index="3" />
							<parameter id="Factor" path="pathengine.pointdecorator_0" value1="0" value2="0.4" minValue="0" maxValue="10" showInUI="1"/>
							<parameter id="Mapping" path="pathengine.pointdecorator_0" value="0" showInUI="1"/>
						</SizeDecorator>
						<ConditionalDecorator>
							<!-- if pen button 1 is pressed -->
							<parameter id="Test Property"  path="pathengine.pointdecorator_1" index="5" />
						</ConditionalDecorator>
						<SpawnDecorator>
							<parameter id="Multiples" value1="3" value2="10" path="pathengine.pointdecorator2" />
							<parameter id="Maximum Offset" path="pathengine.pointdecorator_2" value="16"/>
						</SpawnDecorator>
						<SplatterDecorator>
							<parameter id="Mode" path="pathengine.pointdecorator_3" index="2" />
							<parameter id="Offset Mapping" path="pathengine.pointdecorator_3" value="0" />
							<parameter id="Splat Factor"  path="pathengine.pointdecorator_3" value="40" />
							<parameter id="Minimum Offset" path="pathengine.pointdecorator_3" value="0" />
							<parameter id="Offset Angle Range" path="pathengine.pointdecorator_3" value="180" />
							<parameter id="Size Factor" path="pathengine.pointdecorator_3" value="0.8" />
						</SplatterDecorator>
						<EndConditionalDecorator/>
						<EndConditionalDecorator/>
						<ConditionalDecorator>
							<!-- if pen button 2 is pressed -->
							<parameter id="Test Property"  path="pathengine.pointdecorator_6" index="6" />
						</ConditionalDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_7" index="1" />
						</ColorDecorator>
						<EndConditionalDecorator/>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_8" index="0" />
						</ColorDecorator>
						<EndConditionalDecorator/>
						
					</pathengine>
				</brush>
				<brush engine={BrushType.SHATTER} name="Shatter">
					<parameter id="Shapes" path="brush" index="0" list="splat,splotch,line,basic" showInUI="1"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<parameter id="Output Step Size" path="pathengine" value="3"/>
						<SizeDecorator>
							<!-- Mapping drawing speed to size -->
							<parameter id="Mode"  path="pathengine.pointdecorator_0" index="1" />
							<parameter id="Factor"  path="pathengine.pointdecorator_0" value1="0.0" value2="0.9"/>
							<parameter id="Mapping" path="pathengine.pointdecorator_0" value="2" />
						</SizeDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_1" index="1" />
							<parameter id={ColorDecorator.PARAMETER_NR_OPACITY} path="pathengine.pointdecorator_1" value1="0.5" value2="0.75" showInUI="1"/>
					
						</ColorDecorator>
					</pathengine>
				</brush>
				<brush engine={BrushType.SHATTER} name="Grid Shatter">
					<parameter id="Shapes" path="brush" index="0" list="basic" showInUI="1"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<parameter id="Output Step Size" path="pathengine" value="3"/>
						<SizeDecorator>
							<!-- Mapping drawing speed to size -->
							<parameter id="Mode"  path="pathengine.pointdecorator_0" index="0" />
							<parameter id="Factor"  path="pathengine.pointdecorator_0" value1="1" value2="1"/>
						</SizeDecorator>
						<GridDecorator> 
							<parameter id="Cell Width"  path="pathengine.pointdecorator_1" value="64" />
							<parameter id="Cell Height"  path="pathengine.pointdecorator_1" value="64"/>
							<parameter id="Angle Step"  path="pathengine.pointdecorator_1" value="90"/>
						</GridDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_1" index="1" />
							<parameter id={ColorDecorator.PARAMETER_NR_OPACITY} path="pathengine.pointdecorator_1" value1="0.5" value2="0.75" showInUI="1"/>
						</ColorDecorator>
					</pathengine>
				</brush>
				<brush engine={BrushType.SPRAY_CAN} name="Circular">
					<parameter id="Shapes" path="brush" index="0" list="splat,splotch,line,basic" showInUI="1"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<SizeDecorator>
							<!-- Mapping drawing speed to size -->
							<parameter id="Mode"  path="pathengine.pointdecorator_0" index="1" />
							<parameter id="Factor"  path="pathengine.pointdecorator_0" value1="0.001" value2="0.05"/>
							<parameter id="Mapping" path="pathengine.pointdecorator_0" value="2" />
						</SizeDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_1" index="0" />
						</ColorDecorator>
						<CircularRotationDecorator>
							<parameter id="Angle Adjustment"  path="pathengine.pointdecorator_2" value={90} />
							<centers>
								<point x="0.5" y="0.5"/>
							</centers>
						</CircularRotationDecorator>
					</pathengine>
				</brush>
				<brush engine={BrushType.UNCOLORED_SPRAY_CAN} name="Ink dots">
					<parameter id="Shapes" path="brush" index="0" list="inkdots1,objects" />
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						
						<SpawnDecorator>
							<parameter id="Multiples" value1="1" value2="4" path="pathengine.pointdecorator0" />
							<parameter id="Maximum Offset" path="pathengine.pointdecorator_0" value="16" showInUI="1"/>
							<parameter id="Offset Angle" path="pathengine.pointdecorator_0" value1="-180" value2="180"/>
						</SpawnDecorator>
						<SizeDecorator>
							<!-- Mapping drawing speed to size -->
							<parameter id="Mode"  path="pathengine.pointdecorator_1" index="0" />
							<parameter id="Factor"  path="pathengine.pointdecorator_1" value1="0.001" value2="0.6" showInUI="1"/>
							<parameter id="Mapping" path="pathengine.pointdecorator_1" value="7" showInUI="1"/>
						</SizeDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_2" index="0" />
						</ColorDecorator>
						<!--
						<SplatterDecorator>
							<parameter id="Splat Factor"  path="pathengine.pointdecorator_2" value="2" />
							<parameter id="Minimum Offset"  path="pathengine.pointdecorator_2" value="0" />
							<parameter id="Offset Angle Range" path="pathengine.pointdecorator_2" value="30" />
							<parameter id="Size Factor" path="pathengine.pointdecorator_2" value="0.6" showInUI="1"/>
						</SplatterDecorator>
						-->
					</pathengine>
				</brush>
				<brush engine={BrushType.UNCOLORED_SPRAY_CAN} name="Pointillist">
					<parameter id="Shapes" path="brush" index="0" list="inkdots1" showInUI="0"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<GridDecorator> 
							<parameter id="Cell Width"  path="pathengine.pointdecorator_0" value="8" />
							<parameter id="Cell Height"  path="pathengine.pointdecorator_0" value="8"/>
						</GridDecorator>
						<SizeDecorator>
							<parameter id="Mode"  path="pathengine.pointdecorator_1" index="0" />
							<parameter id="Factor"  path="pathengine.pointdecorator_1" value1="0.1" value2="0.1"/>
						</SizeDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_2" index="0" />
						</ColorDecorator>
						<SpawnDecorator>
							<parameter id="Multiples" value1="4"  value2="12" path="pathengine.pointdecorator_2"/>
							<parameter id="Maximum Offset" path="pathengine.pointdecorator_2" value="16"/>
							<parameter id="Offset Angle" path="pathengine.pointdecorator_1" value1="-180" value2="180"/>
						</SpawnDecorator>
					</pathengine>
				</brush>
				<brush engine={BrushType.RIBBON} name="Ribbon">
					<parameter id="Size Factor" path="brush" value1="0.01" value2="0.05"/>
					<parameter id="Shapes" path="brush" index="0" list="scales" showInUI="0"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<parameter id="Output Step Size" path="pathengine" value="10"  />
						<SizeDecorator>
							<!-- Mapping drawing speed to size -->
							<parameter id="Mode"  path="pathengine.pointdecorator_0" index="1" />
							<parameter id="Factor"  path="pathengine.pointdecorator_0" value1="0" value2="10"  />
							<parameter id="Mapping" path="pathengine.pointdecorator_0" value="2" />
						</SizeDecorator>
					</pathengine>
				</brush>

				<brush engine={BrushType.DELAUNAY} name="Delaunay">
					<parameter id="Size Factor" path="brush" value1="0.1" value2="0.2"/>
					<parameter id="Shapes" path="brush" index="0" list="scales" showInUI="0"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<parameter id="Output Step Size" path="pathengine" value="30"  />
						<SplatterDecorator>
							<parameter id="Splat Factor"  path="pathengine.pointdecorator_0" value="8" />
							<parameter id="Minimum Offset" path="pathengine.pointdecorator_0" value="1" />
						</SplatterDecorator>
					</pathengine>
				</brush>
				
				
			</brushkits>
		*/
		
	}
}