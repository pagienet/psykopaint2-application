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
		private static const STYLE_PENCIL_SKETCH:int=1;
		private static const STYLE_AUTO_GRID:int = 2;
		private static const STYLE_SPRAY:int = 3;
		//private static const STYLE_ROUGH_SQUARE:int = 1;
		
		
		private var sizeDecorator:SizeDecorator;
		private var colorDecorator:ColorDecorator;
		private var spawnDecorator:SpawnDecorator;
		private var param_style:PsykoParameter;
		private var param_precision:PsykoParameter;
		private var param_intensity:PsykoParameter;
		private var gridDecorator:GridDecorator;
		
		
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
			brushEngine.param_bumpiness.numberValue = 0;
			brushEngine.param_quadOffsetRatio.numberValue = 0.25;
			brushEngine.param_shapes.stringList = Vector.<String>(["pencilSketch","line","line","noisy"]);
			
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
			
			gridDecorator = new GridDecorator();
			gridDecorator.param_angleStep.degrees = 45;
			gridDecorator.param_stepX.numberValue = 0;
			gridDecorator.param_stepY.numberValue = 0;
			
			gridDecorator.active = false;
			pathManager.addPointDecorator( gridDecorator );
			
			
			
			_parameterMapping = new PsykoParameterMapping();
			
			//UI elements:
			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["pencil","Sketch","grid pen","Sprayper"]);
			param_style.showInUI = 0;
			param_style.addEventListener( Event.CHANGE, onStyleChanged );
			_parameterMapping.addParameter(param_style);
			
			param_precision = new PsykoParameter( PsykoParameter.NumberParameter,"Precision",0.25,0,1);
			param_precision.showInUI = 1;
			param_precision.addEventListener( Event.CHANGE, onPrecisionChanged );
			_parameterMapping.addParameter(param_precision);
			
			param_intensity = new PsykoParameter( PsykoParameter.NumberParameter,"Intensity",0.9,0,1);
			param_intensity.showInUI = 2;
			param_intensity.addEventListener( Event.CHANGE, onIntensityChanged );
			_parameterMapping.addParameter(param_intensity);
			
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
			
			brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 4;
			brushEngine.pathManager.pathEngine.sendTaps = false;
			brushEngine.textureScaleFactor = 1;
			
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
			
			colorDecorator.param_pickRadius.lowerRangeValue = 0.4;
			colorDecorator.param_pickRadius.upperRangeValue = 0.4;
			colorDecorator.param_brushOpacity.numberValue = 0.7;
			colorDecorator.param_brushOpacityRange.numberValue = 0;
			colorDecorator.param_colorBlending.upperRangeValue = 0.1;
			colorDecorator.param_colorBlending.lowerRangeValue = 0.3;
			
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
			sizeDecorator.param_invertMapping.booleanValue = false;
			sizeDecorator.param_mappingFactor.minLimit = 0;
			sizeDecorator.param_mappingFactor.maxLimit = 2;
			sizeDecorator.param_mappingFactor.numberValue = 0.2;
			sizeDecorator.param_mappingRange.numberValue = 0.05;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
			
			
			switch ( param_style.index )
			{
				case STYLE_DEFAULT:
					
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_OUT;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_invertMapping.booleanValue = true;
					sizeDecorator.param_mappingFactor.numberValue = 0.4;
					
					colorDecorator.param_brushOpacity.numberValue = 0.9;
					colorDecorator.param_brushOpacityRange.numberValue = 0;
					colorDecorator.param_colorBlending.upperRangeValue = 0.6;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.9;
					
					spawnDecorator.param_maxOffset.numberValue = 1 + 12* precision;
					spawnDecorator.param_multiples.lowerRangeValue = 2;
					spawnDecorator.param_multiples.upperRangeValue = 2;

					break;
				case STYLE_SPRAY:
					
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_OUT;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
					sizeDecorator.param_mappingFactor.minLimit = 0;
					sizeDecorator.param_mappingFactor.maxLimit = 2;
					sizeDecorator.param_mappingFactor.numberValue = 0.02+ 10* precision;
					sizeDecorator.param_mappingRange.numberValue = 0.06;
					brushEngine.textureScaleFactor = 2;
					
					
					colorDecorator.param_brushOpacityRange.numberValue = 0.25;
					colorDecorator.param_colorBlending.upperRangeValue = 0.98;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.90;
					
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_FIXED;
					spawnDecorator.param_multiplesMode.index  = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_maxOffset.numberValue = 4;
					spawnDecorator.param_minOffset.numberValue = 4;
					spawnDecorator.param_multiples.lowerRangeValue = 2;
					spawnDecorator.param_multiples.upperRangeValue = 2;
					
					break;
				case STYLE_PENCIL_SKETCH:
					//splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_FIXED;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
					sizeDecorator.param_mappingFactor.numberValue = 0.4;
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.05;
					colorDecorator.param_pickRadius.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.2;
					brushEngine.param_curvatureSizeInfluence.numberValue = 1;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_FIXED;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -30;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 30;
					
					break;
				case STYLE_AUTO_GRID:
					spawnDecorator.param_maxOffset.numberValue = 1 + 23* precision;
					//gridDecorator.active = (param_style.index == 1);
					sizeDecorator.param_mappingFactor.numberValue = 0.4;
					gridDecorator.active = true;
					
				break;
			}
			
		}
		
		protected function onIntensityChanged(event:Event):void
		{
			var intensity:Number = param_intensity.numberValue;
			colorDecorator.param_brushOpacity.numberValue = 0.25 + intensity * 0.75;
		}
	}
}