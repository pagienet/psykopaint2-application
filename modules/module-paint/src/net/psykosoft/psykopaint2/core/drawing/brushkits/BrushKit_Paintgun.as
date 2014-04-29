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
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.CircularRotationDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.GridDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.PointDecoratorFactory;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.RotationDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	
	public class BrushKit_Paintgun extends BrushKit
	{
		private static const STYLE_INKSPLATS:int = 0;
		private static const STYLE_SPLATS:int = 1;
		private static const STYLE_SPRAY:int = 2;
		private static const STYLE_VECTORSPLAT:int = 3;
		private static const STYLE_CRAYON:int = 4;
		private static const STYLE_PAINTBRUSH:int = 5;
		private static const STYLE_SUMI:int = 6;
		
		
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
			brushEngine.param_shapes.stringList = Vector.<String>(["inksplats","splats","spray","vectorsplat","crayon","paintbrush","sumi"]);
			
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
			
			
			//callbackDecorator = new CallbackDecorator(this, processPoints);
			//callbackDecorator.active = false;
			//pathManager.addPointDecorator( callbackDecorator );
			
			colorDecorator = new ColorDecorator();
			colorDecorator.param_brushOpacity.numberValue = 1;
			colorDecorator.param_brushOpacityRange.numberValue = 0;
			colorDecorator.param_colorBlending.upperRangeValue = 1;
			colorDecorator.param_colorBlending.lowerRangeValue = 0.95;
			colorDecorator.param_pickRadius.lowerRangeValue = 0.25;
			colorDecorator.param_pickRadius.upperRangeValue = 0.33;
			colorDecorator.param_smoothFactor.lowerRangeValue = 0.8;
			pathManager.addPointDecorator( colorDecorator );
			
			
			
			_parameterMapping = new PsykoParameterMapping();
			
			//UI elements:
			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["splat","sketch","sketch","sketch","sketch","confetti","sketch","sketch"]);
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
			
			brushEngine.param_shapes.index = param_style.index;
			
			spawnDecorator.active = true;
			
			
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
			colorDecorator.param_pickRadius.lowerRangeValue = 0.25;
			colorDecorator.param_pickRadius.upperRangeValue = 0.33;
			
			splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SIZE_INV;
			
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
				
				case STYLE_INKSPLATS:
				case STYLE_SPLATS:
				case STYLE_SPRAY:
				case STYLE_VECTORSPLAT:
				case STYLE_CRAYON:
				case STYLE_PAINTBRUSH:
				case STYLE_SUMI:
					colorDecorator.param_pickRadius.lowerRangeValue = 0.1;
					colorDecorator.param_pickRadius.upperRangeValue = 0.2;
					brushEngine.param_curvatureSizeInfluence.numberValue = 0;
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
				
				case STYLE_INKSPLATS:
				case STYLE_SPLATS:
				case STYLE_SPRAY:
				case STYLE_VECTORSPLAT:
				case STYLE_CRAYON:
				case STYLE_PAINTBRUSH:
				case STYLE_SUMI:
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 3;
					sizeDecorator.param_mappingFactor.numberValue = 0.05 + precision * 0.5;
					sizeDecorator.param_mappingRange.numberValue = 0.01 + precision * 0.12;
					spawnDecorator.param_maxSize.numberValue = 0.05 + precision * 0.36;
					spawnDecorator.param_maxOffset.numberValue = 16 + precision * 60;
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
				case STYLE_SPLATS:
				case STYLE_SPRAY:
				case STYLE_CRAYON:
				case STYLE_PAINTBRUSH:
					bumpDecorator.param_glossiness.numberValue = 0.3 + 0.2 * intensity;
					bumpDecorator.param_shininess.numberValue = 0.1 + 0.2 * intensity;
					break;
				
				case STYLE_SUMI:
				case STYLE_INKSPLATS:
					bumpDecorator.param_glossiness.numberValue = 0.6 + 0.2 * intensity;
					bumpDecorator.param_shininess.numberValue = 0.4 + 0.2 * intensity;
					bumpDecorator.param_bumpiness.numberValue = 0.3 * intensity;
					
					break;
				case STYLE_VECTORSPLAT:
					bumpDecorator.param_bumpiness.numberValue = 0.2 * intensity;
					bumpDecorator.param_glossiness.numberValue = 0.1 + 0.2 * intensity;
					bumpDecorator.param_shininess.numberValue = 0.1 + 0.2 * intensity;
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


