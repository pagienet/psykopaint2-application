package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.brushes.WaterColorBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterMapping;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.AbstractPointDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.CallbackDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.StationaryDecorator;

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

		private static const STYLE_WET:int = 0;
		private static const STYLE_MEDIUM:int = 1;
		private static const STYLE_BASIC:int = 2;
		//private static const STYLE_DRY_DROPS:int = 3;
		//private static const STYLE_WET_DROPS:int = 4;
		private static const STYLE_DAMAGE:int = 4;
		private static const STYLE_DAMAGE_DROPS:int = 6;

		private var param_style:PsykoParameter;
		private var param_precision:PsykoParameter;
		private var param_intensity:PsykoParameter;
		private var splatterDecorator : SplatterDecorator;
		private var sizeDecorator : SizeDecorator;
		private var pathManager:PathManager;

		private static const SPLAT_FACTOR : Number = 200;
		private static const MIN_SPLAT : Number = .01;
		private var callbackDecorator:CallbackDecorator;

		private var _minSplatterChance : Number = .1;
		private var _maxSplatterChance : Number = 1.0;
		private var _splatterSpeedNorm:Number = 40 * CoreSettings.GLOBAL_SCALING;
		private var stationaryDecorator:StationaryDecorator;

		
		public function BrushKit_WaterColor()
		{
			isPurchasable = true;
			init(null);
		}
		
		override protected function init( xml:XML ):void
		{
			if (!_initialized ) BrushKit.init();
			
			name = "Watercolors";
			
			brushEngine = new WaterColorBrush();
			WaterColorBrush(brushEngine).param_pigmentStaining.numberValue = 1.0;
			WaterColorBrush(brushEngine).param_pigmentDensity.numberValue = 0.012;
			WaterColorBrush(brushEngine).param_pigmentGranulation.numberValue = .8;
			brushEngine.param_shapes.stringList = Vector.<String>(["wet2","wet","almost circular hard"]);

			pathManager = new PathManager( PathManager.ENGINE_TYPE_EXPERIMENTAL );
			brushEngine.pathManager = pathManager;

			_parameterMapping = new PsykoParameterMapping();

			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["Wet","Medium","Dry", "Add Water"]);
			param_style.showInUI = 0;
			param_style.addEventListener( Event.CHANGE, onStyleChanged );
			_parameterMapping.addParameter(param_style);
			
			param_precision = new PsykoParameter( PsykoParameter.NumberParameter,"Precision",0.25,0,1);
			param_precision.showInUI = 1;
			param_precision.addEventListener( Event.CHANGE, onPrecisionChanged );
			_parameterMapping.addParameter(param_precision);
			
			param_intensity = new PsykoParameter( PsykoParameter.NumberParameter,"Intensity",0.50,0,1);
			param_intensity.showInUI = 2;
			param_intensity.addEventListener( Event.CHANGE, onIntensityChanged );
			_parameterMapping.addParameter(param_intensity);

			// used for drops
			splatterDecorator = new SplatterDecorator();
			splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SPEED;
			splatterDecorator.param_minOffset.value = MIN_SPLAT*brushEngine.param_sizeFactor.lowerRangeValue;
			splatterDecorator.param_splatFactor.value = SPLAT_FACTOR*brushEngine.param_sizeFactor.lowerRangeValue;
			splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
			splatterDecorator.param_offsetAngleRange.degrees = 360;
			splatterDecorator.param_sizeFactor.numberValue = 0;

			sizeDecorator = new SizeDecorator();
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_SPEED;
			sizeDecorator.param_invertMapping.booleanValue = true;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_EXPONENTIAL_IN;
			sizeDecorator.param_mappingFactor.numberValue = .6;
			sizeDecorator.param_mappingRange.numberValue = .50;
			
			callbackDecorator = new CallbackDecorator( this, processPoints );
			
			
			stationaryDecorator = new StationaryDecorator();
			stationaryDecorator.param_delay.numberValue=0;
			stationaryDecorator.param_maxOffset.numberValue=30;
			stationaryDecorator.param_sizeRange.lowerRangeValue=0.1;
			stationaryDecorator.param_sizeRange.upperRangeValue=0.5;
			
			//BROKEN SO COMMENT IT FOR NOW
			//pathManager.addPointDecorator(stationaryDecorator);
			pathManager.addPointDecorator(callbackDecorator);
			pathManager.addPointDecorator(sizeDecorator);
			pathManager.addPointDecorator(splatterDecorator);
			
			

			onStyleChanged(null);
		}
		
		protected function onStyleChanged(event:Event):void
		{
			//brushEngine.param_shapes.index = 0;
			
			
			switch (param_style.index) {
				case STYLE_BASIC:
					setValuesForDryBrush();
					setValuesForRibbon();
					setValuesForColor();
					break;
				case STYLE_MEDIUM:
					setValuesForWetBrush();
					setValuesForRibbon();
					setValuesForColor();
					break;
				case STYLE_WET:
					setValuesForWetBrush();
					setValuesForRibbon();
					setValuesForColor();
					break;
				/*case STYLE_DRY_DROPS:
					setValuesForDryBrush();
					setValuesForDrops();
					setValuesForColor();
					break;
				case STYLE_WET_DROPS:
					setValuesForWetBrush();
					setValuesForDrops();
					setValuesForColor();
					break;*/
				case STYLE_DAMAGE:
					setValuesForWetBrush();
					setValuesForRibbon();
					setValuesForDamage();
					break;
				case STYLE_DAMAGE_DROPS:
					setValuesForWetBrush();
					setValuesForDrops();
					setValuesForDamage();
					break;
			}

			onPrecisionChanged(null);
			onIntensityChanged(null);
		}

		private function setValuesForColor():void
		{
			WaterColorBrush(brushEngine).param_paintMode.value = 0;
		}

		private function setValuesForDamage():void
		{
			WaterColorBrush(brushEngine).param_paintMode.value = 1;
		}

		private function setValuesForDrops():void
		{
			WaterColorBrush(brushEngine).param_meshType.value = 1;
			splatterDecorator.active = true;
			sizeDecorator.active = true;
			callbackDecorator.active = true;
		}

		private function setValuesForRibbon():void
		{
			WaterColorBrush(brushEngine).param_meshType.value = 0;
			splatterDecorator.active = false;
			sizeDecorator.active = false;
			callbackDecorator.active = false;
		}
		
		

		private function setValuesForDryBrush():void
		{
			brushEngine.param_shapes.index = 2;
			WaterColorBrush(brushEngine).param_waterViscosity.numberValue = .1;
			WaterColorBrush(brushEngine).param_waterDrag.numberValue = .1;
			WaterColorBrush(brushEngine).param_glossiness.numberValue = 0.5;
			WaterColorBrush(brushEngine).param_pigmentStaining.numberValue = 0.9;
			WaterColorBrush(brushEngine).param_pigmentDensity.numberValue = 0.010;
			WaterColorBrush(brushEngine).param_pigmentGranulation.numberValue = .1;
		}
		
		
		private function setValuesForMediumBrush():void
		{
			brushEngine.param_shapes.index = 1;
			
			WaterColorBrush(brushEngine).param_waterViscosity.numberValue = .2;
			WaterColorBrush(brushEngine).param_waterDrag.numberValue = .1;
			WaterColorBrush(brushEngine).param_glossiness.numberValue = 0.4;
			WaterColorBrush(brushEngine).param_pigmentStaining.numberValue = 1.0;
			WaterColorBrush(brushEngine).param_pigmentDensity.numberValue = 0.006;
			WaterColorBrush(brushEngine).param_pigmentGranulation.numberValue = .5;
		}

		private function setValuesForWetBrush():void
		{
			brushEngine.param_shapes.index = 0;

			WaterColorBrush(brushEngine).param_waterViscosity.numberValue = .2;
			WaterColorBrush(brushEngine).param_waterDrag.numberValue = .1;
			WaterColorBrush(brushEngine).param_glossiness.numberValue = 0.8;
			WaterColorBrush(brushEngine).param_pigmentStaining.numberValue = 1.0;
			WaterColorBrush(brushEngine).param_pigmentDensity.numberValue = 0.8;
			WaterColorBrush(brushEngine).param_pigmentGranulation.numberValue = .3;
		}
		
		
		

		protected function onPrecisionChanged(event:Event):void
		{
			var precision:Number = param_precision.numberValue;
			brushEngine.param_sizeFactor.lowerRangeValue = brushEngine.param_sizeFactor.upperRangeValue = 0.02+precision;
			splatterDecorator.param_splatFactor.value = SPLAT_FACTOR*precision;
			splatterDecorator.param_minOffset.value =  MIN_SPLAT*precision;
			
			
			stationaryDecorator.param_delay.numberValue=0;
			stationaryDecorator.param_maxOffset.numberValue=30*precision;
			stationaryDecorator.param_sizeRange.lowerRangeValue=0.2*precision;
			stationaryDecorator.param_sizeRange.upperRangeValue=1*precision;
			
		}
		
		protected function onIntensityChanged(event:Event):void
		{
			//WaterColorBrush(brushEngine).param_pigmentDensity.numberValue = 0.07 * param_intensity.numberValue;
			WaterColorBrush(brushEngine).param_pigmentDensity.numberValue = 0.01 + 0.1 * param_intensity.numberValue;
			WaterColorBrush(brushEngine).param_damageFlow.numberValue = .1 + 0.3 * param_intensity.numberValue;
			
		}
		
		protected function processPoints(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var splatterRange : Number = _maxSplatterChance - _minSplatterChance;
			for ( var i:int = points.length; --i > -1; )
			{
				var chance : Number = _minSplatterChance + points[i].speed * splatterRange / _splatterSpeedNorm;
				//trace (chance);
				if ( Math.random() > chance )
				{
					PathManager.recycleSamplePoint( points.splice(i,1)[0] );
				}
			}
			
			return points;
		}
	}
}