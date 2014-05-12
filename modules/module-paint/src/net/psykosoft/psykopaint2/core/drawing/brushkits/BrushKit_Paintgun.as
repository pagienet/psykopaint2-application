package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.drawing.brushes.SprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterMapping;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.AbstractPointDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;
	
	public class BrushKit_Paintgun extends BrushKit
	{
		private static const STYLE_INKSPLATS:int = 0;
		private static const STYLE_PAINT_BALL:int = 1;
		private static const STYLE_CONFETTIS:int = 2;
		private static const STYLE_CRAYATOR:int = 3;
		private static const STYLE_AUTOPAINT:int = 4;
		private static const STYLE_PAINTBRUSH:int = 5;
		
		
		
		private var param_style:PsykoParameter;
		private var param_precision:PsykoParameter;
		private var param_intensity:PsykoParameter;
		
		private var sizeDecorator:SizeDecorator;
		private var splatterDecorator:SplatterDecorator;
		private var bumpDecorator:BumpDecorator;
		private var spawnDecorator:SpawnDecorator;
		private var colorDecorator:ColorDecorator;
		//private var callbackDecorator:CallbackDecorator;
		
		
		private var eraserMode:Boolean;
		
		public function BrushKit_Paintgun()
		{
			isPurchasable = true;
			init( null );
		}
		
		override protected function init( xml:XML ):void
		{
			if (!_initialized ) BrushKit.init();
			
			name = "Paint guns";
			
			brushEngine = new SprayCanBrush();
			brushEngine.param_bumpiness.numberValue = 0;
			brushEngine.param_bumpInfluence.numberValue = 0.8;
			brushEngine.param_quadOffsetRatio.numberValue = 0.4;
			brushEngine.param_shapes.stringList = Vector.<String>(["inksplats","splats","spray","crayon","splotch","splotch"]);
			
			var pathManager:PathManager = new PathManager( PathManager.ENGINE_TYPE_EXPERIMENTAL );
			brushEngine.pathManager = pathManager;
			
			sizeDecorator = new SizeDecorator();
			pathManager.addPointDecorator( sizeDecorator );
			
			spawnDecorator = new SpawnDecorator();
			pathManager.addPointDecorator( spawnDecorator );
			
			bumpDecorator = new BumpDecorator();
			pathManager.addPointDecorator( bumpDecorator );
			
			colorDecorator = new ColorDecorator();
			pathManager.addPointDecorator( colorDecorator );
			
			splatterDecorator = new SplatterDecorator();
			pathManager.addPointDecorator( splatterDecorator );
			
			//callbackDecorator = new CallbackDecorator(this, processPoints);
			//callbackDecorator.active = false;
			//pathManager.addPointDecorator( callbackDecorator );
			
			
			_parameterMapping = new PsykoParameterMapping();
			
			//UI elements:
			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["Splat","Paint Ball","Confettis","Crayator","Autopaint","Splotch"]);
			param_style.showInUI = 0;
			param_style.addEventListener( Event.CHANGE, onStyleChanged );
			_parameterMapping.addParameter(param_style);
			
			param_precision = new PsykoParameter( PsykoParameter.NumberParameter,"Precision",0.5,0,1);
			param_precision.showInUI = 1;
			param_precision.addEventListener( Event.CHANGE, onPrecisionChanged );
			_parameterMapping.addParameter(param_precision);
			
			param_intensity = new PsykoParameter( PsykoParameter.NumberParameter,"Intensity",1,0,1);
			param_intensity.showInUI = 2;
			param_intensity.addEventListener( Event.CHANGE, onIntensityChanged );
			_parameterMapping.addParameter(param_intensity);
			
			(brushEngine as SprayCanBrush).param_strokeAlpha.numberValue = param_intensity.numberValue;
			onStyleChanged(null);
		}
		
		protected function onStyleChanged(event:Event):void
		{
			
			brushEngine.param_quadOffsetRatio.numberValue = 0.4;
			//brushEngine.param_quadOffsetRatio.numberValue = 0;
			switch ( param_style.index )
			{
				
				case STYLE_PAINT_BALL:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
				case STYLE_INKSPLATS:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
				case STYLE_CONFETTIS:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
				case STYLE_CRAYATOR:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
				case STYLE_AUTOPAINT:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
				case STYLE_PAINTBRUSH:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
					
					break;
				
			}
			
			
			brushEngine.param_shapes.index = param_style.index;
			
			onPrecisionChanged(null);
			onIntensityChanged(null);
		}
		
		protected function onPrecisionChanged(event:Event):void
		{
			var precision:Number = param_precision.numberValue;
			
			
			spawnDecorator.active = true;
			splatterDecorator.active = true;
			
			brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			brushEngine.pathManager.pathEngine.sendTaps = false;
			brushEngine.param_curvatureSizeInfluence.numberValue = 1;
			brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 200;
			brushEngine.textureScaleFactor = 1;
			brushEngine.param_bumpiness.numberValue = 0.2;
			brushEngine.param_bumpInfluence.numberValue = 0.8;
			
			
			
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
			sizeDecorator.param_mappingFactor.numberValue = 0.8;
			sizeDecorator.param_mappingRange.numberValue = 0.4;
			sizeDecorator.param_mappingFactor.minLimit = 0.01;
			sizeDecorator.param_mappingFactor.maxLimit = 2;
			
			bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
			bumpDecorator.param_invertMapping.booleanValue = true;
			bumpDecorator.param_bumpiness.numberValue = 0.5;
			bumpDecorator.param_bumpinessRange.numberValue = 0.5;
			bumpDecorator.param_bumpInfluence.numberValue = 0.8;
			bumpDecorator.param_noBumpProbability.numberValue = 0.8;
			
			
			colorDecorator.param_pickRadius.lowerRangeValue = 0.25;
			colorDecorator.param_pickRadius.upperRangeValue = 0.33;
			colorDecorator.param_smoothFactor.lowerRangeValue = 0.8;
			colorDecorator.param_saturationAdjustment.lowerRangeValue = 0;
			colorDecorator.param_saturationAdjustment.upperRangeValue = 0;
			colorDecorator.param_brightnessAdjustment.lowerRangeValue = 0;
			colorDecorator.param_brightnessAdjustment.upperRangeValue= 0;
			colorDecorator.param_brushOpacity.numberValue = 0.95;
			colorDecorator.param_brushOpacityRange.numberValue = 0.05;
			colorDecorator.param_colorBlending.upperRangeValue = 1;
			colorDecorator.param_colorBlending.lowerRangeValue = 0.98;
			colorDecorator.param_applyColorMatrix.booleanValue = false;
			
			
			spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_PRESSURE_SPEED;
			spawnDecorator.param_multiples.upperRangeValue = 1;
			spawnDecorator.param_multiples.lowerRangeValue = 1;
			spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -(120 + precision * 60);
			spawnDecorator.param_offsetAngleRange.upperDegreesValue = 120 + precision * 60;
			//spawnDecorator.param_maxSize.numberValue = 0.05 + precision * 0.36;
			spawnDecorator.param_maxSize.numberValue = 1;
			spawnDecorator.param_minOffset.numberValue = 0;
			spawnDecorator.param_maxOffset.numberValue = 16;
			
			
			
			
			splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
			splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
			splatterDecorator.param_brushAngleOffsetRange.degrees =  0;
			splatterDecorator.param_splatFactor.numberValue = 20;
			splatterDecorator.param_minOffset.numberValue = 0;
			splatterDecorator.param_offsetAngleRange.degrees = 360;
			splatterDecorator.param_sizeFactor.numberValue = 0;
			
			
		

			
			
			
			
			
			
			switch ( param_style.index )
			{
				case STYLE_INKSPLATS:
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 200;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
					sizeDecorator.param_mappingFactor.numberValue = 0.1+precision * 0.4;
					sizeDecorator.param_mappingRange.numberValue = 0.05+precision * 0.25;
					
					colorDecorator.param_brushOpacity.numberValue=0.92;
					colorDecorator.param_brushOpacityRange.numberValue = 0.08;
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_multiples.upperRangeValue = 8;
					spawnDecorator.param_multiples.lowerRangeValue = 1;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 10;
					spawnDecorator.param_maxOffset.numberValue =  10+precision * 30;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_bumpiness.numberValue = 0.6;
					bumpDecorator.param_bumpinessRange.numberValue = 0.2;
					bumpDecorator.param_bumpInfluence.numberValue = 0.25;
					bumpDecorator.param_noBumpProbability.numberValue = 0.6;
					bumpDecorator.param_glossiness.numberValue = 0.55 ;
					
					break;
				
				
				case STYLE_PAINT_BALL:
					
					brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 1000;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
					sizeDecorator.param_mappingFactor.numberValue = 0.2+precision * 0.5;
					sizeDecorator.param_mappingRange.numberValue = 0.05;
					
					splatterDecorator.active=false;
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
					splatterDecorator.param_splatFactor.numberValue = 0+precision * 10;
					splatterDecorator.param_minOffset.numberValue = 0+precision * 10;
					//splatterDecorator.param_offsetAngleRange.degrees = 360;
					splatterDecorator.param_offsetAngleRange.degrees = 120;
					splatterDecorator.param_sizeFactor.numberValue = 0.5+precision * 6;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_bumpiness.numberValue = 0.3;
					bumpDecorator.param_bumpinessRange.numberValue = 0.2;
					bumpDecorator.param_bumpInfluence.numberValue = 0.12;
					bumpDecorator.param_noBumpProbability.numberValue = 0.6;
					bumpDecorator.param_glossiness.numberValue = 0.35 ;
					
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.001;
					colorDecorator.param_pickRadius.upperRangeValue = 0.01;
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.04;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = -0.3;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 0.3;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.2;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.2;
					//colorDecorator.param_brushOpacity.numberValue = 0.8;
					//colorDecorator.param_brushOpacityRange.numberValue = 0.15;
					colorDecorator.param_brushOpacity.numberValue = 0.95;
					colorDecorator.param_brushOpacityRange.numberValue = 0.05;
					colorDecorator.param_colorBlending.upperRangeValue = 1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.98;
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_RANDOM;
					spawnDecorator.param_multiples.upperRangeValue = 6;
					spawnDecorator.param_multiples.lowerRangeValue = 2;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_PRESSURE_SPEED;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 20;
					spawnDecorator.param_maxOffset.numberValue =  0+precision * 50;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
					//spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -2;
					//spawnDecorator.param_offsetAngleRange.upperDegreesValue = 2;
					spawnDecorator.param_bristleVariation.numberValue = 0;
					break;
				
				
				case STYLE_CONFETTIS:
					trace("STYLE_CONFETTIS");
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 50;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
					sizeDecorator.param_mappingFactor.numberValue = 0.20+precision * 0.2;
					sizeDecorator.param_mappingRange.numberValue = 0.02+precision * 0.12;
					
					splatterDecorator.active=true;
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
					splatterDecorator.param_splatFactor.numberValue = 0+precision * 20;
					splatterDecorator.param_minOffset.numberValue = 0+precision * 20;
					splatterDecorator.param_offsetAngleRange.degrees = 120;
					splatterDecorator.param_sizeFactor.numberValue = 0.5+precision * 6;
					
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.1;
					colorDecorator.param_pickRadius.upperRangeValue = 0.4;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = -0.2;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 0.2;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.3;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.3;
					colorDecorator.param_brushOpacity.numberValue = 0.90;
					colorDecorator.param_brushOpacityRange.numberValue = 0.10;
					colorDecorator.param_colorBlending.upperRangeValue = 0.2;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.1;
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED;
					spawnDecorator.param_autorotate.booleanValue=true;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_SIZE;
					spawnDecorator.param_brushAngleRange.lowerDegreesValue=-90;
					spawnDecorator.param_brushAngleRange.upperDegreesValue=90;
					spawnDecorator.param_multiples.upperRangeValue = 10;
					spawnDecorator.param_multiples.lowerRangeValue = 4;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 10;
					spawnDecorator.param_maxOffset.numberValue =  0+precision * 30;
					spawnDecorator.param_bristleVariation.numberValue = 10;
					
					
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_bumpiness.numberValue = 0.6;
					bumpDecorator.param_bumpinessRange.numberValue = 0.2;
					bumpDecorator.param_bumpInfluence.numberValue = 0.25;
					bumpDecorator.param_noBumpProbability.numberValue = 0.6;
					bumpDecorator.param_glossiness.numberValue = 0.12 ;
					break;
				case STYLE_CRAYATOR:
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 10;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
					sizeDecorator.param_mappingFactor.numberValue = 0.05+precision*0.15;
					sizeDecorator.param_mappingRange.numberValue = 0.00+precision*0.02;
					
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.0;
					colorDecorator.param_pickRadius.upperRangeValue = 0.0;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = 0;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 1.2;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = 0;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.3;
					colorDecorator.param_brushOpacity.numberValue = 0.96;
					colorDecorator.param_brushOpacityRange.numberValue = 0.04;
					colorDecorator.param_colorBlending.upperRangeValue = 1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0;
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					colorDecorator.param_smoothFactor.lowerRangeValue= 0;
					colorDecorator.param_smoothFactor.upperRangeValue= 0;
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_multiples.upperRangeValue = 8;
					spawnDecorator.param_multiples.lowerRangeValue = 2;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 20;
					spawnDecorator.param_maxOffset.numberValue =  0+precision * 50;
					spawnDecorator.param_bristleVariation.numberValue = 2;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_bumpiness.numberValue = 0.6;
					bumpDecorator.param_bumpinessRange.numberValue = 0.1;
					bumpDecorator.param_bumpInfluence.numberValue = 0.65;
					bumpDecorator.param_noBumpProbability.numberValue = 0.8;
					bumpDecorator.param_glossiness.numberValue = 0.82 ;
					
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_brushAngleOffsetRange.degrees =  0;
					splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
					splatterDecorator.param_splatFactor.numberValue = precision * 30;
					splatterDecorator.param_minOffset.numberValue = precision * 30;
					splatterDecorator.param_offsetAngleRange.degrees = 360;
					splatterDecorator.param_sizeFactor.numberValue = 1;
					
					
					break;
				case STYLE_AUTOPAINT:
					trace("STYLE_AUTOPAINT");
					brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 2000;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
					sizeDecorator.param_invertMapping.booleanValue=false;
					sizeDecorator.param_mappingFactor.numberValue = 1+precision * 3;
					sizeDecorator.param_mappingRange.numberValue = 0.5+precision * 1;
					//sizeDecorator.param_mappingRange.numberValue = 1;
					
					
					
					
					//splatterDecorator.active=false;
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_mappingFunction.index =  AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
					splatterDecorator.param_splatFactor.numberValue = 0+precision * 10;
					splatterDecorator.param_minOffset.numberValue = 0+precision * 10;
					splatterDecorator.param_offsetAngleRange.degrees = 1;
					splatterDecorator.param_sizeFactor.numberValue = 0.5+precision * 6;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_bumpiness.numberValue = 0.2;
					bumpDecorator.param_bumpinessRange.numberValue = 0.1;
					bumpDecorator.param_bumpInfluence.numberValue = 0.92;
					bumpDecorator.param_noBumpProbability.numberValue = 0.9;
					bumpDecorator.param_glossiness.numberValue = 0.35 ;
					
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.0;
					colorDecorator.param_pickRadius.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.04;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = 0;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 1.2;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.5;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.5;
					colorDecorator.param_brushOpacity.numberValue = 0.95;
					colorDecorator.param_brushOpacityRange.numberValue = 0.05;
					colorDecorator.param_colorBlending.upperRangeValue = 1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0;
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					
					//spawnDecorator.active=false;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED;
					spawnDecorator.param_multiples.upperRangeValue = 4;
					spawnDecorator.param_multiples.lowerRangeValue = 1;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_PRESSURE_SPEED;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 20;
					spawnDecorator.param_maxOffset.numberValue =  0+precision * 50;
					spawnDecorator.param_maxOffset.numberValue =  0;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
					spawnDecorator.param_bristleVariation.numberValue = 4;
					break;
				case STYLE_PAINTBRUSH:
					brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5+precision*10;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CUBIC_IN;
					sizeDecorator.param_mappingFactor.numberValue = 0.05+precision * 0.4;
					sizeDecorator.param_mappingRange.numberValue = precision * 0.2;
					
					//spawnDecorator.active=false;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_multiples.upperRangeValue = 8;
					spawnDecorator.param_multiples.lowerRangeValue = 1;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_PRESSURE_SPEED;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 20;
					spawnDecorator.param_maxOffset.numberValue =  0+precision * 50;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -1;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 1;
					spawnDecorator.param_bristleVariation.numberValue = 1;
					
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
					splatterDecorator.param_splatFactor.numberValue = 0+precision * 10;
					splatterDecorator.param_minOffset.numberValue = 0+precision * 10;
					splatterDecorator.param_offsetAngleRange.degrees = 360;
					splatterDecorator.param_sizeFactor.numberValue = 0.5+precision * 1;
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_bumpiness.numberValue = 0.2;
					bumpDecorator.param_bumpinessRange.numberValue = 0.02;
					bumpDecorator.param_bumpInfluence.numberValue = 0.5;
					bumpDecorator.param_noBumpProbability.numberValue = 0.5;
					bumpDecorator.param_glossiness.numberValue = 0.55 ;
					
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.0;
					colorDecorator.param_pickRadius.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.04;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = -0.1;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 0.1;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.2;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.2;
					colorDecorator.param_brushOpacity.numberValue = 0.95;
					colorDecorator.param_brushOpacityRange.numberValue = 0.05;
					colorDecorator.param_colorBlending.upperRangeValue = 1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0;
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					
					
					
					break;
				
			}
		}
		
		protected function onIntensityChanged(event:Event):void
		{
			var intensity:Number = param_intensity.numberValue;
			//colorDecorator.param_brushOpacity.numberValue = intensity;
			(brushEngine as SprayCanBrush).param_strokeAlpha.numberValue = param_intensity.numberValue;
			
			
			
			
			if ( !eraserMode )
			{
				bumpDecorator.param_bumpInfluence.numberValue = 0.4;
				bumpDecorator.param_bumpiness.numberValue = 0.5 * intensity;
				bumpDecorator.param_bumpinessRange.numberValue = 0.1;
			}
			
			
			
			switch ( param_style.index )
			{
				
				
				case STYLE_CONFETTIS:
				case STYLE_AUTOPAINT:
				case STYLE_PAINTBRUSH:
				//	bumpDecorator.param_glossiness.numberValue = 0.3 + 0.2 * intensity;
					//bumpDecorator.param_shininess.numberValue = 0.1 + 0.2 * intensity;
					break;
				
				case STYLE_INKSPLATS:
				//	bumpDecorator.param_glossiness.numberValue = 0.6 + 0.2 * intensity;
					//bumpDecorator.param_shininess.numberValue = 0.4 + 0.2 * intensity;
					bumpDecorator.param_bumpiness.numberValue = 0.3 * intensity;
					
					break;
				case STYLE_CRAYATOR:
					bumpDecorator.param_bumpiness.numberValue = 0.2 * intensity;
					//bumpDecorator.param_glossiness.numberValue = 0.1 + 0.2 * intensity;
					//bumpDecorator.param_shininess.numberValue = 0.1 + 0.2 * intensity;
					break;
			}
			
			
			if ( eraserMode )
			{
				bumpDecorator.param_bumpInfluence.numberValue = 1 - intensity;
				bumpDecorator.param_bumpiness.numberValue = 0;
				bumpDecorator.param_bumpinessRange.numberValue = 0;
				
			}
		}
		
		
		
		override public function setEraserMode( enabled:Boolean ):void
		{
			eraserMode = enabled;
			if ( enabled )
			{
				brushEngine.param_blendModeSource.index = 1;
				brushEngine.param_blendModeTarget.index = 3;
			} else {
				brushEngine.param_blendModeSource.index = 0; 
				brushEngine.param_blendModeTarget.index = 3;
			}
			onIntensityChanged(null);
		}
	}
}


