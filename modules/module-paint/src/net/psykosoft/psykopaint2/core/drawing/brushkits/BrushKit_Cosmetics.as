package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.drawing.brushes.EffectBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterMapping;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.AbstractPointDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.CallbackDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;
	
	public class BrushKit_Cosmetics extends BrushKit
	{
		private static const STYLE_DARKER:int = 0;
		private static const STYLE_LIGHTER:int = 1;
		private static const STYLE_SATURATE:int = 2;
		private static const STYLE_DESATURATE:int = 3;
		
		private var param_style:PsykoParameter;
		private var param_precision:PsykoParameter;
		private var param_intensity:PsykoParameter;
		
		private var sizeDecorator:SizeDecorator;
		private var bumpDecorator:BumpDecorator;
		private var colorDecorator:ColorDecorator;
		private var colorMatrix:ColorMatrix;
		
		
		private var eraserMode:Boolean;
		
		public function BrushKit_Cosmetics()
		{
			isPurchasable = true;
			init( null );
		}
		
		override protected function init( xml:XML ):void
		{
			if (!_initialized ) BrushKit.init();
			
			name = "Cosmetics";
			
			brushEngine = new EffectBrush();
			brushEngine.param_bumpiness.numberValue = 0;
			brushEngine.param_bumpInfluence.numberValue = 0.8;
			brushEngine.param_quadOffsetRatio.numberValue = 0.4;
			brushEngine.param_shapes.stringList = Vector.<String>(["spray","spray","spray","spray"]);
			
			var pathManager:PathManager = new PathManager( PathManager.ENGINE_TYPE_EXPERIMENTAL );
			brushEngine.pathManager = pathManager;
			pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			
			sizeDecorator = new SizeDecorator();
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
			sizeDecorator.param_mappingFactor.numberValue = 0.08;
			sizeDecorator.param_mappingRange.numberValue = 0.04;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
			pathManager.addPointDecorator( sizeDecorator );
			
			
			bumpDecorator = new BumpDecorator();
			bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_FIXED;
			bumpDecorator.param_invertMapping.booleanValue = true;
			bumpDecorator.param_bumpiness.numberValue = 0;
			bumpDecorator.param_bumpinessRange.numberValue = 0;
			bumpDecorator.param_bumpInfluence.numberValue = 0;
			
			pathManager.addPointDecorator( bumpDecorator );
			
			
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
			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["basic","basic","basic","basic"]);
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
			
			(brushEngine as EffectBrush).param_strokeAlpha.numberValue = param_intensity.numberValue;
			
			colorMatrix = new ColorMatrix();
			
			onStyleChanged(null);
		}
		
		protected function onStyleChanged(event:Event):void
		{
			brushEngine.param_shapes.index = param_style.index;
			brushEngine.param_quadOffsetRatio.numberValue = 0;
			brushEngine.param_curvatureSizeInfluence.numberValue = 0;
			
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
			colorDecorator.param_pickRadius.lowerRangeValue = 0.25;
			colorDecorator.param_pickRadius.upperRangeValue = 0.33;
			
			
			brushEngine.param_curvatureSizeInfluence.numberValue = 0;
			colorDecorator.param_colorBlending.upperRangeValue = 1;
			colorDecorator.param_colorBlending.lowerRangeValue = 0.95;
			
			
			
			switch ( param_style.index )
			{
				case STYLE_DARKER:
					colorMatrix.reset();
					colorMatrix.adjustBrightness(-8);
					(brushEngine as EffectBrush).colorMatrixData = colorMatrix.toAGALVector();
					break;
				case STYLE_LIGHTER:
					colorMatrix.reset();
					colorMatrix.adjustBrightness(8);
					(brushEngine as EffectBrush).colorMatrixData = colorMatrix.toAGALVector();
					break;
				case STYLE_SATURATE:
					colorMatrix.reset();
					colorMatrix.adjustSaturation(1.05);
					(brushEngine as EffectBrush).colorMatrixData = colorMatrix.toAGALVector();
					break;
				case STYLE_DESATURATE:
					colorMatrix.reset();
					colorMatrix.adjustSaturation(0.95);
					(brushEngine as EffectBrush).colorMatrixData = colorMatrix.toAGALVector();
					break;
			}
			
			onPrecisionChanged(null);
			onIntensityChanged(null);
		}
		
		protected function onPrecisionChanged(event:Event):void
		{
			var precision:Number = param_precision.numberValue;
			brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 8;
			sizeDecorator.param_mappingFactor.numberValue = 0.05 + precision * 0.5;
			sizeDecorator.param_mappingRange.numberValue = 0.01 + precision * 0.12;
				
		}
		
		protected function onIntensityChanged(event:Event):void
		{
			var intensity:Number = param_intensity.numberValue;
			//colorDecorator.param_brushOpacity.numberValue = intensity;
			(brushEngine as EffectBrush).param_strokeAlpha.numberValue = param_intensity.numberValue;
			bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_FIXED;
			
			if ( !eraserMode )
			{
				bumpDecorator.param_bumpInfluence.numberValue = 0;
				bumpDecorator.param_bumpiness.numberValue = 0;
				bumpDecorator.param_bumpinessRange.numberValue = 0;
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

