package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import com.greensock.easing.Expo;
	import com.greensock.easing.Strong;
	
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.drawing.brushes.SprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.CrayonShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.EraserBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.InkSplatsShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.SplatsShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.SplotchBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.SprayShape;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterMapping;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.AbstractPointDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;
	import net.psykosoft.psykopaint2.core.managers.purchase.InAppPurchaseManager;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	
	public class BrushKit_Paintgun extends BrushKit
	{
		private static const STYLE_INKSPLATS:int = 0;
		private static const STYLE_PAINT_BALL:int = 1;
		private static const STYLE_CONFETTIS:int = 2;
		private static const STYLE_CRAYATOR:int = 3;
		private static const STYLE_AUTOPAINT:int = 4;
		private static const STYLE_PAINTBRUSH:int = 5;
		
		
		
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
		private var precision:Number=0.5;
		
		public function BrushKit_Paintgun()
		{
			//isPurchasable = true;
			purchasePackages.push(InAppPurchaseManager.PRODUCT_ID_BRUSHKIT1, InAppPurchaseManager.PRODUCT_ID_PAINTGUN_BRUSH_1);
			purchaseIconID = ButtonIconType.BUY_PAINTGUN;
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
			brushEngine.param_shapes.stringList = Vector.<String>([InkSplatsShape.NAME,SplatsShape.NAME,SprayShape.NAME,CrayonShape.NAME,SplotchBrushShape.NAME,SplotchBrushShape.NAME,EraserBrushShape.NAME]);
			
			var pathManager:PathManager = new PathManager( PathManager.ENGINE_TYPE_EXPERIMENTAL );
			brushEngine.pathManager = pathManager;
			
			sizeDecorator = new SizeDecorator();
			pathManager.addPointDecorator( sizeDecorator );
			
			spawnDecorator = new SpawnDecorator();
			pathManager.addPointDecorator( spawnDecorator );
			
			bumpDecorator = new BumpDecorator();
			pathManager.addPointDecorator( bumpDecorator );
			
			colorDecorator = new ColorDecorator();
			pathManager.addPointDecorator( colorDecorator );
			
			splatterDecorator = new SplatterDecorator();
			pathManager.addPointDecorator( splatterDecorator );
			
			//callbackDecorator = new CallbackDecorator(this, processPoints);
			//callbackDecorator.active = false;
			//pathManager.addPointDecorator( callbackDecorator );
			
			
			_parameterMapping = new PsykoParameterMapping();
			
			//UI elements:
			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["Splat","Paint Ball","Confettis","Crayator","Autopaint","Splotch"]);
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
			
			brushEngine.param_quadOffsetRatio.numberValue = 0.4;
			switch ( param_style.index )
			{
				
				case STYLE_PAINT_BALL:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
				case STYLE_INKSPLATS:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
				case STYLE_CONFETTIS:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
				case STYLE_CRAYATOR:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
				case STYLE_AUTOPAINT:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
				case STYLE_PAINTBRUSH:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
					
					break;
				
			}
			
			
			brushEngine.param_shapes.index = param_style.index;
			
			onPrecisionChanged(null);
			onIntensityChanged(null);
		}
		
		protected function onPrecisionChanged(event:Event):void
		{
			precision = param_precision.numberValue;
			
			
			spawnDecorator.active = true;
			splatterDecorator.active = true;
			
			brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			brushEngine.pathManager.pathEngine.sendTaps = false;
			brushEngine.param_curvatureSizeInfluence.numberValue = 1;
			brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 200;
			brushEngine.textureScaleFactor = 1;
			brushEngine.param_bumpiness.numberValue = 0.2;
			brushEngine.param_bumpInfluence.numberValue = 0.8;
			
			
			
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
			sizeDecorator.param_mappingFactor.numberValue = 0.8;
			sizeDecorator.param_mappingRange.numberValue = 0.4;
			sizeDecorator.param_mappingFactor.minLimit = 0.01;
			sizeDecorator.param_mappingFactor.maxLimit = 2;
			
			bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
			bumpDecorator.param_invertMapping.booleanValue = true;
			bumpDecorator.param_bumpiness.numberValue = 0.5;
			bumpDecorator.param_bumpinessRange.numberValue = 0.5;
			bumpDecorator.param_bumpInfluence.numberValue = 0.8;
			bumpDecorator.param_noBumpProbability.numberValue = 0.8;
			
			
			colorDecorator.param_pickRadius.lowerRangeValue = 0.25;
			colorDecorator.param_pickRadius.upperRangeValue = 0.33;
			colorDecorator.param_smoothFactor.lowerRangeValue = 0.8;
			colorDecorator.param_saturationAdjustment.lowerRangeValue = 0;
			colorDecorator.param_saturationAdjustment.upperRangeValue = 0;
			colorDecorator.param_brightnessAdjustment.lowerRangeValue = 0;
			colorDecorator.param_brightnessAdjustment.upperRangeValue= 0;
			colorDecorator.param_brushOpacity.numberValue = 0.95;
			colorDecorator.param_brushOpacityRange.numberValue = 0.05;
			colorDecorator.param_colorBlending.upperRangeValue = 1;
			colorDecorator.param_colorBlending.lowerRangeValue = 0.98;
			colorDecorator.param_applyColorMatrix.booleanValue = false;
			
			
			spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_PRESSURE_SPEED;
			spawnDecorator.param_multiples.upperRangeValue = 1;
			spawnDecorator.param_multiples.lowerRangeValue = 1;
			spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -(120 + precision * 60);
			spawnDecorator.param_offsetAngleRange.upperDegreesValue = 120 + precision * 60;
			//spawnDecorator.param_maxSize.numberValue = 0.05 + precision * 0.36;
			spawnDecorator.param_maxSize.numberValue = 1;
			spawnDecorator.param_minOffset.numberValue = 0;
			spawnDecorator.param_maxOffset.numberValue = 16;
			
			
			
			
			splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
			splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
			splatterDecorator.param_brushAngleOffsetRange.degrees =  0;
			splatterDecorator.param_splatFactor.numberValue = 20;
			splatterDecorator.param_minOffset.numberValue = 0;
			splatterDecorator.param_offsetAngleRange.degrees = 360;
			splatterDecorator.param_sizeFactor.numberValue = 0;
			
			
			
			
			
			switch ( param_style.index )
			{
				case STYLE_INKSPLATS:
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 200;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
					sizeDecorator.param_mappingFactor.numberValue = 0.05+precision * 0.4;
					sizeDecorator.param_mappingRange.numberValue = 0.02+precision * 0.25;
					
					colorDecorator.param_brushOpacity.numberValue=0.92;
					colorDecorator.param_brushOpacityRange.numberValue = 0.08;
					
					splatterDecorator.param_splatFactor.numberValue = 20+20*precision;

					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_multiples.upperRangeValue = 8;
					spawnDecorator.param_multiples.lowerRangeValue = 1;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 10;
					spawnDecorator.param_maxOffset.numberValue =  1+precision * 30;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_noBumpProbability.numberValue = 0.05;
					bumpDecorator.param_glossiness.numberValue = 0.65 ;
					bumpDecorator.param_bumpiness.numberValue = param_intensity.numberValue*0.6;
					bumpDecorator.param_bumpinessRange.numberValue = param_intensity.numberValue*0.2;
					bumpDecorator.param_bumpInfluence.numberValue = param_intensity.numberValue*0.55;
					
					
					break;
				
				
				case STYLE_PAINT_BALL:
					
					brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.4+ 500* Expo.easeOut(precision,0,0,1)
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
					sizeDecorator.param_mappingFactor.numberValue = 0.01+precision * 0.5;
					sizeDecorator.param_mappingRange.numberValue = 0.05*precision;
					
					splatterDecorator.active=false;
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
					splatterDecorator.param_splatFactor.numberValue = 0+precision * 10;
					splatterDecorator.param_minOffset.numberValue = 0+precision * 10;
					//splatterDecorator.param_offsetAngleRange.degrees = 360;
					splatterDecorator.param_offsetAngleRange.degrees = 120;
					splatterDecorator.param_sizeFactor.numberValue = precision * 6;
					
				
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.001;
					colorDecorator.param_pickRadius.upperRangeValue = 0.01;
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.04;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = -0.1;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 0.1;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.0;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.0;
					//colorDecorator.param_brushOpacity.numberValue = 0.8;
					//colorDecorator.param_brushOpacityRange.numberValue = 0.15;
					colorDecorator.param_brushOpacity.numberValue = 0.97;
					colorDecorator.param_brushOpacityRange.numberValue = 0.03;
					colorDecorator.param_colorBlending.upperRangeValue = 1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.98;
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_RANDOM;
					spawnDecorator.param_multiples.upperRangeValue = 6;
					spawnDecorator.param_multiples.lowerRangeValue = 2;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_PRESSURE_SPEED;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 20;
					spawnDecorator.param_maxOffset.numberValue =  0+precision * 50;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
					//spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -2;
					//spawnDecorator.param_offsetAngleRange.upperDegreesValue = 2;
					spawnDecorator.param_bristleVariation.numberValue = 0;
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_noBumpProbability.numberValue = 0.3;
					bumpDecorator.param_glossiness.numberValue = 0.35 ;
					bumpDecorator.param_bumpiness.numberValue = param_intensity.numberValue*0.55;
					bumpDecorator.param_bumpinessRange.numberValue = param_intensity.numberValue*0.2;
					bumpDecorator.param_bumpInfluence.numberValue = param_intensity.numberValue*0.72;
					
					
					break;
				
				
				case STYLE_CONFETTIS:
					trace("STYLE_CONFETTIS");
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 5+50* Strong.easeOut(precision,0,0,1);
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
					sizeDecorator.param_mappingFactor.numberValue = 0.02+precision * 0.2;
					sizeDecorator.param_mappingRange.numberValue =precision * 0.12;
					
					splatterDecorator.active=true;
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
					splatterDecorator.param_splatFactor.numberValue = 0+precision * 20;
					splatterDecorator.param_minOffset.numberValue = 0+precision * 20;
					splatterDecorator.param_offsetAngleRange.degrees = 120;
					splatterDecorator.param_sizeFactor.numberValue = 0.1+precision * 6;
					
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.1;
					colorDecorator.param_pickRadius.upperRangeValue = 0.4;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = -0.2;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 0.2;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.3;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.3;
					colorDecorator.param_brushOpacity.numberValue = 0.90;
					colorDecorator.param_brushOpacityRange.numberValue = 0.10;
					colorDecorator.param_colorBlending.upperRangeValue = 0.2;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.1;
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED;
					spawnDecorator.param_autorotate.booleanValue=true;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_SIZE;
					spawnDecorator.param_brushAngleRange.lowerDegreesValue=-90;
					spawnDecorator.param_brushAngleRange.upperDegreesValue=90;
					spawnDecorator.param_multiples.upperRangeValue = 10;
					spawnDecorator.param_multiples.lowerRangeValue = 4;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 10;
					spawnDecorator.param_maxOffset.numberValue =  0+precision * 30;
					spawnDecorator.param_bristleVariation.numberValue = 10;
					
					
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_noBumpProbability.numberValue = 0.2;
					bumpDecorator.param_glossiness.numberValue = 0.12 ;
					bumpDecorator.param_bumpiness.numberValue = param_intensity.numberValue*0.6;
					bumpDecorator.param_bumpinessRange.numberValue = param_intensity.numberValue*0.2;
					bumpDecorator.param_bumpInfluence.numberValue = param_intensity.numberValue*0.75;
					
					break;
				case STYLE_CRAYATOR:
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 2+ 20* Strong.easeOut(precision,0,0,1);
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
					sizeDecorator.param_mappingFactor.numberValue = 0.01+precision*0.15;
					sizeDecorator.param_mappingRange.numberValue = 0.00+precision*0.02;
					
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.0;
					colorDecorator.param_pickRadius.upperRangeValue = 0.0;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = 0;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 1.2;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = 0;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.3;
					colorDecorator.param_brushOpacity.numberValue = 0.96;
					colorDecorator.param_brushOpacityRange.numberValue = 0.04;
					colorDecorator.param_colorBlending.upperRangeValue = 1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0;
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					colorDecorator.param_smoothFactor.lowerRangeValue= 0;
					colorDecorator.param_smoothFactor.upperRangeValue= 0;
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_multiples.upperRangeValue = 8;
					spawnDecorator.param_multiples.lowerRangeValue = 2;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 20;
					spawnDecorator.param_maxOffset.numberValue =  0+precision * 50;
					spawnDecorator.param_bristleVariation.numberValue = 2;
					
					
					
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_brushAngleOffsetRange.degrees =  0;
					splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_LINEAR;
					splatterDecorator.param_splatFactor.numberValue = precision * 30;
					splatterDecorator.param_minOffset.numberValue = precision * 30;
					splatterDecorator.param_offsetAngleRange.degrees = 360;
					splatterDecorator.param_sizeFactor.numberValue = 1;
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_bumpiness.numberValue = 0.6;
					bumpDecorator.param_bumpinessRange.numberValue = 0.1;
					bumpDecorator.param_bumpInfluence.numberValue = param_intensity.numberValue*0.65;
					bumpDecorator.param_noBumpProbability.numberValue = param_intensity.numberValue*0.8;
					bumpDecorator.param_glossiness.numberValue = param_intensity.numberValue*0.82 ;
					
					break;
				case STYLE_AUTOPAINT:
					trace("STYLE_AUTOPAINT");
					brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 2+precision * 2000;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
					sizeDecorator.param_invertMapping.booleanValue=false;
					sizeDecorator.param_mappingFactor.numberValue = 0.05+precision * 3;
					sizeDecorator.param_mappingRange.numberValue = 0.02+precision * 1;
					//sizeDecorator.param_mappingRange.numberValue = 1;
					
					//splatterDecorator.active=false;
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_mappingFunction.index =  AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
					splatterDecorator.param_splatFactor.numberValue = 0+precision * 10;
					splatterDecorator.param_minOffset.numberValue = 0+precision * 10;
					splatterDecorator.param_offsetAngleRange.degrees = 1;
					splatterDecorator.param_sizeFactor.numberValue = 0.05+precision * 6;
					
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.0;
					colorDecorator.param_pickRadius.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.04;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = 0;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 0.6;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.25;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.25;
					colorDecorator.param_brushOpacity.numberValue = 0.95;
					colorDecorator.param_brushOpacityRange.numberValue = 0.05;
					colorDecorator.param_colorBlending.upperRangeValue = 1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0;
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					
					//spawnDecorator.active=false;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED;
					spawnDecorator.param_multiples.upperRangeValue = 4;
					spawnDecorator.param_multiples.lowerRangeValue = 1;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_PRESSURE_SPEED;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 20;
					spawnDecorator.param_maxOffset.numberValue =  0+precision * 50;
					//spawnDecorator.param_maxOffset.numberValue =  0;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
					spawnDecorator.param_bristleVariation.numberValue = 4;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					
					bumpDecorator.param_noBumpProbability.numberValue = 0.0;
					bumpDecorator.param_glossiness.numberValue = 0.35 ;
					bumpDecorator.param_bumpiness.numberValue = param_intensity.numberValue*0.2;
					bumpDecorator.param_bumpinessRange.numberValue = param_intensity.numberValue*0.1;
					bumpDecorator.param_bumpInfluence.numberValue = param_intensity.numberValue*0.72;
					
					
					break;
				case STYLE_PAINTBRUSH:
					brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 2+precision*10;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CUBIC_IN;
					sizeDecorator.param_mappingFactor.numberValue = 0.01+precision * 0.4;
					sizeDecorator.param_mappingRange.numberValue = precision * 0.2;
					;
					//spawnDecorator.active=false;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED_INV;
					spawnDecorator.param_multiples.upperRangeValue = 8;
					spawnDecorator.param_multiples.lowerRangeValue = 1;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_PRESSURE_SPEED;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 20;
					spawnDecorator.param_maxOffset.numberValue =  0+precision * 50;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -1;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 1;
					spawnDecorator.param_bristleVariation.numberValue = 1;
					
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
					splatterDecorator.param_splatFactor.numberValue = 0+precision * 10;
					splatterDecorator.param_minOffset.numberValue = 0+precision * 10;
					splatterDecorator.param_offsetAngleRange.degrees = 360;
					splatterDecorator.param_sizeFactor.numberValue = 0.0+precision * 1;

					colorDecorator.param_pickRadius.lowerRangeValue = 0.0;
					colorDecorator.param_pickRadius.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.04;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = -0.05;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 0.05;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.1;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.1;
					colorDecorator.param_brushOpacity.numberValue = 0.95;
					colorDecorator.param_brushOpacityRange.numberValue = 0.05;
					colorDecorator.param_colorBlending.upperRangeValue = 1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0;
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_noBumpProbability.numberValue = 0.1;
					bumpDecorator.param_glossiness.numberValue = 0.55 ;
					bumpDecorator.param_bumpiness.numberValue = param_intensity.numberValue*0.45;
					bumpDecorator.param_bumpinessRange.numberValue = param_intensity.numberValue*0.05;
					bumpDecorator.param_bumpInfluence.numberValue = param_intensity.numberValue*0.5;
					
					
					break;
				
			}
		}
		
		protected function onIntensityChanged(event:Event):void
		{
			onPrecisionChanged(null);
			
			var intensity:Number = param_intensity.numberValue;
			//colorDecorator.param_brushOpacity.numberValue = intensity;
			(brushEngine as SprayCanBrush).param_strokeAlpha.numberValue = param_intensity.numberValue;
			

			switch ( param_style.index )
			{
				
				
				case STYLE_CONFETTIS:
				case STYLE_AUTOPAINT:
				case STYLE_PAINTBRUSH:
				//	bumpDecorator.param_glossiness.numberValue = 0.3 + 0.2 * intensity;
					//bumpDecorator.param_shininess.numberValue = 0.1 + 0.2 * intensity;
					break;
				
				case STYLE_INKSPLATS:
				//	bumpDecorator.param_glossiness.numberValue = 0.6 + 0.2 * intensity;
					//bumpDecorator.param_shininess.numberValue = 0.4 + 0.2 * intensity;
					bumpDecorator.param_bumpiness.numberValue = 0.3 * intensity;
					
					break;
				case STYLE_CRAYATOR:
					bumpDecorator.param_bumpiness.numberValue = 0.2 * intensity;
					//bumpDecorator.param_glossiness.numberValue = 0.1 + 0.2 * intensity;
					//bumpDecorator.param_shininess.numberValue = 0.1 + 0.2 * intensity;
					break;
			}
			
			
			
			if ( !super.eraserMode )
			{
				bumpDecorator.param_bumpInfluence.numberValue = 0.4;
				bumpDecorator.param_bumpiness.numberValue = 0.5 * intensity;
				bumpDecorator.param_bumpinessRange.numberValue = 0.1;
			}
			else if ( super.eraserMode )
			{
				bumpDecorator.param_bumpInfluence.numberValue = 1 - intensity;
				bumpDecorator.param_bumpiness.numberValue = 0;
				bumpDecorator.param_bumpinessRange.numberValue = 0;
				
			}
		}
		
		
		
		override public function set eraserMode( enabled:Boolean ):void
		{
			super.eraserMode = (enabled);
			
			if ( enabled )
			{
				onPrecisionChanged(null);
				onIntensityChanged(null);
				
				
				brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.4 + precision  *4;

				
				//it's a good idea to put the eraser shape always as the last element into the shapes list
				//like that you will not have to update the index in case you are more regular shapes
				brushEngine.param_shapes.index = brushEngine.param_shapes.stringList.indexOf(EraserBrushShape.NAME);
				
				//SETTING ERASER MODE WILL REMOVE THE DEPTH AS WELL AS THE COLOR
				SprayCanBrush(brushEngine).param_eraserMode.booleanValue=true;
				

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
				bumpDecorator.param_glossiness.numberValue = 0.13  ;
				
				
			} else {
				SprayCanBrush(brushEngine).param_eraserMode.booleanValue=false;
				onStyleChanged(null);
			}
		}
		
	}
}


