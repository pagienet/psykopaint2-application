package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.brushes.SprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.WaterColorBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AlmostCircularHardShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.EraserBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.WetBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.WetBrushShape2;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterMapping;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.AbstractPointDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.CallbackDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.StationaryDecorator;
	import net.psykosoft.psykopaint2.core.managers.purchase.InAppPurchaseManager;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;

	public class BrushKit_WaterColor extends BrushKit
	{
		private static const STYLE_WET:int = 0;
		private static const STYLE_MEDIUM:int = 1;
		private static const STYLE_BASIC:int = 2;
		private static const STYLE_DAMAGE:int = 3;
		private static const STYLE_DAMAGE_DROPS:int = 4;

		private var param_style:PsykoParameter;
		private var param_precision:PsykoParameter;
		private var param_intensity:PsykoParameter;
		private var splatterDecorator : SplatterDecorator;
		private var stationaryDecorator:StationaryDecorator;
		private var spawnDecorator:SpawnDecorator;

		private var sizeDecorator : SizeDecorator;
		private var pathManager:PathManager;

		private static const SPLAT_FACTOR : Number = 200;
		private static const MIN_SPLAT : Number = .01;
		private var callbackDecorator:CallbackDecorator;

		private var _minSplatterChance : Number = .1;
		private var _maxSplatterChance : Number = 1.0;
		private var _splatterSpeedNorm:Number = 40 * CoreSettings.GLOBAL_SCALING;
		private var precision:Number;

		
		public function BrushKit_WaterColor()
		{
			//isPurchasable = true;
			purchasePackages.push(InAppPurchaseManager.PRODUCT_ID_BRUSHKIT1, InAppPurchaseManager.PRODUCT_ID_WATERCOLOR_BRUSH_1);
			purchaseIconID = ButtonIconType.BUY_WATERCOLOR;
			init(null);
		}
		
		override protected function init( xml:XML ):void
		{
			if (!_initialized ) BrushKit.init();
			
			name = "Watercolors";
			
			brushEngine = new WaterColorBrush();
			//pigment staining controls the interaction between absorbed paint in the paper and non-absorbed paint
			//you should only change those by tiny amounts or you get the overabsorption currently showing
			WaterColorBrush(brushEngine).param_pigmentStaining.numberValue = 1.0;
			WaterColorBrush(brushEngine).param_pigmentDensity.numberValue = 0.006;
			//granulation controls how much the paint tend to settle in lower regions of the paper
			WaterColorBrush(brushEngine).param_pigmentGranulation.numberValue = .1;
			WaterColorBrush(brushEngine).param_gravityStrength.numberValue=0.3;
			WaterColorBrush(brushEngine).param_surfaceRelief.numberValue=0.9;
			
			brushEngine.param_shapes.stringList = Vector.<String>([WetBrushShape2.NAME,WetBrushShape.NAME,AlmostCircularHardShape.NAME]);

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
			
			param_intensity = new PsykoParameter( PsykoParameter.NumberParameter,"Intensity",0.90,0,1);
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
			
			
			spawnDecorator = new SpawnDecorator();
			spawnDecorator.param_multiples.lowerRangeValue = 2;
			spawnDecorator.param_multiples.upperRangeValue = 5;
			spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_RANDOM;
			spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_RANDOM;
			spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
			spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
			spawnDecorator.param_maxSize.numberValue = 0.5;
			spawnDecorator.param_minOffset.numberValue = 1;
			spawnDecorator.param_maxOffset.numberValue = 5;
			spawnDecorator.param_sizeMappingFunction.numberValue =AbstractPointDecorator.INDEX_MAPPING_EXPONENTIAL_IN;
			spawnDecorator.param_sizeFactor.numberValue = 0.2;
			

			sizeDecorator = new SizeDecorator();
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_SPEED;
			sizeDecorator.param_invertMapping.booleanValue = true;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_EXPONENTIAL_IN;
			sizeDecorator.param_mappingFactor.numberValue = .6;
			sizeDecorator.param_mappingRange.numberValue = .50;
			
			callbackDecorator = new CallbackDecorator( this, processPoints );
			
			
			stationaryDecorator = new StationaryDecorator();
			stationaryDecorator.param_delay.numberValue=10;
			stationaryDecorator.param_maxOffset.numberValue=30;
			stationaryDecorator.param_sizeRange.lowerRangeValue=0.1;
			stationaryDecorator.param_sizeRange.upperRangeValue=0.5;
			
			//BROKEN SO COMMENT IT FOR NOW
			//pathManager.addPointDecorator(stationaryDecorator);
			pathManager.addPointDecorator(callbackDecorator);
			pathManager.addPointDecorator(sizeDecorator);
			pathManager.addPointDecorator(spawnDecorator);
			pathManager.addPointDecorator(splatterDecorator);
			
			

			onStyleChanged(null);
		}
		
		protected function onStyleChanged(event:Event):void
		{
			//brushEngine.param_shapes.index = 0;
			spawnDecorator.active=false;
			
			switch (param_style.index) {
				case STYLE_BASIC:
					setValuesForDryBrush();
					setValuesForRibbon();
					setValuesForColor();
					break;
				case STYLE_MEDIUM:
					spawnDecorator.active=true;
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
			//HOW EASILY THE PAINT MOVES THROUGH THE FLUID
			WaterColorBrush(brushEngine).param_waterViscosity.numberValue = .2;
			//DRAG IS HOW MUCH FRICTION THE WATER HAVE
			WaterColorBrush(brushEngine).param_waterDrag.numberValue = .1;
			WaterColorBrush(brushEngine).param_glossiness.numberValue = 0.5;
			//pigment staining controls the interaction between absorbed paint in the paper and non-absorbed paint
			//you should only change those by tiny amounts or you get the overabsorption currently showing
			//WaterColorBrush(brushEngine).param_pigmentStaining.numberValue = 0.9;
			//WaterColorBrush(brushEngine).param_pigmentDensity.numberValue = 0.010;
			//granulation controls how much the paint tend to settle in lower regions of the paper
			//WaterColorBrush(brushEngine).param_pigmentGranulation.numberValue = .1;
			//WaterColorBrush(brushEngine).param_damageFlow.numberValue = .1 + 0.3 * param_intensity.numberValue;

		}
		
		
		private function setValuesForMediumBrush():void
		{
			brushEngine.param_shapes.index = 1;
			
			WaterColorBrush(brushEngine).param_waterViscosity.numberValue = .2;
			WaterColorBrush(brushEngine).param_waterDrag.numberValue = .1;
			WaterColorBrush(brushEngine).param_glossiness.numberValue = 0.8;
			//WaterColorBrush(brushEngine).param_pigmentStaining.numberValue = 1.0;
			//WaterColorBrush(brushEngine).param_pigmentDensity.numberValue = 0.013;
			//WaterColorBrush(brushEngine).param_pigmentGranulation.numberValue = .8;
			//WaterColorBrush(brushEngine).param_damageFlow.numberValue = .1;

		}

		private function setValuesForWetBrush():void
		{
			brushEngine.param_shapes.index = 0;

			WaterColorBrush(brushEngine).param_waterViscosity.numberValue = .2;
			WaterColorBrush(brushEngine).param_waterDrag.numberValue = .1;
			WaterColorBrush(brushEngine).param_glossiness.numberValue = 0.8;
			//WaterColorBrush(brushEngine).param_pigmentStaining.numberValue = 1.0;
			//WaterColorBrush(brushEngine).param_pigmentDensity.numberValue = 0.013;
			//WaterColorBrush(brushEngine).param_pigmentGranulation.numberValue = .3;
			//WaterColorBrush(brushEngine).param_damageFlow.numberValue = .1 + 0.3 * param_intensity.numberValue;

		}
		
		
		

		protected function onPrecisionChanged(event:Event):void
		{
			precision = param_precision.numberValue;
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
			WaterColorBrush(brushEngine).param_pigmentDensity.numberValue = 0.07 * param_intensity.numberValue;
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
		
		override public function set eraserMode( enabled:Boolean ):void
		{
			super.eraserMode = (enabled);
			
			if ( enabled )
			{
				onPrecisionChanged(null);
				onIntensityChanged(null);
				
				
				brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.4 + precision  *4;
				
				
				//it's a good idea to put the eraser shape always as the last element into the shapes list
				//like that you will not have to update the index in case you are more regular shapes
				brushEngine.param_shapes.index = brushEngine.param_shapes.stringList.indexOf(WetBrushShape2.NAME);
				
				WaterColorBrush(brushEngine).param_paintMode.value = 1;
				
				splatterDecorator.active=false;
				spawnDecorator.active=false;
				
				sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_RANDOM;
				sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
				sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.93;
				//sizeDecorator.param_mappingRange.numberValue = 0.001+precision * (0.1);
				sizeDecorator.param_mappingRange.numberValue = 0;
				sizeDecorator.param_maxSpeed.numberValue = 200;
				sizeDecorator.param_mappingFactor.numberValue = 1;
				sizeDecorator.param_mappingRange.numberValue = 0.0;
				sizeDecorator.param_mappingFactor.minLimit = 0.01;
				sizeDecorator.param_mappingFactor.maxLimit = 2;
				
				
				
				
			} else {
				WaterColorBrush(brushEngine).param_paintMode.value = 0;
				onStyleChanged(null);
			}
		}
		
	}
}