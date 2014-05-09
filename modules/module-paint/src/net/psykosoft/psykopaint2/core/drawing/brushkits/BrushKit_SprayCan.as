package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.brushes.SprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterMapping;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.AbstractPointDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.CallbackDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.GridDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.StationaryDecorator;
	import net.psykosoft.psykopaint2.core.managers.accelerometer.GyroscopeManager;

	public class BrushKit_SprayCan extends BrushKit
	{
		private static const STYLE_DEFAULT:int=0;
		private static const STYLE_SPONGE:int = 1;
		private static const STYLE_DIGITAL:int = 2;
		private static const STYLE_HALO_SPRAY:int = 3;
		//private static const STYLE_BLOODSPLAT:int = 4;
		//private static const STYLE_FRECKLES2:int = 5;
		private static const STYLE_DROPPING:int = 4;
		
		
		
		
		private var param_style:PsykoParameter;
		private var param_precision:PsykoParameter;
		private var param_intensity:PsykoParameter;

		private var sizeDecorator:SizeDecorator;
		private var splatterDecorator:SplatterDecorator;
		private var bumpDecorator:BumpDecorator;
		private var spawnDecorator:SpawnDecorator;
		private var colorDecorator:ColorDecorator;
		private var gridDecorator:GridDecorator;
		private var callbackDecorator:CallbackDecorator;
		private var eraserMode:Boolean;
		private var _persistentPoints:Object;
		private var stationaryDecorator:StationaryDecorator;
		private var precision:Number;
		
		
		public function BrushKit_SprayCan()
		{
			init( null );
		}
		
		override protected function init( xml:XML ):void
		{
			if (!_initialized ) BrushKit.init();
			
			
			name = "Spray cans";
			
			//CREATE SPRAY CAN BRUSH ENGINE
			brushEngine = new SprayCanBrush();
			brushEngine.param_bumpiness.numberValue = 1;
			brushEngine.param_bumpInfluence.numberValue = 0.8;
			brushEngine.param_quadOffsetRatio.numberValue = 0.4;
			brushEngine.param_curvatureSizeInfluence.numberValue = 0;
			brushEngine.param_shapes.stringList = Vector.<String>(["noisy","almost circular rough","almost circular hard","splatspray","splatspray"]);
			

			
			
			var pathManager:PathManager = new PathManager( PathManager.ENGINE_TYPE_EXPERIMENTAL );
			brushEngine.pathManager = pathManager;
			pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			pathManager.pathEngine.outputStepSize.numberValue = 4;
			pathManager.pathEngine.sendTaps = false;
			pathManager.addCallback( this,null,onPathStart,onPathEnd );
			
			
			stationaryDecorator = new StationaryDecorator();
			stationaryDecorator.param_delay.numberValue=10;
			stationaryDecorator.param_maxOffset.numberValue=20;
			stationaryDecorator.param_sizeRange.lowerRangeValue=1;
			stationaryDecorator.param_sizeRange.upperRangeValue=1;
			pathManager.addPointDecorator(stationaryDecorator);

			
			sizeDecorator = new SizeDecorator();
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
			sizeDecorator.param_mappingFactor.numberValue = 0.2;
			sizeDecorator.param_mappingRange.numberValue = 0.05;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
			pathManager.addPointDecorator( sizeDecorator );
			
			splatterDecorator = new SplatterDecorator();
			splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SIZE_INV;
			splatterDecorator.param_mappingMode.numberValue = 1;
			splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
			splatterDecorator.param_splatFactor.numberValue = 20;
			splatterDecorator.param_minOffset.numberValue = 0;
			splatterDecorator.param_offsetAngleRange.degrees = 360;
			splatterDecorator.param_sizeFactor.numberValue = 0;
			pathManager.addPointDecorator( splatterDecorator );
			
			bumpDecorator = new BumpDecorator();
			bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM2;
			bumpDecorator.param_invertMapping.booleanValue = true;
			bumpDecorator.param_bumpiness.numberValue = 0.5;
			bumpDecorator.param_bumpinessRange.numberValue = 0.5;
			bumpDecorator.param_bumpInfluence.numberValue = 0.8;
			bumpDecorator.param_noBumpProbability.numberValue = 0.8;
			pathManager.addPointDecorator( bumpDecorator );
					
			spawnDecorator = new SpawnDecorator();
			spawnDecorator.param_multiples.upperRangeValue = 1;
			spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SIZE_INV;
			spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_RANDOM;
			spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
			spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
			spawnDecorator.param_maxSize.numberValue = 0.12;
			spawnDecorator.param_minOffset.numberValue = 0;
			spawnDecorator.param_maxOffset.numberValue = 16;
			pathManager.addPointDecorator( spawnDecorator );
			
			gridDecorator = new GridDecorator();
			gridDecorator.param_stepX.numberValue = 0;
			gridDecorator.param_stepY.numberValue = 0;
			gridDecorator.param_angleStep.degrees = 90;
			gridDecorator.active = false;
			pathManager.addPointDecorator( gridDecorator );
			
			colorDecorator = new ColorDecorator();
			colorDecorator.param_brushOpacity.numberValue = 1;
			colorDecorator.param_brushOpacityRange.numberValue = 0;
			colorDecorator.param_colorBlending.upperRangeValue = 1;
			colorDecorator.param_colorBlending.lowerRangeValue = 0.95;
			colorDecorator.param_pickRadius.lowerRangeValue = 0.25;
			colorDecorator.param_pickRadius.upperRangeValue = 0.33;
			colorDecorator.param_smoothFactor.lowerRangeValue = 0.8;
			pathManager.addPointDecorator( colorDecorator );
			
			callbackDecorator = new CallbackDecorator( this, processPoints );
			
			//this is not how it is used:
			//callbackDecorator.hasActivePoints()
			callbackDecorator.keepActive = false; //or true, but it should only be true under controlled circumstances and not permanently.
			pathManager.addPointDecorator( callbackDecorator );
			
			_parameterMapping = new PsykoParameterMapping();
			
			//UI elements:
			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["Spray","Sponge","Digital","Flare","Dropping"]);
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
			
			SprayCanBrush(brushEngine).param_strokeAlpha.numberValue = param_intensity.numberValue;
			
			eraserMode = false; 
			
			_persistentPoints = new Vector.<SamplePoint>(2);
			
			
			onStyleChanged(null);
		}
		
		private function onPathStart():void
		{
			if (  _persistentPoints[0] != null ) {
				PathManager.recycleSamplePoint(_persistentPoints[0]);
				_persistentPoints[0] = null;
			}
			stationaryDecorator.resetLastPoint();
		}
		
		private function onPathEnd():void
		{
			
			
		}
		
		protected function onStyleChanged(event:Event):void
		{
			
			brushEngine.param_quadOffsetRatio.numberValue = 0.0;
			switch ( param_style.index )
			{
				case STYLE_SPONGE:
				brushEngine.param_quadOffsetRatio.numberValue = 0;
				break;
				case STYLE_DIGITAL:
					brushEngine.param_quadOffsetRatio.numberValue = 0.0;
					break;
			}
			
			brushEngine.param_shapes.index = param_style.index;			
			onPrecisionChanged(null);
			onIntensityChanged(null);
		}
		
		protected function onPrecisionChanged(event:Event):void
		{
			precision = param_precision.numberValue;
			
			
			gridDecorator.active = false;
			spawnDecorator.active = true;
			splatterDecorator.active = true;
			callbackDecorator.active = false;
			stationaryDecorator.active=false;
			
			
			
			
			//DEFAULTS			
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_RANDOM;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
			sizeDecorator.param_mappingFactor.numberValue = 0.08;
			sizeDecorator.param_mappingRange.numberValue = 0.04;
			
			
			splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_FIXED;
			splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
			splatterDecorator.param_splatFactor.numberValue = 20;
			splatterDecorator.param_minOffset.numberValue = 0;
			splatterDecorator.param_offsetAngleRange.degrees = 360;
			splatterDecorator.param_sizeFactor.numberValue = 0;
			splatterDecorator.param_brushAngleOffsetRange.degrees =  0;
			
			bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
			bumpDecorator.param_invertMapping.booleanValue = true;
			bumpDecorator.param_bumpiness.numberValue = 0.5;
			bumpDecorator.param_bumpinessRange.numberValue = 0.5;
			bumpDecorator.param_bumpInfluence.numberValue = 2;
			bumpDecorator.param_noBumpProbability.numberValue = 0.1;
			
			
			spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_FIXED;
			spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_FIXED;
			spawnDecorator.param_multiples.upperRangeValue = 1;
			spawnDecorator.param_multiples.lowerRangeValue = 1;
			//spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
			//spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
			spawnDecorator.param_maxSize.numberValue = 0.12;
			spawnDecorator.param_minOffset.numberValue = 0;
			spawnDecorator.param_maxOffset.numberValue = 16;
			spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -(120 + precision * 60);
			spawnDecorator.param_offsetAngleRange.upperDegreesValue = 120 + precision * 60;
			spawnDecorator.param_autorotate.booleanValue = false;
			
			gridDecorator.param_stepX.numberValue = 0;
			gridDecorator.param_stepY.numberValue = 0;
			gridDecorator.param_angleStep.degrees = 90;
			
			
			colorDecorator.param_brushOpacity.numberValue = 1;
			colorDecorator.param_brushOpacityRange.numberValue = 0;
			colorDecorator.param_colorBlending.upperRangeValue = 1;
			colorDecorator.param_colorBlending.lowerRangeValue = 0.2;
			colorDecorator.param_pickRadius.lowerRangeValue = 0.25;
			colorDecorator.param_pickRadius.upperRangeValue = 0.33;
			colorDecorator.param_smoothFactor.lowerRangeValue = 0.8;
			colorDecorator.param_applyColorMatrix.booleanValue=false;
			
			//CHANGE ENGINE
			//brushEngine = _sprayCanBrushEngine;
			brushEngine.textureScaleFactor = 1;
			brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 2 + precision * 8;
			//brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.01 + precision * 0.3;
			
			
			
			
			switch ( param_style.index )
			{
				case STYLE_DEFAULT:
					trace("STYLE DEFAULT");
					spawnDecorator.active = false;
					splatterDecorator.active = true;
					
					//DISTANCE BETWEEN STEPS : THE LESS, THE MORE DENSE IT WILL BE
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 3 ;
					brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
					//brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 3 - precision * 2.5;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 2.5;
					
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_FIXED;
					bumpDecorator.param_bumpInfluence.numberValue = 0.45;
					bumpDecorator.param_bumpiness.numberValue = 0.15 ;
					bumpDecorator.param_bumpinessRange.numberValue = -0.20 ;
					bumpDecorator.param_glossiness.numberValue = 0.8  ;
					
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.2;
					colorDecorator.param_pickRadius.lowerRangeValue = 0.0;
					colorDecorator.param_pickRadius.upperRangeValue = 0.35;
					colorDecorator.param_colorBlending.upperRangeValue = 0.99;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.97;
					
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_RANDOM;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.93;
					sizeDecorator.param_mappingRange.numberValue = 0.01;
					sizeDecorator.param_maxSpeed.numberValue = 200;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_splatFactor.numberValue = 0.01+0.9 * precision;
					//splatterDecorator.param_splatFactor.numberValue = 1;

					
				
					
					break;
				
				case STYLE_SPONGE:
					
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.4 + precision  *4;
					//brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 500;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_RANDOM;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.93;
					//sizeDecorator.param_mappingRange.numberValue = 0.001+precision * (0.1);
					sizeDecorator.param_mappingRange.numberValue = 0;
					sizeDecorator.param_maxSpeed.numberValue = 200;
					
					
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0;
					colorDecorator.param_pickRadius.upperRangeValue = 0;
					colorDecorator.param_brushOpacity.numberValue = 0.91;
					colorDecorator.param_brushOpacityRange.numberValue = 0.04;
					colorDecorator.param_colorBlending.upperRangeValue = 0.98;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.90;
					
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM2;
					bumpDecorator.param_bumpInfluence.numberValue = 0.25;
					bumpDecorator.param_bumpiness.numberValue = 0.10 ;
					bumpDecorator.param_bumpinessRange.numberValue = 0.04 ;
					bumpDecorator.param_noBumpProbability.numberValue=0.4;
					//MAKE IT WET
					bumpDecorator.param_glossiness.numberValue = 0.95  ;
					
					
					gridDecorator.active=true;
					splatterDecorator.active=false;
					spawnDecorator.active=false;
					
					
					
					
					break;
				
				case STYLE_DIGITAL:
					
					
					//DISTANCE BETWEEN STEPS : THE LESS, THE MORE DENSE IT WILL BE
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 ;
					
				
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.4;
					colorDecorator.param_pickRadius.upperRangeValue = 0.4;
					colorDecorator.param_brushOpacity.numberValue = 0.7;
					colorDecorator.param_brushOpacityRange.numberValue = 0.1;
					colorDecorator.param_colorBlending.upperRangeValue = 0.98;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.90;
					
					//sizeDecorator.param_invertMapping.booleanValue = false;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_RANDOM;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
					sizeDecorator.param_mappingFactor.numberValue = 0.01+ 0.99* precision;
					sizeDecorator.param_mappingRange.numberValue = 0;
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM2;
					bumpDecorator.param_bumpInfluence.numberValue = 0.85;
					bumpDecorator.param_bumpiness.numberValue = 0.15 ;
					bumpDecorator.param_bumpinessRange.numberValue = 0.04 ;
					bumpDecorator.param_glossiness.numberValue = 0.55  ;
					bumpDecorator.param_noBumpProbability.numberValue=0.94;
					

					//NO SPLATTING
					
					splatterDecorator.active=false;

					spawnDecorator.active=false;
					
					break;
				
				
				
				case STYLE_HALO_SPRAY:
					stationaryDecorator.active=true;
						
					brushEngine.textureScaleFactor = 2;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 1 + precision * 15;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM2;
					bumpDecorator.param_bumpInfluence.numberValue = 0.55;
					bumpDecorator.param_bumpiness.numberValue = 0.15 ;
					bumpDecorator.param_bumpinessRange.numberValue = 0.3 ;
					bumpDecorator.param_glossiness.numberValue = 0.70  ;
					
					
					colorDecorator.param_colorBlending.upperRangeValue = 0.9;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.65;
					colorDecorator.param_pickRadius.lowerRangeValue = 0.0;
					colorDecorator.param_pickRadius.upperRangeValue = 0.33;
					colorDecorator.param_brushOpacity.numberValue = 0.90;
					colorDecorator.param_brushOpacityRange.numberValue = 0.1;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = -0.05;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 0.05;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.05;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.05;		
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_RANDOM;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_QUINTIC_IN;
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.60;
					sizeDecorator.param_mappingRange.numberValue = 0.025+precision * 0.55;
					
					
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_SIZE_INV;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_maxOffset.numberValue = 0.1+precision * 40;
					spawnDecorator.param_minOffset.numberValue = 0.1+precision * 30;
					spawnDecorator.param_multiples.lowerRangeValue = 2;
					spawnDecorator.param_multiples.upperRangeValue = 6;
					
					
					splatterDecorator.active=false;
					
					
					
					
					break;
				/*
				case STYLE_BLOODSPLAT:
					
					
					trace("STYLE_BLOODSPLAT");
					//USE "splatspray"
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.4 + precision * 3;
					//brushEngine.textureScaleFactor = 1.5;
					
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_RANDOM;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_EXPONENTIAL_IN;
					sizeDecorator.param_mappingFactor.numberValue = 0.05+precision * 0.20;
					sizeDecorator.param_mappingRange.numberValue = 0.04+precision * 0.18;
					
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_SIZE_INV;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_maxOffset.numberValue = 0.01+precision * 20;
					spawnDecorator.param_minOffset.numberValue = 0.01;
					spawnDecorator.param_maxSize.numberValue = 0.2;
					spawnDecorator.param_multiples.lowerRangeValue = 4;
					spawnDecorator.param_multiples.upperRangeValue = 16;
					spawnDecorator.param_bristleVariation.numberValue=1;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue=-180;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue=180;

					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.4;
					colorDecorator.param_pickRadius.upperRangeValue = 0.4;
					colorDecorator.param_brushOpacity.numberValue = 0.94;
					colorDecorator.param_brushOpacityRange.numberValue = 0.06;
					colorDecorator.param_colorBlending.upperRangeValue = 0.9;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.8;
					
					splatterDecorator.active=false;
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SIZE_INV;
					splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
					splatterDecorator.param_splatFactor.numberValue = 20;
					splatterDecorator.param_minOffset.numberValue = 0;
					splatterDecorator.param_offsetAngleRange.degrees = 360;
					splatterDecorator.param_sizeFactor.numberValue = 0;
					splatterDecorator.param_brushAngleOffsetRange.degrees =  0;
					
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM2;
					bumpDecorator.param_bumpInfluence.numberValue = 0.9;
					bumpDecorator.param_bumpiness.numberValue = 0.45 ;
					bumpDecorator.param_bumpinessRange.numberValue = 0.3 ;
					bumpDecorator.param_glossiness.numberValue = 0.9  ;
					bumpDecorator.param_shininess.numberValue = 0.9  ;
					
					break;
				
				case STYLE_FRECKLES2:
					

					trace("STYLE_FRECKLES2");
					//USE almost circular hard
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 2 + precision * 10;
					//brushEngine.textureScaleFactor = 1.5;
					
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_RANDOM;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
					sizeDecorator.param_mappingFactor.numberValue = 0.04+precision * 0.3;
					sizeDecorator.param_mappingRange.numberValue = 0.03+precision * 0.27;
					
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_SIZE_INV;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_maxOffset.numberValue = 0.01+precision * 20;
					spawnDecorator.param_minOffset.numberValue = 0.01;
					spawnDecorator.param_maxSize.numberValue = 0.2;
					spawnDecorator.param_multiples.lowerRangeValue = 1;
					spawnDecorator.param_multiples.upperRangeValue = 10;
					spawnDecorator.param_bristleVariation.numberValue=1;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue=-180;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue=180;
					
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.4;
					colorDecorator.param_pickRadius.upperRangeValue = 0.4;
					colorDecorator.param_brushOpacity.numberValue = 0.94;
					colorDecorator.param_brushOpacityRange.numberValue = 0.06;
					colorDecorator.param_colorBlending.upperRangeValue = 0.9;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.8;
					
					
					splatterDecorator.active=false;
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SIZE_INV;
					splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
					splatterDecorator.param_splatFactor.numberValue = 20;
					splatterDecorator.param_minOffset.numberValue = 0;
					splatterDecorator.param_offsetAngleRange.degrees = 360;
					splatterDecorator.param_sizeFactor.numberValue = 0;
					splatterDecorator.param_brushAngleOffsetRange.degrees =  0;
					
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM2;
					bumpDecorator.param_bumpInfluence.numberValue = 0.9;
					bumpDecorator.param_bumpiness.numberValue = 0.15 ;
					bumpDecorator.param_bumpinessRange.numberValue = 0.20 ;
					bumpDecorator.param_glossiness.numberValue = 0.9  ;
					bumpDecorator.param_shininess.numberValue = 0.9  ;
					bumpDecorator.param_noBumpProbability.numberValue=0.5;

					
					break;*/
				
				case STYLE_DROPPING:
					
					stationaryDecorator.active=true;
					callbackDecorator.active=true;
					splatterDecorator.active=false;
					
					brushEngine.textureScaleFactor = 2;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 10 + precision * 15;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM2;
					bumpDecorator.param_bumpInfluence.numberValue = 0.55;
					bumpDecorator.param_bumpiness.numberValue = 0.15 ;
					bumpDecorator.param_bumpinessRange.numberValue = 0.3 ;
					bumpDecorator.param_glossiness.numberValue = 0.90  ;
					
					
					colorDecorator.param_colorBlending.upperRangeValue = 0.9;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.65;
					colorDecorator.param_pickRadius.lowerRangeValue = 0.0;
					colorDecorator.param_pickRadius.upperRangeValue = 0.33;
					colorDecorator.param_brushOpacity.numberValue = 0.93;
					colorDecorator.param_brushOpacityRange.numberValue = 0.06;
					
					
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_RANDOM;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_STRONG_IN;
					sizeDecorator.param_mappingFactor.numberValue = 0.05 + precision * 0.8;
					sizeDecorator.param_mappingRange.numberValue = 0.04+precision * 0.78;
					
					
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_SIZE_INV;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_maxOffset.numberValue = 0.1+precision * 30;
					spawnDecorator.param_minOffset.numberValue = 0.1+precision * 5;
					spawnDecorator.param_multiples.lowerRangeValue = 1+precision * 3;
					spawnDecorator.param_multiples.upperRangeValue = 7+precision * 4;
					
					
				
					
					
					
					
					break;
				
				/*
				case STYLE_FRECKLESOLD:
					trace("STYLE_FRECKLES2");
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
					sizeDecorator.param_mappingFactor.numberValue = 0.4+precision * 0.2;
					sizeDecorator.param_mappingRange.numberValue = 0.1+precision * 0.05;
					
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_SIZE_INV;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_maxOffset.numberValue = 0.1+precision * 50;
					spawnDecorator.param_minOffset.numberValue = 0.1+precision * 10;
					spawnDecorator.param_maxSize.numberValue = 50;
					spawnDecorator.param_multiples.lowerRangeValue = 1+precision*4;
					spawnDecorator.param_multiples.upperRangeValue = 4+precision*8;
					spawnDecorator.param_sizeFactor.numberValue=1;
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM2;
					bumpDecorator.param_bumpInfluence.numberValue = 0.5;
					bumpDecorator.param_bumpiness.numberValue = 0.25 ;
					bumpDecorator.param_bumpinessRange.numberValue = 0.1 ;
					bumpDecorator.param_glossiness.numberValue = 0.2  ;
					bumpDecorator.param_shininess.numberValue = 0.2  ;
					
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0;
					colorDecorator.param_pickRadius.upperRangeValue = 0.1;
					colorDecorator.param_brushOpacity.numberValue = 0.90;
					colorDecorator.param_brushOpacityRange.numberValue = 0.06;
					colorDecorator.param_colorBlending.upperRangeValue = 0.98;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.94;
					
					break;*/
				default:
					
					break;
				
			}
			
			trace("stop");
		}
		
		protected function onIntensityChanged(event:Event):void
		{
			var intensity:Number = param_intensity.numberValue;
			//RESET LAYER OPACITY
			if (brushEngine is SprayCanBrush) (brushEngine  as SprayCanBrush).param_strokeAlpha.numberValue = 1;
			
			switch ( param_style.index )
			{
//				case STYLE_SPLAT_SPRAY:
//					brushEngine.pathManager.pathEngine.minSamplesPerStep.numberValue = 0.1;
//					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 100-intensity*99;
//					(brushEngine as SprayCanBrush).param_strokeAlpha.numberValue = 1;
//				break;
				/*case STYLE_WET:
					colorDecorator.param_brushOpacity.numberValue = 0.25 + intensity * 0.75;
					break;*/
				case STYLE_DEFAULT:
					
					//ALPHA OF LAYER IS 1 HERE CAUSE WE DON'T WANT TO HAVE TRANSPARENCY ON THE LAYER SIDE
					(brushEngine  as SprayCanBrush).param_strokeAlpha.numberValue = 1;
					//CHANGE INDIVIDUAL BRUSH OPACITY
					colorDecorator.param_brushOpacity.numberValue = 0.3+intensity*0.7;
					bumpDecorator.param_bumpInfluence.numberValue = 0.15+intensity*0.25;
					bumpDecorator.param_bumpinessRange.numberValue = 0.25+intensity*0.15;
					
					break;
				
				//SIMPLE OPACITY BY DEFAULT
				default:
					
					(brushEngine as SprayCanBrush).param_strokeAlpha.numberValue = 0.1+param_intensity.numberValue*0.9;
					
				break;
				
				
				
				//bumpDecorator.param_glossiness.numberValue = 0.3 + 0.2 * intensity;
				//bumpDecorator.param_shininess.numberValue = 0.1 + 0.2 * intensity;
			}
			
			if ( eraserMode )
			{
				//THIS WILL MAKE SURE THAT ERASER ALSO REMOVE DEPTH
				bumpDecorator.param_bumpInfluence.numberValue = - intensity;
				//bumpDecorator.param_bumpiness.numberValue = 0;
				//bumpDecorator.param_bumpinessRange.numberValue = 0;
				
			} 
		}
		
		protected function processPoints(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			
			var addedPoints:Vector.<SamplePoint> = new Vector.<SamplePoint>();
			
			var gyro:Matrix3D = GyroscopeManager.orientationMatrix;
			var vector:Vector.<Vector3D> = GyroscopeManager.orientationMatrix.decompose();
			//vector[1] is rotation vector
			
			//TESTING ON DESKTOP
			if(!CoreSettings.RUNNING_ON_iPAD)
			{vector[1].y=Math.random()*0.3-0.15;
			vector[1].x=0.7;}
			
			//ADD A BIT OF TURBULENCE
			vector[1].x+=Math.random()*0.3-0.15;
			vector[1].y+=Math.random()*0.3-0.15;
			
			//trace(vector[1]);
			
			for ( var i:int = 0; i < points.length; i++ )
			{
				/*if ( Math.random() < 0.10 )
				{
					points[i].x += (Math.random()-Math.random()) * gridDecorator.param_stepX.numberValue;
					points[i].y += (Math.random()-Math.random()) * gridDecorator.param_stepY.numberValue;
				}*/
				
				if(i==0){
					
					//var newPoint :SamplePoint = points[i].getClone();
					//var newPoint :SamplePoint = points[i];
					if(Math.random()<0.1){
						//the way you stored the persistent points creates a memory leak.
						//you should use always use PathManager.recycleSamplePoint() before you overwrite
						//and old point, like this:
						if ( _persistentPoints[0] != null ) PathManager.recycleSamplePoint(_persistentPoints[0]);
						_persistentPoints[0] = points[0].getClone();
						_persistentPoints[0].size = 0.02*Math.random()+0.01 + precision*(Math.random()*0.02+0.05);
						trace("create point")
					}else {
						if(_persistentPoints[0]){
							//points[0] = _persistentPoints[0].getClone() ;
							_persistentPoints[0].x += vector[1].y*100*_persistentPoints[0].size;
							_persistentPoints[0].y += vector[1].x*100*_persistentPoints[0].size;
							points[0].x = _persistentPoints[0].x ;
							points[0].y = _persistentPoints[0].y ;
							points[0].size = _persistentPoints[0].size;
							//_persistentPoints[0].size *= (1+0.05-Math.random()*0.05);
							//_persistentPoints[0].size *= 0.995;
						}
					 	
					}
					//newPoint.size = 0.2-i*0.15/2;
					
					
					
					//newPoint.x += vector[1].x*i*40;
					//newPoint.y+= vector[1].y*i*40;
					
					
					//_persistentPoints[i]=(newPoint);
					//trace("added points");
				}
				
				
				//if ( Math.random() < 0.25 ){
					
					//addedPoints.push(newPoint);
				
					
					//newPoint.x += vector[1].x*200;
					//newPoint.y += vector[1].y*200;
					
					
				//}
				
				
			}
			//points.concat(_persistentPoints);
			
			
			return points;
		}
		
		override public function setEraserMode( enabled:Boolean ):void
		{
			trace(this,"setEraserMode",enabled);
			eraserMode = enabled;
			super.setEraserMode(enabled);
			onIntensityChanged(null);
		}
	}
}