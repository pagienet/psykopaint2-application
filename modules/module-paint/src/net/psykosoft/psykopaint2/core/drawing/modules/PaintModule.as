package net.psykosoft.psykopaint2.core.drawing.modules
{

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.base.remote.PsykoSocket;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.BrushShapeLibrary;
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleType;
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterProxy;
	import net.psykosoft.psykopaint2.core.drawing.paths.AbstractPathEngine;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.GridDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.managers.pen.WacomPenManager;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyActivateBrushChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyAvailableBrushTypesSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;

	public class PaintModule implements IModule
	{
		[Inject]
		public var renderer : CanvasRenderer;

		[Inject]
		public var canvasModel : CanvasModel;

		[Inject]
		public var canvasHistory : CanvasHistoryModel;

		[Inject]
		public var notifyPaintModuleActivatedSignal : NotifyPaintModuleActivatedSignal;

		[Inject]
		public var brushShapeLibrary : BrushShapeLibrary;

		[Inject]
		public var notifyAvailableBrushTypesSignal:NotifyAvailableBrushTypesSignal;

		[Inject]
		public var notifyActivateBrushChangedSignal:NotifyActivateBrushChangedSignal;

		[Inject]
		public var memoryWarningSignal : NotifyMemoryWarningSignal;

		[Inject]
		public var stage3D : Stage3D;
		
		[Inject]
		public var penManager : WacomPenManager;

		[Inject]
		public var requestChangeRenderRect : RequestChangeRenderRectSignal;
		
		
		private var _view : DisplayObject;

		private var _active : Boolean;
		private var _availableBrushKits:Vector.<BrushKit>;
		private var _availableBrushKitNames:Vector.<String>;
		private var _activeBrushKit : BrushKit;
		private var _activeBrushKitName : String;
		
		private const brushKitData:XML = 
			<brushkits>
				<brush engine={BrushType.WATER_COLOR} name="Water Color">
					<parameter id="Surface influence" path="brush" value="0.5" showInUI="1"/>
					<parameter id="Pigment staining" path="brush" value="5.5" showInUI="1"/>
					<parameter id="Pigment granulation" path="brush" value=".81" showInUI="1"/>
					<parameter id={AbstractBrush.PARAMETER_SHAPES}  path="brush" index="0" list="wet,basic" showInUI="1"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}/>
				</brush>
				<brush engine={BrushType.WATER_DAMAGE} name="Water Damage">
					<parameter id="Surface influence" path="brush" value="0.5" showInUI="1"/>
					<parameter id="Pigment flow" path="brush" value="0.5" showInUI="1"/>
					<parameter id="Pigment bleaching" path="brush" value="0.07" showInUI="1"/>
					<parameter id={AbstractBrush.PARAMETER_SHAPES}  path="brush" index="0" list="wet" showInUI="0"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}/>
				</brush>
				<brush engine={BrushType.PENCIL} name="Pencil">
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_0" index="0" />
						</ColorDecorator>
						<SizeDecorator>
							<parameter id="Mode" path="pathengine.pointdecorator_1" index="1" />
							<parameter id="Factor" path="pathengine.pointdecorator_1" value1=".1" value2=".1" showInUI="1" />
							<parameter id="Mapping" path="pathengine.pointdecorator_1" value="2" />
						</SizeDecorator>
					</pathengine>
					<parameter id="Shapes" path="brush" index="0" list="pencil" showInUI="0"/>
				</brush>
				<brush engine={BrushType.SPRAY_CAN} name="Bristle Brush">
					<parameterMapping>
						<parameter type={PsykoParameter.StringListParameter} path="parameterMapping" id="Condition" index="0" list="Normal, Grid" showInUI="1" />
						<proxy type={PsykoParameterProxy.TYPE_DECORATOR_ACTIVATION} src="Condition" target="pathengine.pointdecorator_2" condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE} index="1" />
					</parameterMapping>
					<parameter id={AbstractBrush.PARAMETER_BUMPYNESS} path="brush" value="0.6" />
					<parameter id="Shapes" path="brush" index="0" list="line,splat,splat3,basic,noisy" />

					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<parameter id="Send Taps" path="pathengine" value="0" />
						<SizeDecorator>
							<parameter id="Mode" path="pathengine.pointdecorator_0" index="1" />
							<parameter id="Factor" path="pathengine.pointdecorator_0" value1="0.1" value2="0.5" minValue="0" maxValue="10" showInUI="1"/>
							<parameter id="Mapping" path="pathengine.pointdecorator_0" value="2"/>
						</SizeDecorator>
						
						<SpawnDecorator>
							<parameter id="Multiples" value1="8" value2="8" path="pathengine.pointdecorator_1" />
							<parameter id="Maximum Offset" path="pathengine.pointdecorator_1" value="16" minValue="0" maxValue="200" showInUI="1"/>
							<parameter id="Offset Angle" path="pathengine.pointdecorator_1" value1="-2" value2="2" showInUI="1"/>
							<parameter id="Brush Angle Variation" path="pathengine.pointdecorator_1" value1="-5" value2="5" showInUI="1"/>
							<parameter id="Bristle Variation" path="pathengine.pointdecorator_1" value="1" showInUI="1"/>
						</SpawnDecorator>
						<GridDecorator active="0"> 
							<parameter id="Cell Width"  path="pathengine.pointdecorator_2" value="32" />
							<parameter id="Cell Height"  path="pathengine.pointdecorator_2" value="32"/>
						</GridDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_3" index="0" />
						</ColorDecorator>
					</pathengine>
				</brush>

				<brush engine={BrushType.SPRAY_CAN} name="Spray Can">
					<parameter id={AbstractBrush.PARAMETER_SIZE_FACTOR} path="brush" value1="0" value2="1" showInUI="1"/>
					<parameter id={AbstractBrush.PARAMETER_BUMPYNESS} path="brush" value="0.25" showInUI="1"/>
					<parameter id={AbstractBrush.PARAMETER_SHAPES} path="brush" index="0" list="splat,splat3,line,basic,noisy" showInUI="1"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<SizeDecorator>
							<parameter id="Mode" path="pathengine.pointdecorator_0" index="1" />
							<parameter id="Factor" path="pathengine.pointdecorator_0" value1="0.05" value2="1" minValue="0" maxValue="1"/>
							<parameter id="Mapping" path="pathengine.pointdecorator_0" index="1" showInUI="1"/>
						</SizeDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_SL_COLOR_MODE}  path="pathengine.pointdecorator_1" index="0" />
							<parameter id={ColorDecorator.PARAMETER_NR_OPACITY}  path="pathengine.pointdecorator_1" showInUI="1"/>
							<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_1" showInUI="1"/>
							<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS}  path="pathengine.pointdecorator_1" value1="0.25" value2="0.33" showInUI="1"/>
							<parameter id={ColorDecorator.PARAMETER_NR_SMOOTH_FACTOR}  path="pathengine.pointdecorator_1" value1="0.8" value2="1" showInUI="1"/>
						</ColorDecorator>
						<OrderDecorator>
						</OrderDecorator>
						<SplatterDecorator>
							<parameter id="Mode" path="pathengine.pointdecorator_3" index="1" />
							<parameter id="Offset Mapping" path="pathengine.pointdecorator_3" value="0"  />
							<parameter id="Splat Factor"  path="pathengine.pointdecorator_3" value="40" />
							<parameter id="Minimum Offset" path="pathengine.pointdecorator_3" value="0" />
							<parameter id="Offset Angle Range" path="pathengine.pointdecorator_3" value="30" />
							<parameter id="Size Factor" path="pathengine.pointdecorator_3" value="0.8" />
						</SplatterDecorator>
						
					</pathengine>
				</brush>
				<brush engine={BrushType.SPRAY_CAN} name="Gravity Spray">
					<parameter id="Shapes" path="brush" index="0" list="noisy"/>
					<parameter id={AbstractBrush.PARAMETER_BUMPYNESS} path="brush" value="0.12" showInUI="1"/>
					
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
					<parameter id={AbstractBrush.PARAMETER_BUMPYNESS} path="brush" value="0" />
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
					<parameter id={AbstractBrush.PARAMETER_BUMPYNESS} path="brush" value="0.02" showInUI="1"/>
					<parameter id="Shapes" path="brush" index="0" list="splat3,splat,line,basic,noisy" showInUI="1"/>
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
					<parameter id="Shapes" path="brush" index="0" list="splat,splat3,line,basic" showInUI="1"/>
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
					<parameter id="Shapes" path="brush" index="0" list="splat,splat3,line,basic" showInUI="1"/>
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

		private var _canvasRect : Rectangle;
		
		
		public function PaintModule()
		{
			super();
			
			for ( var i:int = 0; i < brushKitData.brush.length(); i++ )
			{
				registerBrushKit( BrushKit.fromXML(brushKitData.brush[i]), brushKitData.brush[i].@name);
			}
			/*
			registerBrush( BrushType.WATER_COLOR, WaterColorBrush );
			registerBrush( BrushType.WATER_DAMAGE, WaterDamageBrush );
			registerBrush( BrushType.SPRAY_CAN, SprayCanBrush );
			registerBrush( BrushType.INK_DOTS, UncoloredSprayCanBrush );
			registerBrush( BrushType.POINTILLIST, PointillistBrush );
			registerBrush( BrushType.DELAUNAY, DelaunayBrush );
			registerBrush( BrushType.SHATTER, ShatterBrush );
			*/
		}

		[PostConstruct]
		public function postConstruct() : void
		{
			AbstractBrush.brushShapeLibrary = brushShapeLibrary;
			
			memoryWarningSignal.add(onMemoryWarning);
			requestChangeRenderRect.add(onChangeRenderRect);
		}

		private function onChangeRenderRect(rect : Rectangle) : void
		{
			var scale : Number = rect.height/canvasModel.height;
			var width : Number = canvasModel.width*scale;
			_canvasRect = new Rectangle((canvasModel.width - width) *.5, 0, width, rect.height);
			if (_activeBrushKit)
				_activeBrushKit.canvasRect = _canvasRect;
		}
		
		public function stopAnimations() : void
		{
			if (_activeBrushKit)
				_activeBrushKit.stopProgression();
		}

		public function type():String {
			return ModuleType.PAINT;
		}

		private function initializeDefaultBrushes():void {
			
			notifyAvailableBrushTypesSignal.dispatch( _availableBrushKitNames );
		
		}

		private function registerBrushKit( brushKit:BrushKit, kitName:String ):void {
			if( !_availableBrushKits ) _availableBrushKits = new Vector.<BrushKit>();
			_availableBrushKits.push(brushKit);
			if( !_availableBrushKitNames ) _availableBrushKitNames = new Vector.<String>();
			_availableBrushKitNames.push(kitName);
		}
		
		public function get activeBrushKit() : String
		{
			return _activeBrushKitName;
		}

		public function set activeBrushKit( brushKitName:String ) : void
		{
			
			if (_activeBrushKitName == brushKitName) return;
			if ( _activeBrushKit ) deactivateBrushKit();
			
			_activeBrushKitName = brushKitName;
			_activeBrushKit = _availableBrushKits[ _availableBrushKitNames.indexOf(brushKitName)];
			if (_active) activateBrushKit();
			
			//trace( this, "activating brush kit: " + _activeBrushKitName + ", engine: " + _activeBrushKit.brushEngine + " --------------------" );
			
			notifyActivateBrushChangedSignal.dispatch( _activeBrushKit.getParameterSet( !CoreSettings.SHOW_HIDDEN_BRUSH_PARAMETERS ) );
		}

		
		public function get view() : DisplayObject
		{
			return _view;
		}

		public function set view(view : DisplayObject) : void
		{
			if (_active)
				deactivateBrushKit();

			_view = view;

			if (_active)
				activateBrushKit();
		}

		public function activate(bitmapData : BitmapData) : void
		{
			initializeDefaultBrushes();

			_active = true;
			if ( !_activeBrushKit ) activeBrushKit = _availableBrushKitNames[3];
			activateBrushKit();
			renderer.init(this);
			canvasModel.setSourceBitmapData(bitmapData);
			bitmapData.dispose();
			notifyPaintModuleActivatedSignal.dispatch();
		}

		public function deactivate() : void
		{
			_active = false;
			deactivateBrushKit();
		}

		private function onStrokeStarted(event : Event) : void
		{
			_activeBrushKit.brushEngine.snapShot = canvasHistory.takeSnapshot();
		}

		private function activateBrushKit() : void
		{
			if ( _activeBrushKit )
			{
				_activeBrushKit.canvasRect = _canvasRect;
				_activeBrushKit.activate(_view, stage3D.context3D, canvasModel);
				_activeBrushKit.brushEngine.addEventListener(AbstractBrush.STROKE_STARTED, onStrokeStarted);
				_activeBrushKit.addEventListener( Event.CHANGE, onActiveBrushKitChanged );
			}
		}

		private function deactivateBrushKit() : void
		{
			if ( _activeBrushKit )
			{
				_activeBrushKit.deactivate();
				_activeBrushKit.brushEngine.removeEventListener(AbstractBrush.STROKE_STARTED, onStrokeStarted);
				_activeBrushKit.removeEventListener( Event.CHANGE, onActiveBrushKitChanged );
				_activeBrushKit = null;
				_activeBrushKitName = "";
			}
		}

		private function onActiveBrushKitChanged( event:Event ):void
		{
			notifyActivateBrushChangedSignal.dispatch( _activeBrushKit.getParameterSetAsXML() );
		}
		
		public function getAvailableBrushTypes() : Vector.<String> {
			return _availableBrushKitNames;
		}

		
		public function getCurrentBrushParameters():ParameterSetVO {
			return _activeBrushKit.getParameterSet(!CoreSettings.SHOW_HIDDEN_BRUSH_PARAMETERS );
		}
		
		public function render() : void
		{
			if ( _activeBrushKit ) _activeBrushKit.brushEngine.draw();
			renderer.render();
		}

		private function onMemoryWarning() : void
		{
			PsykoSocket.sendString( '<msg src="PaintModule.onMemoryWarning" />' );
			if (_activeBrushKit)
				_activeBrushKit.brushEngine.freeExpendableMemory();
		}
	}
}