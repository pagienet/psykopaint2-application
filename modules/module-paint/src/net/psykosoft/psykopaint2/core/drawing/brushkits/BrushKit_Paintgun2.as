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
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ParticleDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.PointDecoratorFactory;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;

	public class BrushKit_Paintgun2 extends BrushKit
	{
		
		
		private static const STYLE_BUBBLES:int = 0;
		private static const STYLE_CERN:int = 1;
		private static const STYLE_CURLY:int = 2;
		
		
		private var param_style:PsykoParameter;
		private var param_precision:PsykoParameter;
		private var param_intensity:PsykoParameter;

		private var sizeDecorator:SizeDecorator;
		private var bumpDecorator:BumpDecorator;
		private var colorDecorator:ColorDecorator;
		private var particleDecorator:ParticleDecorator;
		private var splatterDecorator:SplatterDecorator;
		
		public function BrushKit_Paintgun2()
		{
			init( null );
		}
		
		override protected function init( xml:XML ):void
		{
			if (!_initialized ) BrushKit.init();
			
			name = "Paint guns";
			
			brushEngine = new SprayCanBrush();
			brushEngine.param_bumpiness.numberValue = 0;
			brushEngine.param_bumpInfluence.numberValue = 0.8;
			brushEngine.param_quadOffsetRatio.numberValue = 0;
			brushEngine.param_shapes.stringList = Vector.<String>(["almost circular hard"]);
			(brushEngine as SprayCanBrush).param_strokeAlpha.numberValue = 1
				
			var pathManager:PathManager = new PathManager( PathManager.ENGINE_TYPE_EXPERIMENTAL );
			brushEngine.pathManager = pathManager;
			pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			
			sizeDecorator = new SizeDecorator();
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_FIXED;
			sizeDecorator.param_mappingFactor.numberValue = 0.08;
			sizeDecorator.param_mappingRange.numberValue = 0.001;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
			pathManager.addPointDecorator( sizeDecorator );
			
			splatterDecorator = new SplatterDecorator();
			splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
			splatterDecorator.param_mappingMode.numberValue = 1;
			splatterDecorator.param_mappingFunction.index = SplatterDecorator.INDEX_MAPPING_LINEAR;
			splatterDecorator.param_splatFactor.numberValue = 10;
			splatterDecorator.param_minOffset.numberValue = 0;
			splatterDecorator.param_offsetAngleRange.degrees = 360;
			splatterDecorator.param_sizeFactor.numberValue = 0;
			pathManager.addPointDecorator( splatterDecorator );
			
			colorDecorator = new ColorDecorator();
			colorDecorator.param_brushOpacity.numberValue = 1;
			colorDecorator.param_brushOpacityRange.numberValue = 0;
			colorDecorator.param_colorBlending.upperRangeValue = 1;
			colorDecorator.param_colorBlending.lowerRangeValue = 0.95;
			colorDecorator.param_pickRadius.lowerRangeValue = 0.25;
			colorDecorator.param_pickRadius.upperRangeValue = 0.33;
			colorDecorator.param_smoothFactor.lowerRangeValue = 0.8;
			pathManager.addPointDecorator( colorDecorator );
			
			bumpDecorator = new BumpDecorator();
			bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM2;
			bumpDecorator.param_invertMapping.booleanValue = true;
			bumpDecorator.param_bumpiness.numberValue = 0.5;
			bumpDecorator.param_bumpinessRange.numberValue = 0.5;
			bumpDecorator.param_bumpInfluence.numberValue = 0.1;
			bumpDecorator.param_noBumpProbability.numberValue = 0.9;
			pathManager.addPointDecorator( bumpDecorator );
			
			particleDecorator = new ParticleDecorator();
			particleDecorator.param_maxConcurrentParticles.intValue = 64;
			particleDecorator.param_lifeSpan.lowerRangeValue = 2;
			particleDecorator.param_lifeSpan.upperRangeValue = 200;
			particleDecorator.param_lifeSpanDistribution.index = AbstractPointDecorator.INDEX_MAPPING_CUBIC_IN;
			particleDecorator.param_speed.lowerRangeValue = 3;
			particleDecorator.param_speed.upperRangeValue = 3;
			particleDecorator.param_speedDistribution.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
			particleDecorator.param_acceleration.lowerRangeValue = 1;
			particleDecorator.param_acceleration.upperRangeValue = 1;
			particleDecorator.param_updateProbability.lowerRangeValue = 1;
			particleDecorator.param_updateProbability.upperRangeValue = 1;
				
			particleDecorator.param_minSpawnDistance.numberValue = 0;
			particleDecorator.param_spawnProbability.numberValue = 0.9;
			particleDecorator.param_curlAngle.lowerDegreesValue = 0;
			particleDecorator.param_curlAngle.upperDegreesValue = 0;
			particleDecorator.param_offsetAngle.lowerDegreesValue = -180;
			particleDecorator.param_offsetAngle.upperDegreesValue = 180;
			particleDecorator.param_dropOriginalPoint.booleanValue = true;
			particleDecorator.param_renderSteps.intValue = 2;
			
			pathManager.addPointDecorator( particleDecorator );
			
			_parameterMapping = new PsykoParameterMapping();
			
			//UI elements:
			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["bubbles","cern","curly"]);
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
		
			onPrecisionChanged(null);
			onIntensityChanged(null);
		}
		
		protected function onStyleChanged(event:Event):void
		{
		
			brushEngine.param_shapes.index = param_style.index;
			
			switch ( param_style.index )
			{
				case STYLE_BUBBLES:
					particleDecorator.param_curlAngle.lowerDegreesValue = 0;
					particleDecorator.param_curlAngle.upperDegreesValue = 0;
					particleDecorator.param_curlFlipProbability.lowerRangeValue = 0;
					particleDecorator.param_curlFlipProbability.upperRangeValue = 0;
					particleDecorator.param_acceleration.lowerRangeValue = 1;
					particleDecorator.param_acceleration.upperRangeValue = 1;
					
					break;
				case STYLE_CERN:
					particleDecorator.param_curlAngle.lowerDegreesValue = 1;
					particleDecorator.param_curlAngle.upperDegreesValue = 8;
					particleDecorator.param_curlFlipProbability.lowerRangeValue = 0;
					particleDecorator.param_curlFlipProbability.upperRangeValue = 0.02;
					particleDecorator.param_acceleration.lowerRangeValue = 0.98;
					particleDecorator.param_acceleration.upperRangeValue = 1;
					
					break;
				case STYLE_CURLY:
					particleDecorator.param_curlAngle.lowerDegreesValue = 1;
					particleDecorator.param_curlAngle.upperDegreesValue = 15;
					particleDecorator.param_curlFlipProbability.lowerRangeValue = 0.1;
					particleDecorator.param_curlFlipProbability.upperRangeValue = 0.3;
					particleDecorator.param_acceleration.lowerRangeValue = 0.97;
					particleDecorator.param_acceleration.upperRangeValue = 1;
					break;
			}
			
			onPrecisionChanged(null);
			onIntensityChanged(null);
		}
		
		protected function onPrecisionChanged(event:Event):void
		{
			var precision:Number = param_precision.numberValue;
			
			sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.3;
			sizeDecorator.param_mappingRange.numberValue =  precision * 0.1;
			
			particleDecorator.param_speed.lowerRangeValue = 3 + precision * 30 ;
			particleDecorator.param_speed.upperRangeValue = 3 + precision * 30;
			particleDecorator.param_spawnProbability.numberValue = 0.15 + 0.8 * (1-precision);
			
			//brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 8;
			//brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.01 + precision * 0.3;
			
			
		}
		
		protected function onIntensityChanged(event:Event):void
		{
			var intensity:Number = param_intensity.numberValue;
			colorDecorator.param_brushOpacity.numberValue = intensity;
			//(brushEngine as SprayCanBrush).param_strokeAlpha.numberValue = param_intensity.numberValue;
			
			bumpDecorator.param_bumpInfluence.numberValue = 1;
			
			bumpDecorator.param_bumpiness.numberValue = 0.7 * intensity;
			bumpDecorator.param_bumpinessRange.numberValue = 0.2 * intensity;
			
			bumpDecorator.param_glossiness.numberValue = 0.3 + 0.2 * intensity;
			bumpDecorator.param_shininess.numberValue = 0.1 + 0.2 * intensity;
		}
		
		
	}
}