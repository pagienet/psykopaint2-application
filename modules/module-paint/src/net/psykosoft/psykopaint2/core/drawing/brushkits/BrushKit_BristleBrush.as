package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.drawing.brushes.SprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.LineBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.PaintBrushShape1;
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
		

		
		public function BrushKit_BristleBrush()
		{
			isPurchasable = true;
			if (!_initialized ) BrushKit.init();
			name = "paint brush";
			
			//init(definitionXML);
			
			
			//CREATE SPRAY CAN BRUSH ENGINE
			brushEngine = new SprayCanBrush();
			brushEngine.param_bumpiness.numberValue = 1;
			brushEngine.param_bumpInfluence.numberValue =1;
			brushEngine.param_quadOffsetRatio.numberValue = 0.4;
			brushEngine.param_glossiness.numberValue=1;
			brushEngine.param_shapes.stringList = Vector.<String>([PaintBrushShape1.NAME,LineBrushShape.NAME,SplotchBrushShape.NAME,PaintBrushShape1.NAME]);
			
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
					break;
				
				case STYLE_PISSARO:
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
			var precision:Number = param_precision.numberValue;
			
			callbackDecorator.active=false;
			splatterDecorator.active=true;
			spawnDecorator.active=true;
			colorDecorator.active=true;
			
			//BRUSH ENGINE
			brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 4;
			brushEngine.pathManager.pathEngine.sendTaps = false;
			brushEngine.textureScaleFactor = 1;
			
			

			
			//SIZE
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
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
			bumpDecorator.param_bumpiness.numberValue = 0.8;
			bumpDecorator.param_bumpinessRange.numberValue = 0.5;
			bumpDecorator.param_bumpInfluence.numberValue = 0.25;
			bumpDecorator.param_noBumpProbability.numberValue = 0.6;
			bumpDecorator.param_glossiness.numberValue = 0.25;
			
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
					brushEngine.param_curvatureSizeInfluence.numberValue = 0;
					
					//ORIGINAL
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 3;
					//brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 3;

					
					//ORIGINAL
					sizeDecorator.param_mappingRange.numberValue = 0.01 + precision * 0.12;
					sizeDecorator.param_mappingFactor.numberValue = 0.05 + precision * 0.5;
					//sizeDecorator.param_mappingRange.numberValue = 0.01 + precision * 1;
					//sizeDecorator.param_mappingFactor.numberValue = 0;

					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_PRESSURE_SPEED;
					spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_RANDOM;
					//ORIGINAL VALUES
					spawnDecorator.param_multiples.upperRangeValue = 16;
					spawnDecorator.param_multiples.lowerRangeValue = 4;
					//spawnDecorator.param_multiples.upperRangeValue = 1;
					//spawnDecorator.param_multiples.lowerRangeValue = 1;
					spawnDecorator.param_maxSize.numberValue = 0.05 + precision * 0.36;
					spawnDecorator.param_maxOffset.numberValue = 16 + precision * 40;
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_invertMapping.booleanValue = true;
					bumpDecorator.param_bumpiness.numberValue = 0.10;
					bumpDecorator.param_bumpinessRange.numberValue = 0.15;
					bumpDecorator.param_bumpInfluence.numberValue = 0.25;
					bumpDecorator.param_noBumpProbability.numberValue = 0.0;
					bumpDecorator.param_glossiness.numberValue = 0.24;
					
					colorDecorator.param_brushOpacity.numberValue = 0.98;
					colorDecorator.param_brushOpacityRange.numberValue = 0.02;
					colorDecorator.param_colorBlending.upperRangeValue = 1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.95;
					colorDecorator.param_pickRadius.lowerRangeValue = 0.0;
					colorDecorator.param_pickRadius.upperRangeValue = 0.53;
					colorDecorator.param_smoothFactor.lowerRangeValue = 0.8;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = -0.2;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 0.2;
					//DONT MESS WITH THE HUE, IT'S UGLY
					//colorDecorator.param_hueRandomizationMode.index = ColorDecorator.HUE_MODE_RANDOM;
					colorDecorator.param_hueAdjustment.lowerRangeValue = 0;
					colorDecorator.param_hueAdjustment.upperRangeValue = 0;
					
					//colorDecorator.param_colorMatrixChance.numberValue = 0.00;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.02;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.02;		
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					
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
					trace("BRistle 3")
					
					spawnDecorator.param_bristleVariation.numberValue = 10;
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SPEED;
					spawnDecorator.param_multiples.upperRangeValue = 16;
					spawnDecorator.param_multiples.lowerRangeValue = 12;
					spawnDecorator.param_minOffset.numberValue =  0+precision * 6;
					spawnDecorator.param_maxOffset.numberValue =  0+precision * 6;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -90;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 90;
					
					bumpDecorator.param_glossiness.numberValue = 0.08	 ;
					bumpDecorator.param_bumpiness.numberValue = 0.2;
					bumpDecorator.param_bumpinessRange.numberValue = 0.3;
					bumpDecorator.param_bumpInfluence.numberValue = 0.05;
					bumpDecorator.param_noBumpProbability.numberValue = 0.9;
					
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
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_bumpiness.numberValue = 0.15;
					bumpDecorator.param_bumpinessRange.numberValue = 0.01;
					bumpDecorator.param_bumpInfluence.numberValue = 0.23;
					bumpDecorator.param_noBumpProbability.numberValue = 0.9;
					bumpDecorator.param_glossiness.numberValue = 0.42 ;
					
				
					colorDecorator.param_pickRadius.lowerRangeValue = 0.001;
					colorDecorator.param_pickRadius.upperRangeValue = 0.01;
					colorDecorator.param_colorBlending.upperRangeValue = 0.1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.04;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = -0.3;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 1.5;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.1;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.2;
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
				
					
					break;
				
				case STYLE_MANET:
					brushEngine.param_curvatureSizeInfluence.numberValue = 1;
					brushEngine.pathManager.pathEngine.outputStepSize.numberValue = 0.5 + precision * 8;
					brushEngine.pathManager.pathEngine.speedSmoothing.numberValue = 0.01 + precision * 0.3;
					
					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
					sizeDecorator.param_mappingFactor.numberValue = 0.05 + precision * 0.25;
					sizeDecorator.param_mappingRange.numberValue = 0.03 + precision * 0.10;
					
					splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SIZE_INV;
					splatterDecorator.param_brushAngleOffsetRange.degrees =  8;
					splatterDecorator.param_splatFactor.numberValue = precision * 5;
					splatterDecorator.param_minOffset.numberValue = 0;
					splatterDecorator.param_offsetAngleRange.degrees = 360;
					splatterDecorator.param_sizeFactor.numberValue = 1;
					//splatterDecorator.active=false;
					
					
					bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM;
					bumpDecorator.param_bumpiness.numberValue = 0.3;
					bumpDecorator.param_bumpinessRange.numberValue = 0.1;
					bumpDecorator.param_bumpInfluence.numberValue = 0.2;
					bumpDecorator.param_noBumpProbability.numberValue = 0.6;
					bumpDecorator.param_glossiness.numberValue = 0.55 ;
					
					
					colorDecorator.param_pickRadius.lowerRangeValue = 0.25;
					colorDecorator.param_pickRadius.upperRangeValue = 0.33;
					colorDecorator.param_colorBlending.upperRangeValue = 1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.95;
					colorDecorator.param_saturationAdjustment.lowerRangeValue = 0;
					colorDecorator.param_saturationAdjustment.upperRangeValue = 1;
					colorDecorator.param_brightnessAdjustment.lowerRangeValue = -0.2;
					colorDecorator.param_brightnessAdjustment.upperRangeValue= 0.2;
					colorDecorator.param_brushOpacity.numberValue = 0.95;
					colorDecorator.param_brushOpacityRange.numberValue = 0.05;
					colorDecorator.param_colorBlending.upperRangeValue = 1;
					colorDecorator.param_colorBlending.lowerRangeValue = 0.98;
					colorDecorator.param_applyColorMatrix.booleanValue=true;
					
					spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SIZE_INV;
					spawnDecorator.param_maxSize.numberValue = 1;
					spawnDecorator.param_multiples.lowerRangeValue = 5;
					spawnDecorator.param_multiples.upperRangeValue = 16;
					spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -10;
					spawnDecorator.param_offsetAngleRange.upperDegreesValue = 10;
					//spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -(120 + precision * 60);
					//spawnDecorator.param_offsetAngleRange.upperDegreesValue = 120 + precision * 60;
					spawnDecorator.param_maxSize.numberValue = 0.05 + precision * 0.36;
					spawnDecorator.param_maxOffset.numberValue = 16 + precision * 40;
					
					
					
					break;
				
				default:

					sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_RANDOM;
					sizeDecorator.param_mappingRange.numberValue = 0.001;
					sizeDecorator.param_mappingFactor.numberValue = 0.02 + precision * 0.93;
					

					
					
					break;
				
				
			}
		}
		
		protected function onIntensityChanged(event:Event):void
		{
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
		/*private static const definitionXML:XML = <brush engine={BrushType.SPRAY_CAN} name="Paint Brush">
		<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0" />
		<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="line" />
		<parameter id={AbstractBrush.PARAMETER_N_QUAD_OFFSET_RATIO} path="brush" value="0"/>
		
		<parameterMapping>
		<parameter id="Brush Style" type={PsykoParameter.IconListParameter} label="Style" list="Small,Medium,Large" index="1" showInUI="0"/>
		<proxy type={PsykoParameterProxy.TYPE_DECORATOR_ACTIVATION} src="Brush Style"
		target="pathengine.pointdecorator_4"
		condition={PsykoParameterProxy.CONDITION_EQUALS_VALUE }
		indices="1"/>
		
		</parameterMapping>
		
		<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
		<parameter id={AbstractPathEngine.PARAMETER_SEND_TAPS} path="pathengine" value="0" />
		<parameter id={AbstractPathEngine.PARAMETER_SPEED_SMOOTHING} path="pathengine" value="0.02" />
		<parameter id={AbstractPathEngine.PARAMETER_OUTPUT_STEP} path="pathengine" value="4" />
		
		<SizeDecorator>
		<parameter id={SizeDecorator.PARAMETER_SL_MODE} index={SizeDecorator.INDEX_MODE_SPEED} path="pathengine.pointdecorator_0" />
		<parameter id={SizeDecorator.PARAMETER_N_FACTOR} path="pathengine.pointdecorator_0" value="0.3" minValue="0" maxValue="2"/>
		<parameter id={SizeDecorator.PARAMETER_N_RANGE} path="pathengine.pointdecorator_0" label="Range" value="0.2" minValue="0" maxValue="1" />
		
		<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} index="2" path="pathengine.pointdecorator_0"/>
		</SizeDecorator>
		<SpawnDecorator>
		<parameter id={SpawnDecorator.PARAMETER_SL_OFFSET_MODE} index={SpawnDecorator.INDEX_MODE_PRESSURE_SPEED} path="pathengine.pointdecorator_1" />
		<parameter id={SpawnDecorator.PARAMETER_IR_MULTIPLES} value1="8" value2="8" path="pathengine.pointdecorator_1" />
		<parameter id={SpawnDecorator.PARAMETER_N_MAXIMUM_OFFSET} path="pathengine.pointdecorator_1" value="16" minValue="0" maxValue="50" showInUI="1"/>
		<parameter id={SpawnDecorator.PARAMETER_N_MINIMUM_OFFSET} path="pathengine.pointdecorator_1" value="1" minValue="0" maxValue="200"/>
		<parameter id={SpawnDecorator.PARAMETER_AR_OFFSET_ANGLE} path="pathengine.pointdecorator_1" value1="-1" value2="1" />
		<parameter id={SpawnDecorator.PARAMETER_AR_BRUSH_ANGLE_VARIATION} path="pathengine.pointdecorator_1" value1="-2" value2="2" />
		<parameter id={SpawnDecorator.PARAMETER_N_BRISTLE_VARIATION} path="pathengine.pointdecorator_1" value="1"/>
		</SpawnDecorator>
		<BumpDecorator>
		<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_2" index={BumpDecorator.INDEX_MODE_FIXED} />
		<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS} path="pathengine.pointdecorator_2" value="0.5" />
		<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS_RANGE} path="pathengine.pointdecorator_2" value="1.5"/>
		<parameter id={BumpDecorator.PARAMETER_N_SHININESS} path="pathengine.pointdecorator_2" value="0.9" />
		<parameter id={BumpDecorator.PARAMETER_N_GLOSSINESS} path="pathengine.pointdecorator_2" value="0.4" />
		<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE} path="pathengine.pointdecorator_2" value="0.8" />
		</BumpDecorator>
		<ColorDecorator>
		<parameter id={ColorDecorator.PARAMETER_NR_PICK_RADIUS} path="pathengine.pointdecorator_3" value1="0.0005" value2="0.1" />
		<parameter id={ColorDecorator.PARAMETER_SL_PICK_RADIUS_MODE} path="pathengine.pointdecorator_3" index="1" />
		<parameter id={ColorDecorator.PARAMETER_N_OPACITY}  path="pathengine.pointdecorator_3" value="0.75" showInUI="2" />
		<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING}  path="pathengine.pointdecorator_3" value1="0.1" value2="0.3" />
		<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_3" color="0xffffff"/>
		</ColorDecorator>
		<SplatterDecorator >
		<parameter id={SplatterDecorator.PARAMETER_A_OFFSET_ANGLE_RANGE} value1="0" value2="0" path="pathengine.pointdecorator_4" />
		<parameter id={SplatterDecorator.PARAMETER_A_ANGLE_ADJUSTMENT} value="90" path="pathengine.pointdecorator_4" />
		<parameter id={SplatterDecorator.PARAMETER_N_SPLAT_FACTOR} value="5" path="pathengine.pointdecorator_4" />
		<parameter id={SplatterDecorator.PARAMETER_N_SIZE_FACTOR} value="0" path="pathengine.pointdecorator_4" />
		<parameter id={SplatterDecorator.PARAMETER_N_MINIMUM_OFFSET} value="2" path="pathengine.pointdecorator_4" />
		</SplatterDecorator>
		
		</pathengine>
		</brush>*/
		
	}
}