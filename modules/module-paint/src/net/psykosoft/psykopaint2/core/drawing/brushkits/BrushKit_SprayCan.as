package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.brushes.SprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AlmostCircularRoughShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.BasicCircularShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.EraserBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.NoisyBrushShape2;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.SplatterSprayShape;
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
	import net.psykosoft.psykopaint2.core.managers.purchase.InAppPurchaseManager;

	public class BrushKit_SprayCan extends BrushKit
	{
		private static const STYLE_HALO_SPRAY:int = 0;

		private static const STYLE_SPONGE:int = 1;
		private static const STYLE_DIGITAL:int = 2;
		private static const STYLE_DEFAULT:int=3;
		//private static const STYLE_BLOODSPLAT:int = 4;
		//private static const STYLE_FRECKLES2:int = 5;
		private static const STYLE_DROPPING:int = 4;
		//Eraser is not a style in the new way of doing things:
		//private static const STYLE_ERASER:int = 5;
		
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
		private var _persistentPoints:Object;
		private var stationaryDecorator:StationaryDecorator;
		private var precision:Number;
		
		
		public function BrushKit_SprayCan()
		{
			purchasePackages.push(InAppPurchaseManager.PRODUCT_ID_FREE);
			
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
			brushEngine.param_shapes.stringList = Vector.<String>([SplatterSprayShape.NAME,NoisyBrushShape2.NAME,AlmostCircularRoughShape.NAME,BasicCircularShape.NAME,SplatterSprayShape.NAME,EraserBrushShape.NAME]);
			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["Flare","Spray","Sponge","Digital","Dropping"]);

			
			
			var pathManager:PathManager = new PathManager( PathManager.ENGINE_TYPE_EXPERIMENTAL );
			brushEngine.pathManager = pathManager;
			pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			pathManager.pathEngine.outputStepSize.numberValue = 4;
			pathManager.pathEngine.sendTaps = false;
			pathManager.addCallback( this,null,onPathStart,onPathEnd,onFingerDown,null );//onFingerUp
			
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
			bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
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
			//NOTE: The Eraser is NOT added as a style here
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
			
			_persistentPoints = new Vector.<SamplePoint>(1);
			
			
			onStyleChanged();
		}
		
		//WHEN START DRAWING
		private function onPathStart():void
		{
			if (  _persistentPoints[0] != null ) {
				PathManager.recycleSamplePoint(_persistentPoints[0]);
				_persistentPoints[0] = null;
			}
			stationaryDecorator.resetLastPoint();
		}
		
		//WHEN RELEASE DRAWING
		private function onPathEnd():void
		{
			if (  _persistentPoints[0] != null ) {
				PathManager.recycleSamplePoint(_persistentPoints[0]);
				_persistentPoints[0] = null;
			}
			stationaryDecorator.resetLastPoint();
		}
		
		
		private function onFingerDown( x:Number, y:Number ):void
		{
			stationaryDecorator.resetLastPoint();
		}
		

		/*
		private function onFingerUp( x:Number, y:Number ):void
		{
			trace("the finger was lifted at",x,y);
		}
		*/
		

		//This is where all the style related brush defaults are set - and this needs only to be called when the 
		//style changes
		private function setStyleDefaults():void
		{
			brushEngine.param_quadOffsetRatio.numberValue = 0.0;
		
			gridDecorator.active = false;
			spawnDecorator.active = true;
			splatterDecorator.active = true;
			callbackDecorator.active = false;
			stationaryDecorator.active = false;
			
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
			bumpDecorator.param_invertMapping.booleanValue = false;
			bumpDecorator.param_bumpiness.numberValue = 0.5;
			bumpDecorator.param_bumpinessRange.numberValue = 0.3;
			bumpDecorator.param_bumpInfluence.numberValue = 2;
			bumpDecorator.param_noBumpProbability.numberValue = 0.1;
			
			
			spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_FIXED;
			spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_FIXED;
			spawnDecorator.param_multiples.upperRangeValue = 0;
			spawnDecorator.param_multiples.lowerRangeValue = 0;
			spawnDecorator.param_maxSize.numberValue = 0.12;
			spawnDecorator.param_minOffset.numberValue = 0;
			spawnDecorator.param_maxOffset.numberValue = 16;
			
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
			
			//brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.01 + precision * 0.3;
		}
		
		protected function onStyleChanged(event:Event= null):void
		{
			//REMOVE PERSISTENT POINTS THAT COULD REMAINS
			if ( _persistentPoints[0] != null ) PathManager.recycleSamplePoint(_persistentPoints[0]);
			
			setStyleDefaults();
			
			brushEngine.param_shapes.index = param_style.index;		
			
			switch ( param_style.index )
			{
				case STYLE_DEFAULT:
					trace("STYLE DEFAULT");
					spawnDecorator.active = false;
					splatterDecorator.active = true;
					
					//DISTANCE BETWEEN STEPS : THE LESS, THE MORE DENSE IT WILL BE
					brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
					//brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 3 - precision * 2.5;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_bumpInfluence.numberValue = 0.5;
					bumpDecorator.param_bumpiness.numberValue = 0.1 ;
					bumpDecorator.param_bumpinessRange.numberValue = 0.02 ;
					bumpDecorator.param_glossiness.numberValue =0.9  ;
					bumpDecorator.param_noBumpProbability.numberValue=0.0;
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.0;
					colorDecorator.param_pickRadius.upperRangeValue = 0.35;
					colorDecorator.param_colorBlending.upperRangeValue = 0.99;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.97;
					colorDecorator.param_brushOpacity.numberValue = 0.95;
					colorDecorator.param_brushOpacityRange.numberValue = 0.01;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_RANDOM;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
					sizeDecorator.param_mappingRange.numberValue = 0.01;
					sizeDecorator.param_maxSpeed.numberValue = 200;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					
					
					break;
				
				case STYLE_SPONGE:
					
					gridDecorator.active=true;
					splatterDecorator.active=false;
					spawnDecorator.active=false;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_RANDOM;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
					sizeDecorator.param_mappingRange.numberValue = 0;
					sizeDecorator.param_maxSpeed.numberValue = 200;
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0;
					colorDecorator.param_pickRadius.upperRangeValue = 0;
					colorDecorator.param_brushOpacity.numberValue = 0.91;
					colorDecorator.param_brushOpacityRange.numberValue = 0.04;
					colorDecorator.param_colorBlending.upperRangeValue = 0.98;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.90;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_bumpInfluence.numberValue = 0.55;
					bumpDecorator.param_bumpiness.numberValue = 0.30 ;
					bumpDecorator.param_bumpinessRange.numberValue = 0.04 ;
					bumpDecorator.param_noBumpProbability.numberValue=0.4;
					//MAKE IT WET
					bumpDecorator.param_glossiness.numberValue = 0.25  ;
					
					break;
					
				break;
				case STYLE_DIGITAL:
					 
					//NO SPLATTING
					splatterDecorator.active=false;
					spawnDecorator.active=false;
					
					//DISTANCE BETWEEN STEPS : THE LESS, THE MORE DENSE IT WILL BE
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.4 ;
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.4;
					colorDecorator.param_pickRadius.upperRangeValue = 0.4;
					colorDecorator.param_brushOpacity.numberValue = 1;
					colorDecorator.param_brushOpacityRange.numberValue = 0.0;
					colorDecorator.param_colorBlending.upperRangeValue = 0.98;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.90;
					
					//sizeDecorator.param_invertMapping.booleanValue = false;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
					sizeDecorator.param_mappingFactor.numberValue = 0.01+ 0.99* precision;
					sizeDecorator.param_mappingRange.numberValue = 0.00;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_PRESSURE_SPEED;
					bumpDecorator.param_invertMapping.booleanValue=false;
					bumpDecorator.param_bumpInfluence.numberValue = 0.5;
					bumpDecorator.param_bumpiness.numberValue = 0.2 ;
					bumpDecorator.param_bumpinessRange.numberValue = 0.04 ;
					bumpDecorator.param_glossiness.numberValue = 0.53  ;
					bumpDecorator.param_noBumpProbability.numberValue=0.0;
					break;
				
				case STYLE_HALO_SPRAY:
					
					stationaryDecorator.active=true;
					splatterDecorator.active=false;
					
					brushEngine.textureScaleFactor = 2;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
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
					
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_SIZE_INV;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_multiples.lowerRangeValue = 2;
					spawnDecorator.param_multiples.upperRangeValue = 6;
					
					break;
				
				case STYLE_DROPPING:
					
					stationaryDecorator.active=true;
					callbackDecorator.active=true;
					splatterDecorator.active=false;
					
					brushEngine.textureScaleFactor = 2;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
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
					
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_SIZE_INV;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					break;
			}
			
			onPrecisionChanged();
			onIntensityChanged();
		}
		
		protected function onPrecisionChanged(event:Event = null):void
		{
			precision = param_precision.numberValue;
			
			spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -(120 + precision * 60);
			spawnDecorator.param_offsetAngleRange.upperDegreesValue = 120 + precision * 60;
			
			brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 2 + precision * 8;
			
			switch ( param_style.index )
			{
				case STYLE_HALO_SPRAY:
					
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 1 + precision * 15;
					
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.60;
					sizeDecorator.param_mappingRange.numberValue = 0.025+precision * 0.55;
					
					spawnDecorator.param_maxOffset.numberValue = 0.1+precision * 40;
					spawnDecorator.param_minOffset.numberValue = 0.1+precision * 30;
					
					break;
				case STYLE_DEFAULT:
					trace("STYLE DEFAULT");
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 2.5;
					
					sizeDecorator.param_mappingFactor.numberValue = 0.001 + precision * 0.93;
					
					splatterDecorator.param_splatFactor.numberValue = 0.01+0.9 * precision;
					spawnDecorator.param_minOffset.numberValue =   0.01+0.9 * precision;
					spawnDecorator.param_maxOffset.numberValue =  0.01+0.9 * precision;

					
					break;
				
				case STYLE_SPONGE:
					
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.4 + precision  *4;
					//brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 500;
					
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.93;
					break;
				
				case STYLE_DIGITAL:
					
					sizeDecorator.param_mappingFactor.numberValue = 0.01+ 0.99* precision;
					break;
				
				
				
				case STYLE_DROPPING:
					
					
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 10 + precision * 15;
					
					sizeDecorator.param_mappingFactor.numberValue = 0.05 + precision * 0.8;
					sizeDecorator.param_mappingRange.numberValue = 0.04+precision * 0.78;
					
					spawnDecorator.param_maxOffset.numberValue = 0.1+precision * 30;
					spawnDecorator.param_minOffset.numberValue = 0.1+precision * 5;
					spawnDecorator.param_multiples.lowerRangeValue = 1+precision * 3;
					spawnDecorator.param_multiples.upperRangeValue = 7+precision * 4;
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

					
					break;
				
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
			}
		}
		
		protected function onIntensityChanged(event:Event= null):void
		{
			var intensity:Number = param_intensity.numberValue;
			//RESET LAYER OPACITY
			//if (brushEngine is SprayCanBrush) (brushEngine as SprayCanBrush).param_strokeAlpha.numberValue = 1;
			
			switch ( param_style.index )
			{
				/*case STYLE_WET:
					colorDecorator.param_brushOpacity.numberValue = 0.25 + intensity * 0.75;
					break;*/
				/*case STYLE_DEFAULT:
					
					//ALPHA OF LAYER IS 1 HERE CAUSE WE DON'T WANT TO HAVE TRANSPARENCY ON THE LAYER SIDE
					(brushEngine  as SprayCanBrush).param_strokeAlpha.numberValue = 1;
					//CHANGE INDIVIDUAL BRUSH OPACITY
					colorDecorator.param_brushOpacity.numberValue = 0.3+intensity*0.7;
					bumpDecorator.param_bumpInfluence.numberValue = 0.15+intensity*0.25;
					bumpDecorator.param_bumpinessRange.numberValue = 0.25+intensity*0.15;
					
					break;*/
				
				//SIMPLE OPACITY BY DEFAULT
				default:
					
					(brushEngine as SprayCanBrush).param_strokeAlpha.numberValue = 0.1+param_intensity.numberValue*0.9;
					
				break;
				
				
				
				//bumpDecorator.param_glossiness.numberValue = 0.3 + 0.2 * intensity;
				//bumpDecorator.param_shininess.numberValue = 0.1 + 0.2 * intensity;
			}
			
			
		}
		
		protected function processPoints(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			
			var addedPoints:Vector.<SamplePoint> = new Vector.<SamplePoint>();
			
			var gyro:Matrix3D = GyroscopeManager.orientationMatrix;
			var vector:Vector.<Vector3D> = GyroscopeManager.orientationMatrix.decompose();
			
			//TESTING ON DESKTOP
			if(!CoreSettings.RUNNING_ON_iPAD)
			{vector[1].y=Math.random()*0.3-0.15;
			vector[1].x=0.7;}
			
			//ADD A BIT OF TURBULENCE
			vector[1].x+=Math.random()*0.3-0.15;
			vector[1].y+=Math.random()*0.3-0.15;
						
			for ( var i:int = 0; i < points.length; i++ )
			{

				
				if(i==0){
					
					if(Math.random()<0.03){
						//the way you stored the persistent points creates a memory leak.
						//you should use always use PathManager.recycleSamplePoint() before you overwrite
						//and old point, like this:
						if ( _persistentPoints[0] != null ) PathManager.recycleSamplePoint(_persistentPoints[0]);
						_persistentPoints[0] = points[0].getClone();
						_persistentPoints[0].size = 0.02*Math.random()+0.01 + precision*(Math.random()*0.05+0.02);
						SamplePoint(_persistentPoints[0]).colorsRGBA = _persistentPoints[0].colorsRGBA;
					}else {
						if(_persistentPoints[0]){
							_persistentPoints[0].x += vector[1].y*100*_persistentPoints[0].size;
							_persistentPoints[0].y += vector[1].x*100*_persistentPoints[0].size;
							points[0].x = _persistentPoints[0].x ;
							points[0].y = _persistentPoints[0].y ;
							points[0].size = _persistentPoints[0].size;
							//OVERRIDE COLORS
							for ( i = 0; i < 16; i++ )
							{
								points[0].colorsRGBA [i] = _persistentPoints[0].colorsRGBA[i];
							}
							
						}
					 	
					}
					
				}
				
				
				
			}
		
			return points;
		}
		
		override public function set eraserMode( enabled:Boolean ):void
		{
			super.eraserMode = (enabled);
			
			if ( enabled )
			{
				setStyleDefaults();
				
				brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.4 + precision  *4;
				//brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 500;
				
				//it's a good idea to put the eraser shape always as the last element into the shapes list
				//like that you will not have to update the index in case you are more regular shapes
				brushEngine.param_shapes.index = brushEngine.param_shapes.stringList.indexOf(EraserBrushShape.NAME);
				
				SprayCanBrush(brushEngine).param_eraserMode.booleanValue=true;
				
				gridDecorator.active=false;
				splatterDecorator.active=false;
				spawnDecorator.active=false;
				bumpDecorator.active=true;
					
				
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
				
				colorDecorator.param_pickRadius.lowerRangeValue = 0;
				colorDecorator.param_pickRadius.upperRangeValue = 0;
				colorDecorator.param_brushOpacity.numberValue = 0.8;
				colorDecorator.param_brushOpacityRange.numberValue = 0.1;
				colorDecorator.param_colorBlending.upperRangeValue = 0.98;
				colorDecorator.param_colorBlending.lowerRangeValue = 0.90;
				
				bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
				bumpDecorator.param_bumpInfluence.numberValue = 1;
				bumpDecorator.param_bumpiness.numberValue = 1 ;
				bumpDecorator.param_bumpinessRange.numberValue = 0.00 ;
				bumpDecorator.param_noBumpProbability.numberValue=0.0;
				//MAKE IT WET
				bumpDecorator.param_glossiness.numberValue = 0.10  ;
				
				
				
				onPrecisionChanged();
				onIntensityChanged()
			} else {
				SprayCanBrush(brushEngine).param_eraserMode.booleanValue=false;
				onStyleChanged();
			}
		}
	}
}