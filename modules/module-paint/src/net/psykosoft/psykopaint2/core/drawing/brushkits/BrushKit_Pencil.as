package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.SketchBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.SprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterMapping;
	import net.psykosoft.psykopaint2.core.drawing.paths.AbstractPathEngine;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.AbstractPointDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.CallbackDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.GridDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;

	public class BrushKit_Pencil extends BrushKit
	{
		
		private static const STYLE_DEFAULT:int=0;
		private static const STYLE_PASTEL:int=1;
		private static const STYLE_CHARCOAL:int = 2;
		private static const STYLE_SKETCH:int = 3;
		private static const STYLE_CRAYS:int = 4;
		private static const STYLE_QUILL:int = 5;
		
		
		private var sizeDecorator:SizeDecorator;
		private var colorDecorator:ColorDecorator;
		private var spawnDecorator:SpawnDecorator;
		private var param_style:PsykoParameter;
		private var param_precision:PsykoParameter;
		private var param_intensity:PsykoParameter;
		private var gridDecorator:GridDecorator;
		private var splatterDecorator:SplatterDecorator;
		private var bumpDecorator:BumpDecorator;
		
		
		public function BrushKit_Pencil()
		{
			isPurchasable = true;
			init(null);
		}
		
		override protected function init( xml:XML ):void
		{
			if (!_initialized ) BrushKit.init();
			
			name = "Pencils";
			
			brushEngine = new SketchBrush();
			(brushEngine as SketchBrush).param_surfaceRelief.numberValue = 0.2;
			brushEngine.param_quadOffsetRatio.numberValue = 0.25;
			brushEngine.param_bumpiness.numberValue = 0;
			brushEngine.param_bumpInfluence.numberValue = 0.8;
			brushEngine.param_glossiness.numberValue=1;
			brushEngine.param_shapes.stringList = Vector.<String>(["dots","line","pencilSketch","pencilSketch","paint1","paint1"]);
			
			var pathManager:PathManager = new PathManager( PathManager.ENGINE_TYPE_EXPERIMENTAL );
			brushEngine.pathManager = pathManager;
			pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			pathManager.pathEngine.outputStepSize.numberValue = 4;
			pathManager.pathEngine.sendTaps = false;
			
			
			sizeDecorator = new SizeDecorator();
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
			sizeDecorator.param_mappingFactor.minLimit = 0;
			sizeDecorator.param_mappingFactor.maxLimit = 2;
			sizeDecorator.param_mappingFactor.numberValue = 0.2;
			sizeDecorator.param_mappingRange.numberValue = 0.05;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
			pathManager.addPointDecorator( sizeDecorator );
			
			
			colorDecorator = new ColorDecorator();
			colorDecorator.param_pickRadius.lowerRangeValue = 0.4;
			colorDecorator.param_pickRadius.upperRangeValue = 0.4;
			colorDecorator.param_brushOpacity.numberValue = 0.7;
			colorDecorator.param_brushOpacityRange.numberValue = 0;
			colorDecorator.param_colorBlending.upperRangeValue = 0.1;
			colorDecorator.param_colorBlending.lowerRangeValue = 0.3;
			pathManager.addPointDecorator( colorDecorator );
			
			bumpDecorator = new BumpDecorator();
			bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM2;
			bumpDecorator.param_invertMapping.booleanValue = true;
			//PENCILS ARE FLAT
			bumpDecorator.param_bumpiness.numberValue = 0.01;
			bumpDecorator.param_bumpinessRange.numberValue = 0.0;
			bumpDecorator.param_bumpInfluence.numberValue = 0.5;
			bumpDecorator.param_noBumpProbability.numberValue = 0.0;
			//BUT A BIT GLOSSY
			bumpDecorator.param_glossiness.numberValue = 0.2;
			pathManager.addPointDecorator( bumpDecorator );
			
				
			spawnDecorator = new SpawnDecorator();
			spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_FIXED;
			spawnDecorator.param_multiples.lowerRangeValue = 8;
			spawnDecorator.param_multiples.upperRangeValue = 8;
			spawnDecorator.param_minOffset.numberValue = 0.5;
			spawnDecorator.param_maxOffset.numberValue = 12;
			spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -1;
			spawnDecorator.param_offsetAngleRange.upperDegreesValue = 1;
			spawnDecorator.param_brushAngleRange.lowerDegreesValue = -2;
			spawnDecorator.param_brushAngleRange.upperDegreesValue = 2;
			spawnDecorator.param_bristleVariation.numberValue = 1;
			pathManager.addPointDecorator( spawnDecorator );
			
			splatterDecorator = new SplatterDecorator();
			splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SIZE_INV;
			splatterDecorator.param_mappingMode.numberValue = 1;
			splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
			splatterDecorator.param_splatFactor.numberValue = 20;
			splatterDecorator.param_minOffset.numberValue = 0;
			splatterDecorator.param_offsetAngleRange.degrees = 360;
			splatterDecorator.param_sizeFactor.numberValue = 0;
			pathManager.addPointDecorator( splatterDecorator );
			
			
			gridDecorator = new GridDecorator();
			gridDecorator.param_angleStep.degrees = 90;
			gridDecorator.param_stepX.numberValue = 0;
			gridDecorator.param_stepY.numberValue = 0;
			
			gridDecorator.active = false;
			pathManager.addPointDecorator( gridDecorator );
			
			
			
			_parameterMapping = new PsykoParameterMapping();
			
			//UI elements:
			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["Pencil","Pastel","Charcoal","Sketch","Crayons","Quill"]);
			param_style.showInUI = 0;
			param_style.addEventListener( Event.CHANGE, onStyleChanged );
			_parameterMapping.addParameter(param_style);
			
			param_precision = new PsykoParameter( PsykoParameter.NumberParameter,"Precision",0.5,0,1);
			param_precision.showInUI = 1;
			param_precision.addEventListener( Event.CHANGE, onPrecisionChanged );
			_parameterMapping.addParameter(param_precision);
			
			param_intensity = new PsykoParameter( PsykoParameter.NumberParameter,"Intensity",0.9,0,1);
			param_intensity.showInUI = 2;
			param_intensity.addEventListener( Event.CHANGE, onIntensityChanged );
			_parameterMapping.addParameter(param_intensity);
			
			onPrecisionChanged(null);
			onIntensityChanged(null);
			
		}
		
		protected function onStyleChanged(event:Event):void
		{
			onPrecisionChanged(null);
			onIntensityChanged(null);
		}
		
		protected function onPrecisionChanged(event:Event):void
		{
			var precision:Number = param_precision.numberValue;
			
			//ASSIGN SAME INDEX FOR SHAPE AS STYLE
			brushEngine.param_shapes.index = param_style.index;
			
			//RESET DEFAULT SETTINGS
			gridDecorator.active = false;
			splatterDecorator.active=true;
			spawnDecorator.active=true;
			
			brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 4;
			brushEngine.param_curvatureSizeInfluence.numberValue = 1;
			brushEngine.pathManager.pathEngine.sendTaps = false;
			brushEngine.textureScaleFactor = 1;
			
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
			sizeDecorator.param_invertMapping.booleanValue = false;
			sizeDecorator.param_mappingFactor.minLimit = 0;
			sizeDecorator.param_mappingFactor.maxLimit = 2;
			sizeDecorator.param_mappingFactor.numberValue = 0.2;
			sizeDecorator.param_mappingRange.numberValue = 0.05;
			
			
			spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_FIXED;
			spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_FIXED;
			spawnDecorator.param_multiples.lowerRangeValue = 8;
			spawnDecorator.param_multiples.upperRangeValue = 8;
			spawnDecorator.param_minOffset.numberValue = 0.5;
			spawnDecorator.param_maxOffset.numberValue = 12;
			spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -1;
			spawnDecorator.param_offsetAngleRange.upperDegreesValue = 1;
			spawnDecorator.param_brushAngleRange.lowerDegreesValue = -2;
			spawnDecorator.param_brushAngleRange.upperDegreesValue = 2;
			spawnDecorator.param_bristleVariation.numberValue = 1;
			spawnDecorator.param_autorotate.booleanValue=true;
			
			colorDecorator.param_pickRadius.lowerRangeValue = 0.4;
			colorDecorator.param_pickRadius.upperRangeValue = 0.4;
			colorDecorator.param_brushOpacity.numberValue = 0.7;
			colorDecorator.param_brushOpacityRange.numberValue = 0;
			colorDecorator.param_colorBlending.upperRangeValue = 0.1;
			colorDecorator.param_colorBlending.lowerRangeValue = 0.3;
			
			bumpDecorator.param_glossiness.numberValue = 0.2;
			

			splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SIZE_INV;
			splatterDecorator.param_mappingMode.numberValue = 1;
			splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
			splatterDecorator.param_splatFactor.numberValue = 20;
			splatterDecorator.param_minOffset.numberValue = 0;
			splatterDecorator.param_offsetAngleRange.degrees = 360;
			splatterDecorator.param_sizeFactor.numberValue = 0;
			
			
			
			switch ( param_style.index )
			{
				case STYLE_DEFAULT:
					splatterDecorator.active=false;
					
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.7;
					
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_STRONG_OUT;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_RANDOM;
					sizeDecorator.param_invertMapping.booleanValue = false;
					sizeDecorator.param_mappingRange.numberValue = 0.01;
					sizeDecorator.param_mappingFactor.numberValue = 0.04;
					sizeDecorator.param_maxSpeed.numberValue = 40;
					
					colorDecorator.param_brushOpacity.numberValue = 1;
					colorDecorator.param_brushOpacityRange.numberValue = 0.15;
					colorDecorator.param_colorBlending.upperRangeValue = 0.6;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.9;
					colorDecorator.param_pickRadius.lowerRangeValue = 0.05;
					colorDecorator.param_pickRadius.upperRangeValue = 0.1;
					
					//spawnDecorator.param_maxOffset.numberValue = 1 + 12* precision;
					
					spawnDecorator.param_sizeMappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CUBIC_OUT;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_FIXED;
					spawnDecorator.param_multiplesMode.index  = SpawnDecorator.INDEX_MODE_SIZE;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
					spawnDecorator.param_multiples.lowerRangeValue = 3+precision * 2;
					spawnDecorator.param_multiples.upperRangeValue = 3+precision * 4;
					spawnDecorator.param_maxOffset.numberValue = 0.01+precision * 12;
					spawnDecorator.param_minOffset.numberValue = 0.01+precision * 12;
					
					bumpDecorator.param_glossiness.numberValue = 0.9;
					
				

					break;
				case STYLE_PASTEL:
					brushEngine.param_curvatureSizeInfluence.numberValue = 1;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 1.5;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_splatFactor.numberValue = 0.01+ 2 * precision;
					splatterDecorator.param_brushAngleOffsetRange.degrees = 2;
					
					
					//PASTELS SHOULD BE WET: TODO
					//NO DEPTH BUT WET
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_SPEED;					
					sizeDecorator.param_mappingFactor.numberValue = 0.25;
					sizeDecorator.param_mappingRange.numberValue = 0.09;
					
					colorDecorator.param_brushOpacity.numberValue = 0.75;
					colorDecorator.param_brushOpacityRange.numberValue = 0.20;
					colorDecorator.param_pickRadius.lowerRangeValue = 0.05;
					colorDecorator.param_pickRadius.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.2;
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_PRESSURE_SPEED;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -30;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 30;
					spawnDecorator.param_minOffset.numberValue = 0.01+precision * 1;
					spawnDecorator.param_maxOffset.numberValue = 0.01+precision * 20;
					spawnDecorator.param_multiples.lowerRangeValue = 4+precision * 1;
					spawnDecorator.param_multiples.upperRangeValue = 4+precision * 5;
					
					break;
				case STYLE_PASTEL:
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
					break;
				case STYLE_CHARCOAL:
					
					brushEngine.param_curvatureSizeInfluence.numberValue = 1;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 1;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_splatFactor.numberValue = 0.01+ 2 * precision;
					splatterDecorator.param_brushAngleOffsetRange.degrees = 5;
					
					
					
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;					
					sizeDecorator.param_mappingFactor.numberValue = 0.3;
					sizeDecorator.param_mappingRange.numberValue = 0.05;
					//sizeDecorator.param_mappingFactor.numberValue = 0.25;
					//sizeDecorator.param_mappingRange.numberValue = 0.09;
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.01;
					colorDecorator.param_pickRadius.upperRangeValue = 0.05;
					colorDecorator.param_colorBlending.upperRangeValue = 0.6;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.1;
					colorDecorator.param_brushOpacity.numberValue = 0.9;
					colorDecorator.param_brushOpacityRange.numberValue = 0.1;
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_FIXED;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -80;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 80;
					spawnDecorator.param_minOffset.numberValue = 0.01+precision * 8;
					spawnDecorator.param_maxOffset.numberValue = 0.01+precision * 20;
					spawnDecorator.param_multiples.lowerRangeValue = 3+precision * 2;
					spawnDecorator.param_multiples.upperRangeValue = 3+precision * 5;
					

					
					break;
				
				case STYLE_SKETCH:
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 1;
					
					
					sizeDecorator.param_mappingRange.numberValue = 0.01;
					sizeDecorator.param_mappingFactor.numberValue = 0.4;
					
					spawnDecorator.param_minOffset.numberValue =  5* precision;
					spawnDecorator.param_maxOffset.numberValue = 1 + 23* precision;
					spawnDecorator.param_brushAngleRange.degrees=360;
					spawnDecorator.param_multiples.lowerRangeValue = 8;
					spawnDecorator.param_multiples.upperRangeValue = 8;
					
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -1;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 1;
					spawnDecorator.param_brushAngleRange.lowerDegreesValue = -2;
					spawnDecorator.param_brushAngleRange.upperDegreesValue = 2;
					spawnDecorator.param_bristleVariation.numberValue = 1;
					spawnDecorator.active=true;
					
					splatterDecorator.active=false;
					
									
					gridDecorator.active = true;
					gridDecorator.param_stepX.numberValue = 0;
					gridDecorator.param_stepY.numberValue = 0;
					gridDecorator.param_angleStep.degrees = 45;
					
					
					
				break;
				
				case STYLE_QUILL:
					trace("STYLE STYLE_QUILL");
					
					//MAKE IT SMALLER ON STEEP CORNERS
					brushEngine.param_curvatureSizeInfluence.numberValue = 2;
					
					
					//SIZE VARY ON SPEED
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_OUT;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_SPEED;
					sizeDecorator.param_mappingFactor.numberValue = 0.05+0.6*precision;
					sizeDecorator.param_mappingRange.numberValue = 0.02+0.5*precision;
					sizeDecorator.param_maxSpeed.numberValue = 50;
					
					/*bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_SPEED;
					bumpDecorator.param_bumpInfluence.numberValue = 0.25;
					bumpDecorator.param_bumpiness.numberValue = 0.15 ;
					bumpDecorator.param_bumpinessRange.numberValue = -0.16 ;
					bumpDecorator.param_glossiness.numberValue = 0.8  ;
					bumpDecorator.param_shininess.numberValue = 0.25  ;*/
					
					colorDecorator.param_colorBlending.upperRangeValue = 0.90;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.85;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_splatFactor.numberValue = 0.01 ;
					
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_FIXED;
					spawnDecorator.param_maxSize.numberValue = 2+precision*2;
					spawnDecorator.param_multiples.lowerRangeValue = 1;
					spawnDecorator.param_multiples.upperRangeValue = 1;
					spawnDecorator.param_maxOffset.numberValue = 0.02+precision*10;
					spawnDecorator.param_minOffset.numberValue = 0.02+precision*10;
					spawnDecorator.param_autorotate.booleanValue=true;
					break;
				case STYLE_CRAYS:
					trace("STYLE STYLE_COOLINK2");
					
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 3;
					
					//SIZE VARY ON SPEED
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFactor.numberValue = 1.2;
					sizeDecorator.param_mappingRange.numberValue = 1.18;
					sizeDecorator.param_maxSpeed.numberValue = 200;
					//sizeDecorator.pa
					
					colorDecorator.param_colorBlending.upperRangeValue = 0.90;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.05;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_FIXED;
					splatterDecorator.param_splatFactor.numberValue = 0.01+precision*1;
					splatterDecorator.param_minOffset.numberValue = 0.01+precision*1;
					splatterDecorator.param_offsetAngleRange.degrees = 3;
					
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_FIXED;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_PRESSURE_SPEED;
					spawnDecorator.param_maxSize.numberValue = 2+precision*2;
					spawnDecorator.param_multiples.lowerRangeValue = 1+precision*6;
					spawnDecorator.param_multiples.upperRangeValue = 1+precision*6;
					spawnDecorator.param_maxOffset.numberValue = 0.02+precision*20;
					spawnDecorator.param_minOffset.numberValue = 0.02+precision*16;
					spawnDecorator.param_autorotate.booleanValue=true;
					
					
					
					
					break;
				
				
				
				
				/*case STYLE_PENCIL_SKETCH2:
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
					
					break;*/
				
			}
			
		}
		
		protected function onIntensityChanged(event:Event):void
		{
			var intensity:Number = param_intensity.numberValue;
			colorDecorator.param_brushOpacity.numberValue = 0.30 + intensity *0.7;
			
			(brushEngine as SketchBrush).param_strokeAlpha.numberValue = 0.5+param_intensity.numberValue*0.5;
		}
	}
}