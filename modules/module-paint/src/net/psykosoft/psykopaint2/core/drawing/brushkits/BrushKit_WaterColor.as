package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.WaterColorBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.WaterColorBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterMapping;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterProxy;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;

	public class BrushKit_WaterColor extends BrushKit
	{
		/*
		private static const definitionXML:XML = <brush engine={BrushType.WATER_COLOR} name="Water Color">
			<!--<parameter id={WaterColorBrush.PARAMETER_N_SURFACE_INFLUENCE} path="brush" value="0.75" showInUI="0"/>-->
			<parameter id={WaterColorBrush.PARAMETER_N_PIGMENT_STAINING} type={PsykoParameter.NumberParameter} path="brush" value=".4" />
			<parameter id={WaterColorBrush.PARAMETER_N_PIGMENT_DENSITY} type={PsykoParameter.NumberParameter} path="brush" value=".4" />
			<!--<parameter id={WaterColorBrush.PARAMETER_N_PIGMENT_GRANULATION} path="brush" value="1.5" />-->
			<parameter id={AbstractBrush.PARAMETER_IL_SHAPES}  path="brush" index="0" list="basic,wet" showInUI="0"/>

						<parameterMapping>
							<parameter id="WaterColorSize" showInUI="1" minValue={.03} maxValue="1" value=".77"/>
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
*/

		private static const STYLE_BASIC:int = 0;
		private static const STYLE_WET:int = 1;
		private static const STYLE_DROPS:int = 2;

		private var param_style:PsykoParameter;
		private var param_precision:PsykoParameter;
		private var param_intensity:PsykoParameter;

		
		public function BrushKit_WaterColor()
		{
			init(null);
		}
		
		override protected function init( xml:XML ):void
		{
			if (!_initialized ) BrushKit.init();
			
			name = "Water Color";
			
			brushEngine = new WaterColorBrush();
			WaterColorBrush(brushEngine).param_pigmentStaining.numberValue = 1.0;
			WaterColorBrush(brushEngine).param_pigmentDensity.numberValue = 0.02;
			WaterColorBrush(brushEngine).param_pigmentGranulation.numberValue = .5;
			brushEngine.param_shapes.stringList = Vector.<String>(["basic","wet"]);
			
			var pathManager:PathManager = new PathManager( PathManager.ENGINE_TYPE_EXPERIMENTAL );
			brushEngine.pathManager = pathManager;
			
			_parameterMapping = new PsykoParameterMapping();
			
			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["basic","wet", "paint1"]);
			param_style.showInUI = 0;
			param_style.addEventListener( Event.CHANGE, onStyleChanged );
			_parameterMapping.addParameter(param_style);
			
			param_precision = new PsykoParameter( PsykoParameter.NumberParameter,"Precision",0.77,0,1);
			param_precision.showInUI = 1;
			param_precision.addEventListener( Event.CHANGE, onPrecisionChanged );
			_parameterMapping.addParameter(param_precision);
			
			param_intensity = new PsykoParameter( PsykoParameter.NumberParameter,"Intensity",0.2,0,1);
			param_intensity.showInUI = 2;
			param_intensity.addEventListener( Event.CHANGE, onIntensityChanged );
			_parameterMapping.addParameter(param_intensity);
			
			onStyleChanged(null);
		}
		
		protected function onStyleChanged(event:Event):void
		{
			switch (param_style.index) {
				case STYLE_BASIC:
					setValuesForDryBrush();
					WaterColorBrush(brushEngine).param_meshType.value = 0;
					break;
				case STYLE_WET:
					setValuesForWetBrush();
					WaterColorBrush(brushEngine).param_meshType.value = 0;
					break;
				// needs to be drops
				case STYLE_DROPS:
					setValuesForWetBrush();
					WaterColorBrush(brushEngine).param_meshType.value = 1;
					break;
			}

			onPrecisionChanged(null);
			onIntensityChanged(null);
		}

		private function setValuesForDryBrush():void
		{
			brushEngine.param_shapes.index = 0;
			WaterColorBrush(brushEngine).param_waterViscosity.numberValue = .05;
			WaterColorBrush(brushEngine).param_waterDrag.numberValue = .2;
		}

		private function setValuesForWetBrush():void
		{
			brushEngine.param_shapes.index = 1;
			WaterColorBrush(brushEngine).param_waterViscosity.numberValue = .1;
			WaterColorBrush(brushEngine).param_waterDrag.numberValue = .01;
		}

		protected function onPrecisionChanged(event:Event):void
		{
			var precision:Number = param_precision.numberValue;
			brushEngine.param_sizeFactor.lowerRangeValue = brushEngine.param_sizeFactor.upperRangeValue = precision;
		}
		
		protected function onIntensityChanged(event:Event):void
		{
			WaterColorBrush(brushEngine).param_pigmentDensity.numberValue = 0.1 * param_intensity.numberValue;
		}
	}
}