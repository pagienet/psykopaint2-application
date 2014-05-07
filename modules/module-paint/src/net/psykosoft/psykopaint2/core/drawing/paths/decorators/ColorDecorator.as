package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	
	import com.greensock.easing.Expo;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Strong;
	import com.quasimondo.geom.ColorMatrix;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManagerCallbackInfo;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	
	final public class ColorDecorator extends AbstractPointDecorator
	{
		public static const PARAMETER_B_COLORMATRIX:String = "Appy Color Matrix";
		public static const PARAMETER_N_COLORMATRIX_CHANCE:String = "Color Matrix Application Chance";
		public static const PARAMETER_NR_SATURATION:String = "Saturation";
		public static const PARAMETER_NR_HUE:String = "Hue";
		public static const PARAMETER_NR_BRIGHTNESS:String = "Brightness";
		public static const PARAMETER_NR_COLOR_BLENDING:String = "Color Blending";
		public static const PARAMETER_N_OPACITY:String = "Opacity";
		public static const PARAMETER_N_OPACITY_RANGE:String = "Opacity Range";
		public static const PARAMETER_SL_PICK_RADIUS_MODE:String = "Pick Radius Mode";
		public static const PARAMETER_NR_PICK_RADIUS:String = "Color Pick Radius";
		public static const PARAMETER_NR_SMOOTH_FACTOR:String = "Color Smooth Factor";
		public static const PARAMETER_N_MAXIMUM_SPEED:String  = "Maximum Speed";
		public static const PARAMETER_N_PICK_RANDOM_OFFSET_FACTOR:String  = "Random Pick Offset";
		public static const PARAMETER_SL_HUE_RANDOMIZATION_MODE:String  = "Hue Randomization Mode";
		
		public static const INDEX_MODE_PICK_COLOR:int = 0;
		public static const INDEX_MODE_FIXED_COLOR:int = 1;
		
		// "Apply Color Matrix" - Boolean
		// if set to true a color matrix will be applied to the sampled color values
		// the matrix is defined by the following 3 parameters
		public var param_applyColorMatrix:PsykoParameter;
		
		//"Color Matrix Application Chance" - NumberValue
		//If "Apply Color Matrix" is true then this value will define how likely it is
		//that a point's color gets changed
		public var param_colorMatrixChance:PsykoParameter;
		
		// "Saturation" - NumberRange
		// the saturation is changed randomly within the given range
		public var param_saturationAdjustment:PsykoParameter;
		
		// "Hue" - NumberRange
		// the hue is changed randomly within the given range
		public var param_hueAdjustment:PsykoParameter;
		
		// "Hue Randomization Mode" - StringList
		// sets what kind of random hues are generated
		public var param_hueRandomizationMode:PsykoParameter;
		
		// "Brightness" - NumberRange
		// the brightness is changed randomly within the given range
		public var param_brightnessAdjustment:PsykoParameter;
		
		//  "Color Blending" - NumberRange
		// defines how much of the previously picked color is mixed with the incoming one
		// if given a range the amount can vary randomly per point.
		// a value of 0 will return just the new color, a value of 1 just the previous one
		public var param_colorBlending:PsykoParameter;
		
		// "Opacity" - NumberValue
		// sets the opacity of the point
		public var param_brushOpacity:PsykoParameter;
		
		// "Opacity Range" - NumberValue
		// sets a range in which the opacity of the point vcan vary randomly
		// the range is between param_brushOpacity.numberValue - param_brushOpacityRange.numberValue and  param_brushOpacity.numberValue + param_brushOpacityRange.numberValue
		// and gets limited to a range of 0..1
		public var param_brushOpacityRange:PsykoParameter;
		
		// "Color Pick Radius" - NumberRange
		// the distance range from the brush center that the 4 corner color pickers are located
		// a bigger distance will result in more of a color gradient withing the brush quad
		public var param_pickRadius:PsykoParameter;
		
		// "Pick Radius Mode" - StringList
		// defines what controls the pickRadius:
		// index = 0: the radius is random within the range
		// index = 1: the radius is dependent on the drawing speed: the slower you draw the smaller the radius and thus the more precise the colors
		public var param_pickRadiusMode:PsykoParameter;
		
		//"Maximum Speed" - NumberValue
		// used only if the Pick Radius Mode is speed based and controls how speed is mapped to radius
		public var param_maxSpeed:PsykoParameter;
		
		//"Random Pick Offset" - NumberValue
		// if a value > 0 is used the color picker center will be randomly offset from the brush center
		// and thus make the colors less precise
		public var param_pickOffsetFactor:PsykoParameter;
		
		//"Color Smooth Factor"- NumberRange
		/* DEFINE THE SAMPE SIZE : the area from which the color average is picked. If 0 means no blur/average */
		public var param_smoothFactor:PsykoParameter;
		
		private var cm:ColorMatrix;
		private const lastRGBA:Vector.<Number> = new Vector.<Number>(16,true);
		private const _applyArray:Array = [];
		
		private const hueHarmonyAngles:Array = [[],[90],[-30,30],[-120,120],[-150,150],[-60,120,180],[60,-120,180],[90,-90,180]];
			
			
		
		public function ColorDecorator()
		{
			super();
			//colorMode  = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_COLOR_MODE,0,["Pick Color","Fixed Color"] );
			
			param_applyColorMatrix  = new PsykoParameter( PsykoParameter.BooleanParameter,PARAMETER_B_COLORMATRIX,false);
			param_colorMatrixChance  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_COLORMATRIX_CHANCE,0.25,0,1);
			
			param_saturationAdjustment  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_SATURATION,0,0,-10, 10);
			param_hueAdjustment  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_HUE,0,0,-1, 1);
			param_brightnessAdjustment  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_BRIGHTNESS,0,0,-1, 1);
			
			param_colorBlending  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_COLOR_BLENDING,0.7,0.7,0, 1);
			param_brushOpacity  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_OPACITY,0.9,0,1);
			param_brushOpacityRange  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_OPACITY_RANGE,0.2,0,1);
			
			param_pickRadiusMode  = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_PICK_RADIUS_MODE,0,["Fixed","Speed"] );
			param_pickRadius  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_PICK_RADIUS,1,1,0,1);
			param_pickOffsetFactor  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_PICK_RANDOM_OFFSET_FACTOR,0,0,200);
			
			param_smoothFactor  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_SMOOTH_FACTOR,1,1,0,1);
			param_maxSpeed  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MAXIMUM_SPEED,20,1,100);
			
			param_hueRandomizationMode  = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_PICK_RADIUS_MODE,0,["Free","Complementary","Analogous","Triad","Split-Complementary","Rectangle 1","Rectangle 2","Square"] );
			
			
			_parameters.push(param_applyColorMatrix,param_saturationAdjustment, param_hueAdjustment, param_brightnessAdjustment,param_colorBlending,param_brushOpacity,param_brushOpacityRange,param_pickRadius,param_pickRadiusMode,param_smoothFactor,param_maxSpeed,param_pickOffsetFactor);
			cm = new ColorMatrix();
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var applyMatrix:Boolean = param_applyColorMatrix.booleanValue;
			var applyArray:Array = _applyArray;
			
			
			var cm_chance:PsykoParameter = param_colorMatrixChance;
			var radiusMode:int = param_pickRadiusMode.index;
			var minPickRadius:Number = param_pickRadius.lowerRangeValue;
			var pickRadiusRange:Number = param_pickRadius.rangeValue;
			var ms:Number = param_maxSpeed.numberValue;
			var pof:Number = param_pickOffsetFactor.numberValue;
			var bo:Number = Quad.easeIn(param_brushOpacity.numberValue,0,1,1);
			var bor:Number = param_brushOpacityRange.numberValue;
			var hrm:int = param_hueRandomizationMode.index;
			var hueAngles:Array = hueHarmonyAngles[hrm];
			var hl:int =  hueAngles.length;
			var useHarmony:Boolean = hl > 0;
			var cb:PathManagerCallbackInfo = manager.callbacks;
			for ( var i:int = 0; i < points.length; i++ )
			{
				var point:SamplePoint = points[i];
				var prgba:Vector.<Number> = point.colorsRGBA;
				
				//if ( mode == 0 )
				//{
					if ( cb.onPickColor ) {
						
						var tmp_x:Number = point.x;
						var tmp_y:Number = point.y;
						if ( pof != 0 )
						{
							point.x += (Math.random() - Math.random()) * pof * point.size;
							point.y += (Math.random() - Math.random()) * pof * point.size;
						}
						applyArray[0] = point;
						applyArray[1] = minPickRadius + pickRadiusRange * [Math.random(),Math.min(point.speed,ms) / ms][radiusMode];
						applyArray[2] = param_smoothFactor.randomValue;
						cb.onPickColor.apply(cb.callbackObject, applyArray );
						point.x = tmp_x;
						point.y = tmp_y;
					}
					/*
				} else {
					prgba[0] = prgba[4] = prgba[8] = prgba[12] = r;
					prgba[1] = prgba[5] = prgba[9] = prgba[13] = g;
					prgba[2] = prgba[6] = prgba[10] = prgba[14] = b;
					prgba[3] = prgba[7] = prgba[11] = prgba[15] = 1;
				}
					*/
				if ( applyMatrix && cm_chance.chance) {
					
					cm.reset();
					cm.adjustSaturation( param_saturationAdjustment.randomValue + 1 );
					cm.adjustHue( useHarmony ? hueAngles[int(Math.random() * hl)] : param_hueAdjustment.randomValue * 180);
					cm.adjustBrightness( param_brightnessAdjustment.randomValue * 255 );
					cm.applyMatrixToVector( prgba );
				}
				
				var lrgba:Vector.<Number> = lastRGBA;
				
				var alpha:Number;
				if (point.first )
				{
					alpha = bo - bor *  + ( 2 * Math.random() * bor );
					if ( alpha < 0 ) alpha = 0;
					else if ( alpha > 1 ) alpha = 1;
					lrgba[0] = prgba[0] * alpha;
					lrgba[1] = prgba[1] * alpha;
					lrgba[2] = prgba[2] * alpha;
					lrgba[3] = alpha;
					
					alpha = bo - bor *  + ( 2 * Math.random() * bor );
					if ( alpha < 0 ) alpha = 0;
					else if ( alpha > 1 ) alpha = 1;
					lrgba[4] = prgba[4] * alpha;
					lrgba[5] = prgba[5] * alpha;
					lrgba[6] = prgba[6] * alpha;
					lrgba[7] = alpha;
					
					alpha = bo - bor *  + ( 2 * Math.random() * bor );
					if ( alpha < 0 ) alpha = 0;
					else if ( alpha > 1 ) alpha = 1;
					lrgba[8] = prgba[8] * alpha;
					lrgba[9] = prgba[9] * alpha;
					lrgba[10] = prgba[10] * alpha;
					lrgba[11] = alpha;
					
					
					alpha = bo - bor *  + ( 2 * Math.random() * bor );
					if ( alpha < 0 ) alpha = 0;
					else if ( alpha > 1 ) alpha = 1;
					lrgba[12] = prgba[12] * alpha;
					lrgba[13] = prgba[13] * alpha;
					lrgba[14] = prgba[14] * alpha;
					lrgba[15] = alpha;
				} else {
					alpha = bo - bor *  + ( 2 * Math.random() * bor );
					if ( alpha < 0 ) alpha = 0;
					else if ( alpha > 1 ) alpha = 1;
					var blend:Number = param_colorBlending.randomValue;
					lrgba[0] += (prgba[0] * alpha - lrgba[0] ) * blend ;
					lrgba[1] += (prgba[1] * alpha - lrgba[1] ) * blend ;
					lrgba[2] += (prgba[2] * alpha - lrgba[2] ) * blend ;
					lrgba[3] += (alpha - lrgba[3]) * blend ;
					
					alpha = bo - bor *  + ( 2 * Math.random() * bor );
					if ( alpha < 0 ) alpha = 0;
					else if ( alpha > 1 ) alpha = 1;
					blend = param_colorBlending.randomValue;
					lrgba[4] += (prgba[4] * alpha - lrgba[4] ) * blend ;
					lrgba[5] += (prgba[5] * alpha - lrgba[5] ) * blend ;
					lrgba[6] += (prgba[6] * alpha - lrgba[6] ) * blend ;
					lrgba[7] += (alpha - lrgba[7]) * blend ;
					
					alpha = bo - bor *  + ( 2 * Math.random() * bor );
					if ( alpha < 0 ) alpha = 0;
					else if ( alpha > 1 ) alpha = 1;
					blend = param_colorBlending.randomValue;
					lrgba[8] += (prgba[8] * alpha - lrgba[8] ) * blend ;
					lrgba[9] += (prgba[9] * alpha - lrgba[9] ) * blend ;
					lrgba[10] += (prgba[10] * alpha - lrgba[10] ) * blend ;
					lrgba[11] += (alpha - lrgba[11]) * blend ;
					
					alpha = bo - bor *  + ( 2 * Math.random() * bor );
					if ( alpha < 0 ) alpha = 0;
					else if ( alpha > 1 ) alpha = 1;
					blend = param_colorBlending.randomValue;
					lrgba[12] += (prgba[12] * alpha - lrgba[12] ) * blend ;
					lrgba[13] += (prgba[13] * alpha - lrgba[13] ) * blend ;
					lrgba[14] += (prgba[14] * alpha - lrgba[14] ) * blend ;
					lrgba[15] += (alpha - lrgba[15]) * blend ;
				} 
				for ( var j:int = 0; j < 16; j++ )
				{
					prgba[j] = lrgba[j];
				}
			}
			return points;
		}
		
		override public function getParameterSetAsXML( path:Array ):XML
		{
			var data:XML = <ColorDecorator />;
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				data.appendChild( _parameters[i].toXML(path) );
			}
			return data;
		}
		
	}
}