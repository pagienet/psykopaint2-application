package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import flash.display3D.Context3DBlendFactor;
	import flash.events.Event;
	
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
		private static const STYLE_HARD_ROUND_CIRCLE:int = 0;
		private static const STYLE_ROUGH_SQUARE:int = 1;
		private static const STYLE_SPLAT_SPRAY:int = 2;
		private static const STYLE_PENCIL_SKETCH:int = 3;
		private static const STYLE_PENCIL_SKETCH2:int =4;
		private static const STYLE_WHATEVER:int = 5;
		private static const STYLE_PIXELATE:int = 6;
		private static const STYLE_PAINTSTROKES:int = 7;
		
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
		
		public function BrushKit_SprayCan()
		{
			init( null );
		}
		
		override protected function init( xml:XML ):void
		{
			if (!_initialized ) BrushKit.init();
			
			name = "Spraycan";
			
			brushEngine = new SprayCanBrush();
			brushEngine.param_bumpiness.numberValue = 0;
			brushEngine.param_bumpInfluence.numberValue = 0.8;
			brushEngine.param_quadOffsetRatio.numberValue = 0.4;
			brushEngine.param_shapes.stringList = Vector.<String>(["almost circular hard","almost circular rough","splatspray","line","dots","basic","paint1"]);
			
			var pathManager:PathManager = new PathManager( PathManager.ENGINE_TYPE_EXPERIMENTAL );
			brushEngine.pathManager = pathManager;
			pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			
			sizeDecorator = new SizeDecorator();
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
			sizeDecorator.param_mappingFactor.numberValue = 0.08;
			sizeDecorator.param_mappingRange.numberValue = 0.04;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
			pathManager.addPointDecorator( sizeDecorator );
			
			splatterDecorator = new SplatterDecorator();
			splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SIZE_INV;
			splatterDecorator.param_mappingMode.numberValue = 1;
			splatterDecorator.param_mappingFunction.index = SplatterDecorator.INDEX_MAPPING_LINEAR;
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
			spawnDecorator.param_multiples.upperRangeValue = 16;
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
			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["basic","splat","sketch","sketch","sketch","line"]);
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
			
			(brushEngine as SprayCanBrush).param_strokeAlpha.numberValue = param_intensity.numberValue;
			onStyleChanged(null);
		}
		
		protected function onStyleChanged(event:Event):void
		{
			if (  param_style.index == STYLE_PAINTSTROKES)
			{
				brushEngine.param_quadOffsetRatio.numberValue = 0.4;
			} else {
				brushEngine.param_quadOffsetRatio.numberValue = 0;
			}
			brushEngine.param_shapes.index = param_style.index;
			
			gridDecorator.active = false;
			spawnDecorator.active = true;
			
			if (  param_style.index != STYLE_PIXELATE )
			{
				sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
				colorDecorator.param_pickRadius.lowerRangeValue = 0.25;
				colorDecorator.param_pickRadius.upperRangeValue = 0.33;
				
				splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SIZE_INV;
			} 
			bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM2;
			brushEngine.param_curvatureSizeInfluence.numberValue = 0;
			colorDecorator.param_colorBlending.upperRangeValue = 1;
			colorDecorator.param_colorBlending.lowerRangeValue = 0.95;
			
			spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SIZE_INV;
			spawnDecorator.param_maxSize.numberValue = 1;
			spawnDecorator.param_multiples.upperRangeValue = 16;
			
			spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
			spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
			
			
			switch ( param_style.index )
			{
				case STYLE_PAINTSTROKES:
				case STYLE_WHATEVER:
					brushEngine.param_curvatureSizeInfluence.numberValue = 1;
					spawnDecorator.param_maxSize.numberValue = 0.12;
				break;
				
				case STYLE_HARD_ROUND_CIRCLE:
				case STYLE_ROUGH_SQUARE:
				case STYLE_SPLAT_SPRAY:
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_FIXED;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
					sizeDecorator.param_mappingRange.numberValue = 0;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SPEED;
					
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.2;
					colorDecorator.param_pickRadius.lowerRangeValue = 0.3;
					colorDecorator.param_pickRadius.upperRangeValue = 0.35;
					break;
				
				case STYLE_PIXELATE:
					gridDecorator.active = true;
					spawnDecorator.active = false;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
					sizeDecorator.param_mappingRange.numberValue = 0;
					brushEngine.param_curvatureSizeInfluence.numberValue = 0;
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.1;
					colorDecorator.param_pickRadius.upperRangeValue = 0.2;
				break;
				
				case STYLE_PENCIL_SKETCH:
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_FIXED;
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.05;
					colorDecorator.param_pickRadius.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.2;
					brushEngine.param_curvatureSizeInfluence.numberValue = 1;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_FIXED;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -30;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 30;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
				break;
				case STYLE_PENCIL_SKETCH2:
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_FIXED;
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.05;
					colorDecorator.param_pickRadius.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.2;
					brushEngine.param_curvatureSizeInfluence.numberValue = 0;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SIZE_INV;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -30;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 30;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
					break;
			}
			
			onPrecisionChanged(null);
			onIntensityChanged(null);
		}
		
		protected function onPrecisionChanged(event:Event):void
		{
			var precision:Number = param_precision.numberValue;
			
			brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 8;
			//brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.01 + precision * 0.3;
			
			spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -(120 + precision * 60);
			spawnDecorator.param_offsetAngleRange.upperDegreesValue = 120 + precision * 60;
			splatterDecorator.param_brushAngleOffsetRange.degrees =  0;
			
			switch ( param_style.index )
			{
				case STYLE_PAINTSTROKES:
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 3;
					sizeDecorator.param_mappingFactor.numberValue = 0.05 + precision * 0.25;
					sizeDecorator.param_mappingRange.numberValue = 0.01 + precision * 0.12;
					spawnDecorator.param_maxSize.numberValue = 0.05 + precision * 0.36;
					spawnDecorator.param_maxOffset.numberValue = 16 + precision * 40;
					break;
				
				case STYLE_HARD_ROUND_CIRCLE:
				 
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.93;
					splatterDecorator.param_splatFactor.numberValue = 10 * precision;
					spawnDecorator.param_maxOffset.numberValue = precision * 4;
					break;
				
				case STYLE_ROUGH_SQUARE:
				case STYLE_SPLAT_SPRAY:
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.93;
					splatterDecorator.param_splatFactor.numberValue = 10 * precision;
					spawnDecorator.param_maxOffset.numberValue = precision * 12;
					break;
					
				
				case STYLE_PIXELATE:
					sizeDecorator.param_mappingFactor.numberValue = (4 / 62) + precision * (58/62);
					sizeDecorator.param_mappingRange.numberValue = 0;
					gridDecorator.param_stepX.numberValue = gridDecorator.param_stepY.numberValue = ((4 + 58 * precision) * 2);
					break;
				
				case STYLE_PENCIL_SKETCH:
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
		}
		
		protected function onIntensityChanged(event:Event):void
		{
			var intensity:Number = param_intensity.numberValue;
			//colorDecorator.param_brushOpacity.numberValue = intensity;
			(brushEngine as SprayCanBrush).param_strokeAlpha.numberValue = param_intensity.numberValue;
			
			bumpDecorator.param_bumpInfluence.numberValue = 1;
			
			bumpDecorator.param_bumpiness.numberValue = 0.7 * intensity;
			bumpDecorator.param_bumpinessRange.numberValue = 0.2 * intensity;
			
			bumpDecorator.param_glossiness.numberValue = 0.3 + 0.2 * intensity;
			bumpDecorator.param_shininess.numberValue = 0.1 + 0.2 * intensity;
		}
		
		protected function processPoints(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			if (  param_style.index == STYLE_PIXELATE )
			{
				for ( var i:int = 0; i < points.length; i++ )
				{
					if ( Math.random() < 0.10 )
					{
						points[i].x += (Math.random()-Math.random()) * gridDecorator.param_stepX.numberValue;
						points[i].y += (Math.random()-Math.random()) * gridDecorator.param_stepY.numberValue;
					}
				}
			}
			return points;
		}
	}
}