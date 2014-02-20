package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.drawing.brushes.SprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterMapping;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterProxy;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.CallbackDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.GridDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.PointDecoratorFactory;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;

	public class BrushKit_SprayCan extends BrushKit
	{
		
		
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
			brushEngine.param_shapes.stringList = Vector.<String>(["paint1","almost circular hard","almost circular rough","basic","line","sumi"]);
			
			var pathManager:PathManager = new PathManager( PathManager.ENGINE_TYPE_EXPERIMENTAL );
			brushEngine.pathManager = pathManager;
			pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			
			sizeDecorator = new SizeDecorator();
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
			sizeDecorator.param_mappingFactor.numberValue = 0.08;
			sizeDecorator.param_mappingRange.numberValue = 0.04;
			sizeDecorator.param_mappingFunction.index = SizeDecorator.INDEX_MAPPING_CIRCQUAD;
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
			colorDecorator.param_brushOpacity.numberValue = 0.9;
			colorDecorator.param_brushOpacityRange.numberValue = 0.2;
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
			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["paint1","basic","splat","line","sumi"]);
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
			if (  param_style.index == 0)
			{
				brushEngine.param_quadOffsetRatio.numberValue = 0.4;
			} else {
				brushEngine.param_quadOffsetRatio.numberValue = 0;
			}
			brushEngine.param_shapes.index = param_style.index;
			
			gridDecorator.active = false;
			spawnDecorator.active = true;
			
			if (  param_style.index != 3 )
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
			spawnDecorator.param_maxSize.numberValue = 1;
			
			switch ( param_style.index )
			{
				case 0:
					brushEngine.param_curvatureSizeInfluence.numberValue = 1;
					spawnDecorator.param_maxSize.numberValue = 0.12;
				break;
				
				case 1:
				case 2:
					//spawnDecorator.active = false;
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_FIXED;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
					sizeDecorator.param_mappingRange.numberValue = 0;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SPEED;
					
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.2;
					colorDecorator.param_pickRadius.lowerRangeValue = 0.3;
					colorDecorator.param_pickRadius.upperRangeValue = 0.35;
					
					
					break;
				case 3:
					gridDecorator.active = true;
					spawnDecorator.active = false;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
					sizeDecorator.param_mappingRange.numberValue = 0;
					brushEngine.param_curvatureSizeInfluence.numberValue = 0;
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.1;
					colorDecorator.param_pickRadius.upperRangeValue = 0.2;
				break;
				case 4:
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
		
			
			switch ( param_style.index )
			{
				case 0:
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 3;
					
				case 4:
					sizeDecorator.param_mappingFactor.numberValue = 0.05 + precision * 0.25;
					sizeDecorator.param_mappingRange.numberValue = 0.01 + precision * 0.12;
					spawnDecorator.param_maxSize.numberValue = 0.05 + precision * 0.36;
					spawnDecorator.param_maxOffset.numberValue = 16 + precision * 40;
					break;
				case 1:
				
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.93;
					
					splatterDecorator.param_splatFactor.numberValue = 10 * precision;
					
					
					spawnDecorator.param_maxOffset.numberValue = precision * 4;
					break;
				
				case 2:
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.93;
					splatterDecorator.param_splatFactor.numberValue = 10 * precision;
					spawnDecorator.param_maxOffset.numberValue = precision * 12;
					break;
					
				
				case 3:
					sizeDecorator.param_mappingFactor.numberValue = (4 / 62) + precision * (58/62);
					sizeDecorator.param_mappingRange.numberValue = 0;
					gridDecorator.param_stepX.numberValue = gridDecorator.param_stepY.numberValue = ((4 + 58 * precision) * 2);
					
					break;
				
				
			}
		}
		
		protected function onIntensityChanged(event:Event):void
		{
			var intensity:Number = param_intensity.numberValue;
			colorDecorator.param_brushOpacity.numberValue = intensity;
			
			bumpDecorator.param_bumpInfluence.numberValue = 1;
			
			bumpDecorator.param_bumpiness.numberValue = 0.7 * intensity;
			bumpDecorator.param_bumpinessRange.numberValue = 0.2 * intensity;
			
			bumpDecorator.param_glossiness.numberValue = 0.3 + 0.2 * intensity;
			bumpDecorator.param_shininess.numberValue = 0.1 + 0.2 * intensity;
		}
		
		protected function processPoints(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			if (  param_style.index == 3 )
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