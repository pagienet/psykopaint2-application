package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import com.greensock.easing.Expo;
	
	import flash.display3D.Context3DBlendFactor;
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.SketchBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.SprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterMapping;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterProxy;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.AbstractPointDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.CallbackDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.GridDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.PointDecoratorFactory;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;

	public class BrushKit_SprayCan extends BrushKit
	{
		private static const STYLE_DEFAULT:int=0;
		private static const STYLE_ROUGH_SQUARE:int = 1;
		private static const STYLE_SIMPLE_SPRAY:int = 2;
		private static const STYLE_NOISY:int = 3;
		private static const STYLE_PENCIL_SKETCH2:int =4;
		private static const STYLE_COOLINK:int = 5;
		private static const STYLE_PIXELATE:int = 6;
		private static const STYLE_PAINTSTROKES:int = 7;
		private static const STYLE_HARD_ROUND_CIRCLE:int = 8;
		
		
		
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
			brushEngine.param_bumpiness.numberValue = 0;
			brushEngine.param_bumpInfluence.numberValue = 0.8;
			brushEngine.param_quadOffsetRatio.numberValue = 0.4;
			brushEngine.param_shapes.stringList = Vector.<String>(["noisy","almost circular rough","splatspray","noisy","dots","paint1","paint1","paint1","almost circular hard"]);
			
			
			
			var pathManager:PathManager = new PathManager( PathManager.ENGINE_TYPE_EXPERIMENTAL );
			brushEngine.pathManager = pathManager;
			pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			pathManager.pathEngine.outputStepSize.numberValue = 4;
			pathManager.pathEngine.sendTaps = false;
			
			sizeDecorator = new SizeDecorator();
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
			sizeDecorator.param_mappingFactor.minLimit = 0.01;
			sizeDecorator.param_mappingFactor.maxLimit = 2;
			sizeDecorator.param_mappingFactor.numberValue = 0.2;
			sizeDecorator.param_mappingRange.numberValue = 0.05;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
			pathManager.addPointDecorator( sizeDecorator );
			
			splatterDecorator = new SplatterDecorator();
			splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SIZE_INV;
			splatterDecorator.param_mappingMode.numberValue = 1;
			splatterDecorator.param_mappingFunction.index = SplatterDecorator.INDEX_MAPPING_LINEAR;
			splatterDecorator.param_splatFactor.numberValue = 20;
			splatterDecorator.param_minOffset.numberValue = 0;
			splatterDecorator.param_offsetAngleRange.degrees = 360;
			splatterDecorator.param_sizeFactor.numberValue = 0;
			//pathManager.addPointDecorator( splatterDecorator );
			
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
			gridDecorator.param_stepX.numberValue = 32;
			gridDecorator.param_stepY.numberValue = 32;
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
			pathManager.addPointDecorator( callbackDecorator );
			
			_parameterMapping = new PsykoParameterMapping();
			
			//UI elements:
			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["Spray","sponge","spray","SWITCH ENGINE","sketch","line","line","basic","basic"]);
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
			
			
			onStyleChanged(null);
		}
		
		protected function onStyleChanged(event:Event):void
		{
			
			brushEngine.param_shapes.index = param_style.index;			
			onPrecisionChanged(null);
			onIntensityChanged(null);
		}
		
		protected function onPrecisionChanged(event:Event):void
		{
			var precision:Number = param_precision.numberValue;
			
			
			gridDecorator.active = false;
			spawnDecorator.active = true;
			callbackDecorator.active = false;
			
			//DEFAULTS			
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
			sizeDecorator.param_mappingFactor.numberValue = 0.08;
			sizeDecorator.param_mappingRange.numberValue = 0.04;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
			
			splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_FIXED;
			splatterDecorator.param_mappingMode.numberValue = 1;
			splatterDecorator.param_mappingFunction.index = SplatterDecorator.INDEX_MAPPING_LINEAR;
			splatterDecorator.param_splatFactor.numberValue = 20;
			splatterDecorator.param_minOffset.numberValue = 0;
			splatterDecorator.param_offsetAngleRange.degrees = 360;
			splatterDecorator.param_sizeFactor.numberValue = 0;
			splatterDecorator.param_brushAngleOffsetRange.degrees =  0;
			
			bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
			bumpDecorator.param_invertMapping.booleanValue = true;
			bumpDecorator.param_bumpiness.numberValue = 0.5;
			bumpDecorator.param_bumpinessRange.numberValue = 0.5;
			bumpDecorator.param_bumpInfluence.numberValue = 0.8;
			bumpDecorator.param_noBumpProbability.numberValue = 0.8;
			
			spawnDecorator.param_multiples.upperRangeValue = 1;
			spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_FIXED;
			spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_FIXED;
			//spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
			//spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
			spawnDecorator.param_maxSize.numberValue = 0.12;
			spawnDecorator.param_minOffset.numberValue = 0;
			spawnDecorator.param_maxOffset.numberValue = 16;
			spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -(120 + precision * 60);
			spawnDecorator.param_offsetAngleRange.upperDegreesValue = 120 + precision * 60;
			
			gridDecorator.param_stepX.numberValue = 32;
			gridDecorator.param_stepY.numberValue = 32;
			gridDecorator.param_angleStep.degrees = 90;
			
			
			colorDecorator.param_brushOpacity.numberValue = 1;
			colorDecorator.param_brushOpacityRange.numberValue = 0;
			colorDecorator.param_colorBlending.upperRangeValue = 1;
			colorDecorator.param_colorBlending.lowerRangeValue = 0.2;
			colorDecorator.param_pickRadius.lowerRangeValue = 0.25;
			colorDecorator.param_pickRadius.upperRangeValue = 0.33;
			colorDecorator.param_smoothFactor.lowerRangeValue = 0.8;
			
			//CHANGE ENGINE
			//brushEngine = _sprayCanBrushEngine;
			brushEngine.textureScaleFactor = 1;
			brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 8;
			brushEngine.param_quadOffsetRatio.numberValue = 0;
			//brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.01 + precision * 0.3;
			
			
			
			
			switch ( param_style.index )
			{
				case STYLE_DEFAULT:
					trace("STYLE DEFAULT");
					spawnDecorator.active = false;
					splatterDecorator.active = false;
					brushEngine.textureScaleFactor = 2.5;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 ;

					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_FIXED;
					bumpDecorator.param_bumpInfluence.numberValue = 0.45;
					bumpDecorator.param_bumpiness.numberValue = 0.15 ;
					bumpDecorator.param_bumpinessRange.numberValue = -0.20 ;
					bumpDecorator.param_glossiness.numberValue = 0.8  ;
					bumpDecorator.param_shininess.numberValue = 0.25  ;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
					sizeDecorator.param_mappingRange.numberValue = 0.001;
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.93;
					
					
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.2;
					colorDecorator.param_pickRadius.lowerRangeValue = 0.3;
					colorDecorator.param_pickRadius.upperRangeValue = 0.35;
					
					
					
					/*
					//SIZE VARY ON SPEED
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
					//sizeDecorator.param_mappingFactor.numberValue = 0.2+precision*1;
					sizeDecorator.param_mappingRange.numberValue = 0;
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.93;
					
					//sizeDecorator.param_mappingFactor.numberValue = 1;
					//sizeDecorator.param_mappingRange.numberValue = 10;
					//sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
					//sizeDecorator.param_mappingFactor.numberValue = 3;
					//sizeDecorator.param_mappingRange.numberValue = 1;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SPEED;
					splatterDecorator.param_splatFactor.numberValue = 0.2+10 * precision;
					//splatterDecorator.param_splatFactor.numberValue = 1;
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_FIXED;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_FIXED;
					spawnDecorator.param_maxSize.numberValue = 0.3;
					spawnDecorator.param_multiples.lowerRangeValue = 1;
					spawnDecorator.param_multiples.upperRangeValue = 1;
					spawnDecorator.param_maxOffset.numberValue = precision *5;
					spawnDecorator.param_minOffset.numberValue = 2;
					spawnDecorator.param_autorotate.booleanValue = false;
					spawnDecorator.param_bristleVariation.numberValue = 0.2;
					
					
					colorDecorator.param_colorBlending.upperRangeValue = 0.99;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.97;
					
					brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 3 - precision * 2;*/
					
					
					break;
				case STYLE_NOISY:
					
					
					//CHANGE ENGINE
					//brushEngine = _sketchBrushEngine;
					//_sketchBrushEngine.param_surfaceRelief.numberValue = 0.2;
					//_sketchBrushEngine.param_shapes.index = param_style.index;
					//trace("_sketchBrushEngine.param_shapes "+_sketchBrushEngine.param_shapes.stringList.join(","))
					
					//NOT TO FORGET TO ASSING THE RIGHT INDEX
					//_sketchBrushEngine.param_shapes.index = param_style.index;
					//_sketchBrushEngine.param_bumpiness.numberValue = 0;
					//_sketchBrushEngine.param_quadOffsetRatio.numberValue = 0.25;
					//_sketchBrushEngine.textureScaleFactor = 2;
					
					
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_FIXED;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -1;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 1;
					spawnDecorator.param_brushAngleRange.lowerDegreesValue = -2;
					spawnDecorator.param_brushAngleRange.upperDegreesValue = 2;
					spawnDecorator.param_bristleVariation.numberValue = 1;
					spawnDecorator.param_multiplesMode.index  = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_maxOffset.numberValue = 4;
					spawnDecorator.param_minOffset.numberValue = 4;
					spawnDecorator.param_multiples.lowerRangeValue = 2;
					spawnDecorator.param_multiples.upperRangeValue = 2;
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.4;
					colorDecorator.param_pickRadius.upperRangeValue = 0.4;
					colorDecorator.param_brushOpacity.numberValue = 0.7;
					colorDecorator.param_brushOpacityRange.numberValue = 0;
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.3;
					colorDecorator.param_brushOpacityRange.numberValue = 0.25;
					colorDecorator.param_colorBlending.upperRangeValue = 0.98;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.90;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_invertMapping.booleanValue = false;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_OUT;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
					sizeDecorator.param_mappingFactor.minLimit = 0;
					sizeDecorator.param_mappingFactor.maxLimit = 2;
					sizeDecorator.param_mappingFactor.numberValue = 0.02+ 10* precision;
					sizeDecorator.param_mappingRange.numberValue = 0.06;
					

					//NO SPLATTING
					splatterDecorator.param_splatFactor.numberValue = 0;

					break;
				
				case STYLE_PAINTSTROKES:
					brushEngine.param_quadOffsetRatio.numberValue = 0.4;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 3;
					sizeDecorator.param_mappingFactor.numberValue = 0.05 + precision * 0.25;
					sizeDecorator.param_mappingRange.numberValue = 0.01 + precision * 0.12;
					spawnDecorator.param_maxSize.numberValue = 0.05 + precision * 0.36;
					spawnDecorator.param_maxOffset.numberValue = 16 + precision * 40;
					break;
				
				case STYLE_SIMPLE_SPRAY:
					
					brushEngine.textureScaleFactor = 2.5;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM2;
					bumpDecorator.param_bumpInfluence.numberValue = 0.55;
					bumpDecorator.param_bumpiness.numberValue = 0.15 ;
					bumpDecorator.param_bumpinessRange.numberValue = 0.3 ;
					bumpDecorator.param_glossiness.numberValue = 0.55  ;
					bumpDecorator.param_shininess.numberValue = 0.86  ;
					
					
					colorDecorator.param_colorBlending.upperRangeValue = 0.9;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.85;
					colorDecorator.param_pickRadius.lowerRangeValue = 0.3;
					colorDecorator.param_pickRadius.upperRangeValue = 0.33;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
					sizeDecorator.param_mappingFactor.numberValue = 0.05 + precision * (0.95)*1;
					sizeDecorator.param_mappingRange.numberValue = 0;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SPEED;
					splatterDecorator.param_splatFactor.numberValue = 0.1 * precision;
					
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_FIXED;
					spawnDecorator.param_maxOffset.numberValue = 1+precision * 1;
					spawnDecorator.param_minOffset.numberValue = 1+precision * 1;
					spawnDecorator.param_maxSize.numberValue = 1+precision*5;
					spawnDecorator.param_multiples.lowerRangeValue = 0;
					spawnDecorator.param_multiples.upperRangeValue = 10;
					
					
					break;
				
				case STYLE_HARD_ROUND_CIRCLE:
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_FIXED;
					bumpDecorator.param_bumpInfluence.numberValue = 0.45;
					bumpDecorator.param_bumpiness.numberValue = 0.15 ;
					bumpDecorator.param_bumpinessRange.numberValue = -0.20 ;
					bumpDecorator.param_glossiness.numberValue = 0.8  ;
					bumpDecorator.param_shininess.numberValue = 0.25  ;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
					sizeDecorator.param_mappingRange.numberValue = 0;
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.93;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SPEED;
					splatterDecorator.param_splatFactor.numberValue = 10 * precision;
					
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.2;
					colorDecorator.param_pickRadius.lowerRangeValue = 0.3;
					colorDecorator.param_pickRadius.upperRangeValue = 0.35;
					
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_SPEED;
					spawnDecorator.param_maxOffset.numberValue = precision * 4;
					break;
				
				case STYLE_COOLINK:
					trace("STYLE COOL INK");
					//SIZE VARY ON SPEED
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_SPEED;
					sizeDecorator.param_mappingFactor.numberValue = 3;
					sizeDecorator.param_mappingRange.numberValue = 1;
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_SPEED;
					bumpDecorator.param_bumpInfluence.numberValue = 0.25;
					bumpDecorator.param_bumpiness.numberValue = 0.15 ;
					bumpDecorator.param_bumpinessRange.numberValue = -0.16 ;
					bumpDecorator.param_glossiness.numberValue = 0.8  ;
					bumpDecorator.param_shininess.numberValue = 0.25  ;
					
					
					colorDecorator.param_colorBlending.upperRangeValue = 0.90;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.85;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_splatFactor.numberValue = 0.02+precision*0.6 ;
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_FIXED;
					spawnDecorator.param_maxSize.numberValue = 2+precision*2;
					spawnDecorator.param_multiples.lowerRangeValue = 1;
					spawnDecorator.param_multiples.upperRangeValue = 1;
					spawnDecorator.param_maxOffset.numberValue = 0.02+precision*10;
					spawnDecorator.param_minOffset.numberValue = 0.02+precision*10;
					spawnDecorator.param_autorotate.booleanValue=false;
					break;
				
				
				case STYLE_ROUGH_SQUARE:
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.93;
					splatterDecorator.param_splatFactor.numberValue = 10 * precision;
					spawnDecorator.param_maxOffset.numberValue = precision * 12;
					break;
				
				
				case STYLE_PIXELATE:
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.05;
					colorDecorator.param_pickRadius.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.2;
					
					brushEngine.param_curvatureSizeInfluence.numberValue = 0;
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SIZE_INV;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -30;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 30;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
					
					
					gridDecorator.active = true;
					spawnDecorator.active = false;
					callbackDecorator.active = true;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
					sizeDecorator.param_mappingRange.numberValue = 0;
					brushEngine.param_curvatureSizeInfluence.numberValue = 0;
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.1;
					colorDecorator.param_pickRadius.upperRangeValue = 0.2;
					
					sizeDecorator.param_mappingFactor.numberValue = (4 / 62) + precision * (58/62);
					sizeDecorator.param_mappingRange.numberValue = 0;
					gridDecorator.param_stepX.numberValue = gridDecorator.param_stepY.numberValue = ((4 + 58 * precision) * 2);
					break;
				
				/*case STYLE_PENCIL_SKETCH:
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 2;
					
					sizeDecorator.param_mappingFactor.numberValue = 0.07;
					sizeDecorator.param_mappingRange.numberValue = 0.02;
					
					spawnDecorator.param_maxSize.numberValue = 0.5;
					spawnDecorator.param_maxOffset.numberValue = 0.25 + precision * 4
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
					spawnDecorator.param_multiples.upperRangeValue = 2 + precision * 12;
					
					splatterDecorator.param_splatFactor.numberValue = 2 * precision;
					splatterDecorator.param_brushAngleOffsetRange.degrees = precision * 10;
					break;*/
				case STYLE_PENCIL_SKETCH2:
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.2 + precision;
					
					sizeDecorator.param_mappingFactor.numberValue = 0.03 +precision * 0.1;
					sizeDecorator.param_mappingRange.numberValue = 0.02;
					
					spawnDecorator.param_maxSize.numberValue = 1;
					spawnDecorator.param_maxOffset.numberValue = 0.25 + precision * 4
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
					spawnDecorator.param_multiples.upperRangeValue = 1 + precision * 10;
					
					splatterDecorator.param_splatFactor.numberValue = 4 * precision;
					splatterDecorator.param_brushAngleOffsetRange.degrees = precision * 10;
					
					
					
					
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
				case STYLE_NOISY:
					colorDecorator.param_brushOpacity.numberValue = 0.25 + intensity * 0.75;
					break;
				case STYLE_DEFAULT:
					
					//ALPHA OF LAYER IS 1 HERE CAUSE WE DON'T WANT TO HAVE TRANSPARENCY ON THE LAYER SIDE
					(brushEngine  as SprayCanBrush).param_strokeAlpha.numberValue = 1;
					//CHANGE INDIVIDUAL BRUSH OPACITY
					colorDecorator.param_brushOpacity.numberValue = 0.1+intensity*0.9;
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
				bumpDecorator.param_bumpInfluence.numberValue = 1 - intensity;
				bumpDecorator.param_bumpiness.numberValue = 0;
				bumpDecorator.param_bumpinessRange.numberValue = 0;
				
			} 
		}
		
		protected function processPoints(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			//only active for pixelate style
			for ( var i:int = 0; i < points.length; i++ )
			{
				if ( Math.random() < 0.10 )
				{
					points[i].x += (Math.random()-Math.random()) * gridDecorator.param_stepX.numberValue;
					points[i].y += (Math.random()-Math.random()) * gridDecorator.param_stepY.numberValue;
				}
			}
			
			return points;
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