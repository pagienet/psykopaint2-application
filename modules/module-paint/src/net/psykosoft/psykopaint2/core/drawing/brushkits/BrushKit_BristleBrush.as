package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.drawing.brushes.SprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.EraserBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.PaintBrushShape1;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.PaintbrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.SplotchBrushShape;
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
	import net.psykosoft.psykopaint2.core.managers.purchase.InAppPurchaseManager;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;

	public class BrushKit_BristleBrush extends BrushKit
	{
		
		private static const STYLE_VAN_GOGH:int = 0;
		private static const STYLE_MONET:int = 1;
		private static const STYLE_PISSARO:int = 2;
		private static const STYLE_MANET:int = 3;
		//private static const STYLE_PAINTSTROKES_SPIRAL:int = 3;
		
		private var sizeDecorator:SizeDecorator;
		private var splatterDecorator:SplatterDecorator;
		private var bumpDecorator:BumpDecorator;
		private var spawnDecorator:SpawnDecorator;
		private var colorDecorator:ColorDecorator;
		private var callbackDecorator:CallbackDecorator;
		
		
		private var forceRotationAngle:Number;
		private var rotationCenterX:Number;
		private var rotationCenterY:Number;
		
		private var param_style:PsykoParameter;
		private var param_precision:PsykoParameter;
		private var param_intensity:PsykoParameter;
		
		public var precision:Number;

		
		public function BrushKit_BristleBrush()
		{
			//isPurchasable = true;
			purchasePackages.push(InAppPurchaseManager.PRODUCT_ID_BRUSHKIT1, InAppPurchaseManager.PRODUCT_ID_BRISTLE_BRUSH_1);
			purchaseIconID = ButtonIconType.BUY_BRUSH;
			
			if (!_initialized ) BrushKit.init();
			name = "paint brush";
			
			//init(definitionXML);
			
			
			//CREATE SPRAY CAN BRUSH ENGINE
			brushEngine = new SprayCanBrush();
			brushEngine.param_bumpiness.numberValue = 1;
			brushEngine.param_bumpInfluence.numberValue =1;
			brushEngine.param_quadOffsetRatio.numberValue = 0.4;
			brushEngine.param_glossiness.numberValue=1;
			brushEngine.param_shapes.stringList = Vector.<String>([PaintBrushShape1.NAME,PaintbrushShape.NAME,SplotchBrushShape.NAME,PaintBrushShape1.NAME,EraserBrushShape.NAME]);
			
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
			
			callbackDecorator = new CallbackDecorator( this, processPoints );
			//pathManager.addPointDecorator( callbackDecorator );
			
			_parameterMapping = new PsykoParameterMapping();
			
			//UI elements:
			param_style = new PsykoParameter( PsykoParameter.IconListParameter,"Style",0,["Van Gogh","Monet","Pissaro","Cezanne"]);
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
						
			
			onStyleChanged(null);
			
		}
		
		
		protected function onStyleChanged(event:Event):void
		{
			//HAVE TO SET THE OFFSET BEFORE ASSIGNING NEW SHAPE
			brushEngine.param_quadOffsetRatio.numberValue = 0.4;
			switch ( param_style.index )
			{
				
				case STYLE_VAN_GOGH:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
					break;
				case STYLE_MONET:
					brushEngine.param_quadOffsetRatio.numberValue = 0.0;
					break;
				case STYLE_PISSARO:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
					break;
				case STYLE_MANET:
					brushEngine.param_quadOffsetRatio.numberValue = 0;
					break;
				default:
					break;
					
			}
			
			brushEngine.param_shapes.index = param_style.index;			
			onPrecisionChanged(null);
			onIntensityChanged(null);
		}
		
		protected function onPrecisionChanged(event:Event):void
		{
			precision = param_precision.numberValue;
			
			callbackDecorator.active=false;
			splatterDecorator.active=true;
			spawnDecorator.active=true;
			colorDecorator.active=true;
			
			//BRUSH ENGINE
			brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 4;
			brushEngine.pathManager.pathEngine.sendTaps = false;
			brushEngine.textureScaleFactor = 1;
			brushEngine.param_curvatureSizeInfluence.numberValue = 0.2;
			

			
			//SIZE
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
			sizeDecorator.param_invertMapping.booleanValue=true;
			sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
			sizeDecorator.param_mappingFactor.minLimit = 0.01;
			sizeDecorator.param_mappingFactor.maxLimit = 2;
			sizeDecorator.param_mappingFactor.numberValue = 0.2;
			sizeDecorator.param_mappingRange.numberValue = 0.05;
			
			//SPAWN
			spawnDecorator.param_multiples.upperRangeValue = 16;
			spawnDecorator.param_multiples.lowerRangeValue = 4;
			spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_PRESSURE_SPEED;
			spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_RANDOM;
			//spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
			//spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
			spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -1;
			spawnDecorator.param_offsetAngleRange.upperDegreesValue = 1;
			spawnDecorator.param_maxSize.numberValue = 0.12;
			spawnDecorator.param_minOffset.numberValue = 0;
			spawnDecorator.param_maxOffset.numberValue = 16;
			spawnDecorator.param_bristleVariation.numberValue = 0.0;
			spawnDecorator.param_autorotate.booleanValue =true;
			
			
			
			//BUMP
			bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
			bumpDecorator.param_invertMapping.booleanValue = true;
			bumpDecorator.param_bumpiness.numberValue = 0.0;
			bumpDecorator.param_bumpinessRange.numberValue = 0.5;
			bumpDecorator.param_bumpInfluence.numberValue = 0.25;
			bumpDecorator.param_noBumpProbability.numberValue = 0.9;
			bumpDecorator.param_glossiness.numberValue = 0.20;
			
			//COLOR
			colorDecorator.param_brushOpacity.numberValue = 0.98;
			colorDecorator.param_brushOpacityRange.numberValue = 0.02;
			colorDecorator.param_colorBlending.upperRangeValue = 1;
			colorDecorator.param_colorBlending.lowerRangeValue = 0.95;
			colorDecorator.param_pickRadius.lowerRangeValue = 0.0;
			colorDecorator.param_pickRadius.upperRangeValue = 0.53;
			colorDecorator.param_smoothFactor.lowerRangeValue = 0.8;
			colorDecorator.param_saturationAdjustment.lowerRangeValue = 0;
			colorDecorator.param_saturationAdjustment.upperRangeValue = 0;
			colorDecorator.param_hueAdjustment.lowerRangeValue = 0;
			colorDecorator.param_hueAdjustment.upperRangeValue = 0;
			colorDecorator.param_brightnessAdjustment.lowerRangeValue = 0;
			colorDecorator.param_brightnessAdjustment.upperRangeValue= 0;		
			colorDecorator.param_applyColorMatrix.booleanValue=false;
			
			//colorDecorator.param_applyColorMatrix.booleanValue=false;
			
			
			//SPLATTER
			splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SPEED;
			splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
			splatterDecorator.param_splatFactor.numberValue = 20;
			splatterDecorator.param_minOffset.numberValue = 0;
			splatterDecorator.param_offsetAngleRange.degrees = 360;
			splatterDecorator.param_sizeFactor.numberValue = 0;
			
			
			switch ( param_style.index )
			{
				
				case STYLE_VAN_GOGH:
					
					trace("van Gogh");					
				
					callbackDecorator.active = false;
					forceRotationAngle = 0;
					brushEngine.param_curvatureSizeInfluence.numberValue = 0.8;
					
					//ORIGINAL
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 3;
					//brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 3;

					
					//ORIGINAL
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_invertMapping.booleanValue=false;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
					sizeDecorator.param_mappingRange.numberValue = 0.0001 + precision * 0.30;
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.5;
					
					//sizeDecorator.param_mappingRange.numberValue = 0.01 + precision * 1;
					//sizeDecorator.param_mappingFactor.numberValue = 0;
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_PRESSURE_SPEED;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_RANDOM;
					spawnDecorator.param_multiples.upperRangeValue = 1;
					spawnDecorator.param_multiples.lowerRangeValue = 6;
					//spawnDecorator.param_multiples.upperRangeValue = 1;
					//spawnDecorator.param_multiples.lowerRangeValue = 1;
					//spawnDecorator.param_maxSize.numberValue = 0.005 + precision * 0.16;
					spawnDecorator.param_maxSize.numberValue = 0.2;
					spawnDecorator.param_maxOffset.numberValue =  precision * 40;
					spawnDecorator.param_minOffset.numberValue =  precision * 30;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
					
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SPEED;
					splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
					splatterDecorator.param_splatFactor.numberValue = 1 + 20 * precision;
					splatterDecorator.param_minOffset.numberValue = 0;
					splatterDecorator.param_offsetAngleRange.degrees = 360;
					splatterDecorator.param_sizeFactor.numberValue = 0;
					
					colorDecorator.param_brushOpacity.numberValue = 0.98;
					colorDecorator.param_brushOpacityRange.numberValue = 0.02;
					colorDecorator.param_colorBlending.upperRangeValue = 0.8;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.45;
					colorDecorator.param_pickRadius.lowerRangeValue = 0.0;
					colorDecorator.param_pickRadius.upperRangeValue = 0.53;
					colorDecorator.param_smoothFactor.lowerRangeValue = 0.8;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = -0.02;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 0.02;
					//DONT MESS WITH THE HUE, IT'S UGLY
					//colorDecorator.param_hueRandomizationMode.index = ColorDecorator.HUE_MODE_RANDOM;
					colorDecorator.param_hueAdjustment.lowerRangeValue = 0;
					colorDecorator.param_hueAdjustment.upperRangeValue = 0;
					
					//colorDecorator.param_colorMatrixChance.numberValue = 0.00;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.01;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.01;
					colorDecorator.param_applyColorMatrix.booleanValue=false;
					
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_invertMapping.booleanValue = false;
					bumpDecorator.param_noBumpProbability.numberValue = 0.2;
					bumpDecorator.param_glossiness.numberValue = 0.42;
					bumpDecorator.param_bumpiness.numberValue = 0.3;
					bumpDecorator.param_bumpinessRange.numberValue = 0.15;
					bumpDecorator.param_bumpInfluence.numberValue = 0.9;
					bumpDecorator.param_bumpiness.numberValue = param_intensity.numberValue*0.5;
					bumpDecorator.param_bumpinessRange.numberValue = param_intensity.numberValue*0.15; 
					bumpDecorator.param_bumpInfluence.numberValue = param_intensity.numberValue*0.9;
					
					break;
				/*case STYLE_PAINTSTROKES_FIREWORKS:
					callbackDecorator.active = true;
					forceRotationAngle = 0;
					brushEngine.param_curvatureSizeInfluence.numberValue = 0;
					break;
				case STYLE_PAINTSTROKES_SPIRAL:
					callbackDecorator.active = true;
					forceRotationAngle = Math.PI*0.25;
					brushEngine.param_curvatureSizeInfluence.numberValue = 0;
					break;*/
					
				case STYLE_MONET:
					trace("STYLE_MONET")
					brushEngine.param_curvatureSizeInfluence.numberValue = 2;
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_invertMapping.booleanValue=false;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
					sizeDecorator.param_mappingRange.numberValue = 0.05 + precision * 0.40;
					sizeDecorator.param_mappingFactor.numberValue = 0.2 + precision * 0.8;
					
					
					spawnDecorator.param_bristleVariation.numberValue = 10;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED;
					spawnDecorator.param_multiples.upperRangeValue = 3;
					spawnDecorator.param_multiples.lowerRangeValue = 6;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 20;
					spawnDecorator.param_maxOffset.numberValue =  0+precision * 22;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -4;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 4;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SPEED;
					splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
					splatterDecorator.param_splatFactor.numberValue = 4 + 10 * precision;
					splatterDecorator.param_minOffset.numberValue = 0;
					splatterDecorator.param_offsetAngleRange.degrees = 360;
					splatterDecorator.param_sizeFactor.numberValue = 0;
					
					
					colorDecorator.param_brushOpacity.numberValue = 0.98;
					colorDecorator.param_brushOpacityRange.numberValue = 0.02;
					colorDecorator.param_colorBlending.upperRangeValue = 1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.95;
					colorDecorator.param_pickRadius.lowerRangeValue = 0.0;
					colorDecorator.param_pickRadius.upperRangeValue = 0.53;
					colorDecorator.param_smoothFactor.lowerRangeValue = 0.8;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = 0;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 0;
					colorDecorator.param_hueAdjustment.lowerRangeValue = 0;
					colorDecorator.param_hueAdjustment.upperRangeValue = 0;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = 0;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0;		
					colorDecorator.param_applyColorMatrix.booleanValue=false;
					
					bumpDecorator.param_glossiness.numberValue = 0.08 +Math.random()*0.04 ;
					bumpDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_EXPONENTIAL_IN;
					bumpDecorator.param_noBumpProbability.numberValue = 0.83;
					
					//bumpDecorator.param_bumpInfluence.numberValue = 0.15;
					
					//bumpDecorator.param_bumpiness.numberValue = 0.03;
					//bumpDecorator.param_bumpinessRange.numberValue = 0.26;
					bumpDecorator.param_bumpiness.numberValue = param_intensity.numberValue*0.03;
					bumpDecorator.param_bumpinessRange.numberValue = param_intensity.numberValue*0.26; 
					bumpDecorator.param_bumpInfluence.numberValue = param_intensity.numberValue*0.25;
					
					break;
				
				case STYLE_PISSARO:
					trace("STYLE_PISSARO");
					
					brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 25+precision*800;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCULAR_IN;
				//	sizeDecorator.param_mappingFactor.numberValue = 0.025+precision * 0.8;
					//sizeDecorator.param_mappingRange.numberValue = 0.01+precision * 0.015;
					sizeDecorator.param_mappingFactor.numberValue = 0.07+precision * 0.34;
					sizeDecorator.param_mappingRange.numberValue = 0.02+precision * 0.07;
					
					splatterDecorator.active=false;
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_PRESSURE_SPEED;
					splatterDecorator.param_mappingFunction.index = AbstractPointDecorator.INDEX_MAPPING_CIRCQUAD_IN;
					splatterDecorator.param_splatFactor.numberValue = 0+precision * 10;
					splatterDecorator.param_minOffset.numberValue = 0+precision * 10;
					//splatterDecorator.param_offsetAngleRange.degrees = 360;
					splatterDecorator.param_offsetAngleRange.degrees = 1;
					splatterDecorator.param_sizeFactor.numberValue = 0.5+precision * 6;
					
					
					
				
					colorDecorator.param_pickRadius.lowerRangeValue = 0.001;
					colorDecorator.param_pickRadius.upperRangeValue = 0.01;
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.04;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = -0.1;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 0.1;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.05;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.05;
					colorDecorator.param_brushOpacity.numberValue = 0.95;
					colorDecorator.param_brushOpacityRange.numberValue = 0.05;
					colorDecorator.param_colorBlending.upperRangeValue = 0.9;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.78;
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					
					//spawnDecorator.active=false;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_RANDOM;
					spawnDecorator.param_multiples.upperRangeValue = 4;
					spawnDecorator.param_multiples.lowerRangeValue = 4;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_PRESSURE_SPEED;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 30;
					spawnDecorator.param_maxOffset.numberValue =  0+precision * 60;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
					//spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -2;
					//spawnDecorator.param_offsetAngleRange.upperDegreesValue = 2;
					spawnDecorator.param_bristleVariation.numberValue = 0;
				
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_noBumpProbability.numberValue = 0.1;
					bumpDecorator.param_glossiness.numberValue = 0.42 ;
					bumpDecorator.param_bumpiness.numberValue = param_intensity.numberValue*0.55;
					bumpDecorator.param_bumpinessRange.numberValue = param_intensity.numberValue*0.41;
					bumpDecorator.param_bumpInfluence.numberValue = param_intensity.numberValue*0.53;
					
					
					
					break;
				
				case STYLE_MANET:
					brushEngine.param_curvatureSizeInfluence.numberValue = 1;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 8;
					brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.01 + precision * 0.3;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFactor.numberValue = 0.05 + precision * 0.35;
					sizeDecorator.param_mappingRange.numberValue = 0.03 + precision * 0.20;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SIZE_INV;
					splatterDecorator.param_brushAngleOffsetRange.degrees =  8;
					splatterDecorator.param_splatFactor.numberValue = precision * 10;
					splatterDecorator.param_minOffset.numberValue = 0;
					splatterDecorator.param_offsetAngleRange.degrees = 360;
					splatterDecorator.param_sizeFactor.numberValue = 1;
					//splatterDecorator.active=false;
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.25;
					colorDecorator.param_pickRadius.upperRangeValue = 0.33;
					colorDecorator.param_colorBlending.upperRangeValue = 1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.95;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = 0.0;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 0.3;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.05;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.05;
					colorDecorator.param_brushOpacity.numberValue = 0.95;
					colorDecorator.param_brushOpacityRange.numberValue = 0.05;
					colorDecorator.param_colorBlending.upperRangeValue = 1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.98;
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SIZE_INV;
					spawnDecorator.param_multiples.lowerRangeValue = 8;
					spawnDecorator.param_multiples.upperRangeValue = 16;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -16;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 16;
					//spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -(120 + precision * 60);
					//spawnDecorator.param_offsetAngleRange.upperDegreesValue = 120 + precision * 60;
					spawnDecorator.param_maxSize.numberValue = 0.05 + precision * 0.36;
					spawnDecorator.param_maxSize.numberValue = 1;
					spawnDecorator.param_maxOffset.numberValue =  precision * 20;
					spawnDecorator.param_minOffset.numberValue = precision * 17;
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_noBumpProbability.numberValue = 0.6;
					bumpDecorator.param_glossiness.numberValue = 0.55 ;
					bumpDecorator.param_bumpiness.numberValue = param_intensity.numberValue*0.3;
					bumpDecorator.param_bumpinessRange.numberValue = param_intensity.numberValue*0.1;
					bumpDecorator.param_bumpInfluence.numberValue = param_intensity.numberValue*0.6;
					
					break;
				
			
				
				
			}
		}
		
		protected function onIntensityChanged(event:Event):void
		{
			onPrecisionChanged(null);
			
			var intensity:Number = param_intensity.numberValue;
			//RESET LAYER OPACITY
			if (brushEngine is SprayCanBrush) (brushEngine  as SprayCanBrush).param_strokeAlpha.numberValue = 1;
			
			switch ( param_style.index )
			{
				
				
				case "STYLE TO ASSIGN":
					
					//ALPHA OF LAYER IS 1 HERE CAUSE WE DON'T WANT TO HAVE TRANSPARENCY ON THE LAYER SIDE
					(brushEngine  as SprayCanBrush).param_strokeAlpha.numberValue = 1;
					//CHANGE INDIVIDUAL BRUSH OPACITY
					colorDecorator.param_brushOpacity.numberValue = 0.1+intensity*0.9;
					bumpDecorator.param_bumpInfluence.numberValue = 0.15+intensity*0.25;
					bumpDecorator.param_bumpinessRange.numberValue = 0.25+intensity*0.15;
					
					break;
				
				
				/*case STYLE_PAINTSTROKES:
					
					//spawnDecorator.param_maxSize.numberValue = 0.05 + intensity * 2;
					//spawnDecorator.param_maxOffset.numberValue = 16 + intensity * 4;
					
					//splatterDecorator.param_sizeFactor.numberValue = intensity*4;
					
					
					//brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + intensity * 3;
					
					//sizeDecorator.param_mappingFactor.numberValue = 0.05 + intensity * 0.25;
					//sizeDecorator.param_mappingRange.numberValue = 0.01 + intensity * 0.12;
					
					break;*/
				
				
			
				//SIMPLE OPACITY BY DEFAULT
				default:
					
					(brushEngine as SprayCanBrush).param_strokeAlpha.numberValue = 0.1+param_intensity.numberValue*0.9;
					
					break;
				
				
			}
		

		}	
		
		
		protected function processPoints(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			if ( points.length == 0 ) return points;
			
			if (points[0].first )
			{
				rotationCenterX = points[0].x;
				rotationCenterY = points[0].y;
				//if (  param_style.index == STYLE_PAINTSTROKES_SPIRAL ) forceRotationAngle = Math.random() * Math.PI * 2;
			}
			for ( var i:int = 0; i < points.length; i++ )
			{
				var p:SamplePoint = points[i];
				p.angle = Math.atan2(rotationCenterY -p.y ,rotationCenterX - p.x) +  forceRotationAngle;
			}
			
			return points;
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
				
				SprayCanBrush(brushEngine).param_eraserMode.booleanValue=true;
				
				splatterDecorator.active=false;
				spawnDecorator.active=false;
				sizeDecorator.active=true;
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