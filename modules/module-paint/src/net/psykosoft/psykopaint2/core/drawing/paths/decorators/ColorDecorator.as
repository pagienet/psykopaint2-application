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
		//public static const PARAMETER_SL_COLOR_MODE:String = "Color Mode";
		public static const PARAMETER_IL_COLOR_SWATCH:String = "Color Swatch";
		public static const PARAMETER_C_COLOR:String = "Color";
		public static const PARAMETER_B_COLORMATRIX:String = "Appy Color Matrix";
		public static const PARAMETER_NR_SATURATION:String = "Saturation";
		public static const PARAMETER_AR_HUE:String = "Hue";
		public static const PARAMETER_NR_BRIGHTNESS:String = "Brightness";
		public static const PARAMETER_NR_COLOR_BLENDING:String = "Color Blending";
		public static const PARAMETER_N_OPACITY:String = "Opacity";
		public static const PARAMETER_N_OPACITY_RANGE:String = "Opacity Range";
		public static const PARAMETER_SL_PICK_RADIUS_MODE:String = "Pick Radius Mode";
		public static const PARAMETER_NR_PICK_RADIUS:String = "Color Pick Radius";
		public static const PARAMETER_NR_SMOOTH_FACTOR:String = "Color Smooth Factor";
		public static const PARAMETER_N_MAXIMUM_SPEED:String  = "Maximum Speed";
		public static const PARAMETER_N_PICK_RANDOM_OFFSET_FACTOR:String  = "Random Pick Offset";
		
		public static const INDEX_MODE_PICK_COLOR:int = 0;
		public static const INDEX_MODE_FIXED_COLOR:int = 1;
		
		public var param_saturationAdjustment:PsykoParameter;
		public var param_hueAdjustment:PsykoParameter;
		public var param_brightnessAdjustment:PsykoParameter;
		public var param_presetColor:PsykoParameter;
		public var param_colorBlending:PsykoParameter;
		public var param_brushOpacity:PsykoParameter;
		public var param_brushOpacityRange:PsykoParameter;
		public var param_pickRadius:PsykoParameter;
		public var param_pickRadiusMode:PsykoParameter;
		public var param_maxSpeed:PsykoParameter;
		public var param_applyColorMatrix:PsykoParameter;
		public var param_pickOffsetFactor:PsykoParameter;
		public var param_smoothFactor:PsykoParameter;
		public var param_color:PsykoParameter;
		
		private var cm:ColorMatrix;
		private const lastRGBA:Vector.<Number> = new Vector.<Number>(16,true);
		private const _applyArray:Array = [];
		
		public function ColorDecorator()
		{
			super();
			//colorMode  = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_COLOR_MODE,0,["Pick Color","Fixed Color"] );
			param_presetColor = new PsykoParameter( PsykoParameter.IntListParameter,PARAMETER_IL_COLOR_SWATCH,0,[0x000000,0xffffff,0x808080,0xc00000]);
			
			param_applyColorMatrix  = new PsykoParameter( PsykoParameter.BooleanParameter,PARAMETER_B_COLORMATRIX,false);
			
			param_saturationAdjustment  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_SATURATION,1,1,-3, 3);
			param_hueAdjustment  = new PsykoParameter( PsykoParameter.AngleRangeParameter,PARAMETER_AR_HUE,0,0,-180, 180);
			param_brightnessAdjustment  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_BRIGHTNESS,0,0,-255, 255);
			
			param_colorBlending  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_COLOR_BLENDING,0.7,0.7,0, 1);
			param_brushOpacity  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_OPACITY,0.9,0,1);
			param_brushOpacityRange  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_OPACITY_RANGE,0.2,0,1);
			
			param_pickRadiusMode  = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_PICK_RADIUS_MODE,0,["Fixed","Speed"] );
			param_pickRadius  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_PICK_RADIUS,1,1,0,1);
			param_pickOffsetFactor  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_PICK_RANDOM_OFFSET_FACTOR,0,0,200);
			
			param_smoothFactor  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_SMOOTH_FACTOR,1,1,0,1);
			param_color  = new PsykoParameter( PsykoParameter.ColorParameter,PARAMETER_C_COLOR,0x000000);
			param_maxSpeed  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MAXIMUM_SPEED,20,1,100);
			
			
			_parameters.push(param_presetColor, param_applyColorMatrix,param_saturationAdjustment, param_hueAdjustment, param_brightnessAdjustment,param_colorBlending,param_brushOpacity,param_brushOpacityRange,param_pickRadius,param_pickRadiusMode,param_smoothFactor,param_color,param_maxSpeed,param_pickOffsetFactor);
			cm = new ColorMatrix();
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var applyMatrix:Boolean = param_applyColorMatrix.booleanValue;
			var applyArray:Array = _applyArray;
			
			if ( applyMatrix )
			{
				cm.reset();
				cm.adjustSaturation( param_saturationAdjustment.randomValue );
				cm.adjustHue( param_hueAdjustment.randomDegreeValue );
				cm.adjustBrightness( param_brightnessAdjustment.randomValue );
			}
			
			var radiusMode:int = param_pickRadiusMode.index;
			var minPickRadius:Number = param_pickRadius.lowerRangeValue;
			var pickRadiusRange:Number = param_pickRadius.rangeValue;
			var ms:Number = param_maxSpeed.numberValue;
			var pof:Number = param_pickOffsetFactor.numberValue;
			var bo:Number = Quad.easeIn(param_brushOpacity.numberValue,0,1,1);
			var bor:Number = param_brushOpacityRange.numberValue;
			
			//var mode:int = colorMode.index;
			//if ( mode == 1 ) 
			//{
			var c:uint = param_color.colorValue;
			var r:Number = (((c >>> 16) & 0xff) / 255);
			var g:Number = (((c >>> 8) & 0xff) / 255);
			var b:Number = ((c & 0xff) / 255);
				
			//}
			
			
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
				//TODO: this could be skipped if there is no color adjustment:
				if ( applyMatrix ) cm.applyMatrixToVector( prgba );
				
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