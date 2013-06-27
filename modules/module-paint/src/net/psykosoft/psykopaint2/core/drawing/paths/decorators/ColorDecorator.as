package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	
	import com.quasimondo.geom.ColorMatrix;
	
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManagerCallbackInfo;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	
	final public class ColorDecorator extends AbstractPointDecorator
	{
		public static const PARAMETER_SL_COLOR_MODE:String = "Color Mode";
		public static const PARAMETER_IL_COLOR:String = "Color";
		public static const PARAMETER_N_SATURATION:String = "Saturation";
		public static const PARAMETER_A_HUE:String = "Hue";
		public static const PARAMETER_N_BRIGHTNESS:String = "Brightness";
		public static const PARAMETER_NR_COLOR_BLENDING:String = "Color Blending";
		public static const PARAMETER_NR_OPACITY:String = "Opacity";
		public static const PARAMETER_NR_PICK_RADIUS:String = "Color Pick Radius";
		public static const PARAMETER_NR_SMOOTH_FACTOR:String = "Color Smooth Factor";
		
		
		private var colorMode:PsykoParameter;
		private var saturationAdjustment:PsykoParameter;
		private var hueAdjustment:PsykoParameter;
		private var brightnessAdjustment:PsykoParameter;
		private var presetColor:PsykoParameter;
		private var colorBlending:PsykoParameter;
		private var brushOpacity:PsykoParameter;
		private var pickRadius:PsykoParameter;
		private var smoothFactor:PsykoParameter;
		
		private var cm:ColorMatrix;
		private const lastRGBA:Vector.<Number> = new Vector.<Number>(16,true);
		
		public function ColorDecorator()
		{
			super();
			colorMode  = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_COLOR_MODE,0,["Pick Color","Fixed Color"] );
			presetColor = new PsykoParameter( PsykoParameter.IntListParameter,PARAMETER_IL_COLOR,0,[0x000000,0xffffff,0x808080]);
			saturationAdjustment  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_SATURATION,1,-3, 3);
			hueAdjustment  = new PsykoParameter( PsykoParameter.AngleParameter,PARAMETER_A_HUE,0,-180, 180);
			brightnessAdjustment  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_BRIGHTNESS,0,-255, 255);
			colorBlending  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_COLOR_BLENDING,0.7,0.7,0, 1);
			brushOpacity  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_OPACITY,0.9,0.9,0,1);
			pickRadius  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_PICK_RADIUS,1,1,0,1);
			smoothFactor  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_SMOOTH_FACTOR,1,1,0,1);
			
			
			_parameters.push(colorMode, presetColor, saturationAdjustment, hueAdjustment, brightnessAdjustment,colorBlending,brushOpacity,pickRadius,smoothFactor);
			cm = new ColorMatrix();
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var applyMatrix:Boolean = ( saturationAdjustment.numberValue != 1 || hueAdjustment.degrees != 0 || brightnessAdjustment.numberValue != 0 );
				
			if ( applyMatrix )
			{
				cm.reset();
				cm.adjustSaturation( saturationAdjustment.numberValue );
				cm.adjustHue( hueAdjustment.degrees );
				cm.adjustBrightness( brightnessAdjustment.numberValue );
			}
			
			var mode:int = colorMode.index;
			
			if ( mode == 1 ) 
			{
				var c:uint = presetColor.intValue;
				var r:Number = (((c >>> 16) & 0xff) / 255);
				var g:Number = (((c >>> 8) & 0xff) / 255);
				var b:Number = ((c & 0xff) / 255);
				
			}
			
			var cb:PathManagerCallbackInfo =  manager.callbacks;
			for ( var i:int = 0; i < points.length; i++ )
			{
				var prgba:Vector.<Number> = points[i].colorsRGBA;
				
				if ( mode == 0 )
				{
					if ( cb.onPickColor ) cb.onPickColor.apply(cb.callbackObject, [points[i], pickRadius.randomValue, smoothFactor.randomValue] );
				} else {
					prgba[0] = prgba[4] = prgba[8] = prgba[12] = r;
					prgba[1] = prgba[5] = prgba[9] = prgba[13] = g;
					prgba[2] = prgba[6] = prgba[10] = prgba[14] = b;
					prgba[3] = prgba[7] = prgba[11] = prgba[15] = 1;
				}
				//TODO: this could be skipped if there is no color adjustment:
				if ( applyMatrix ) cm.applyMatrixToVector( prgba );
				
				var lrgba:Vector.<Number> = lastRGBA;
				
				if (points[i].first )
				{
					alpha = brushOpacity.randomValue;
					lrgba[0] = prgba[0] * alpha;
					lrgba[1] = prgba[1] * alpha;
					lrgba[2] = prgba[2] * alpha;
					lrgba[3] = alpha;
					
					alpha = brushOpacity.randomValue;
					lrgba[4] = prgba[4] * alpha;
					lrgba[5] = prgba[5] * alpha;
					lrgba[6] = prgba[6] * alpha;
					lrgba[7] = alpha;
					
					alpha = brushOpacity.randomValue;
					lrgba[8] = prgba[8] * alpha;
					lrgba[9] = prgba[9] * alpha;
					lrgba[10] = prgba[10] * alpha;
					lrgba[11] = alpha;
					
					
					alpha = brushOpacity.randomValue;
					lrgba[12] = prgba[12] * alpha;
					lrgba[13] = prgba[13] * alpha;
					lrgba[14] = prgba[14] * alpha;
					lrgba[15] = alpha;
				} else {
					var alpha:Number = brushOpacity.randomValue;
					var blend:Number = colorBlending.randomValue;
					lrgba[0] += (prgba[0] * alpha - lrgba[0] )  * blend ;
					lrgba[1] += (prgba[1] * alpha - lrgba[1] ) * blend ;
					lrgba[2] += (prgba[2] * alpha - lrgba[2] ) * blend ;
					lrgba[3] += (alpha - lrgba[3]) * blend ;
					
					alpha = brushOpacity.randomValue;
					blend = colorBlending.randomValue;
					lrgba[4] += (prgba[4] * alpha - lrgba[4] )  * blend ;
					lrgba[5] += (prgba[5] * alpha - lrgba[5] ) * blend ;
					lrgba[6] += (prgba[6] * alpha - lrgba[6] ) * blend ;
					lrgba[7] += (alpha - lrgba[7]) * blend ;
					
					alpha = brushOpacity.randomValue;
					blend = colorBlending.randomValue;
					lrgba[8] += (prgba[8] * alpha - lrgba[8] )  * blend ;
					lrgba[9] += (prgba[9] * alpha - lrgba[9] ) * blend ;
					lrgba[10] += (prgba[10] * alpha - lrgba[10] ) * blend ;
					lrgba[11] += (alpha - lrgba[11]) * blend ;
					
					alpha = brushOpacity.randomValue;
					blend = colorBlending.randomValue;
					lrgba[12] += (prgba[12] * alpha - lrgba[12] )  * blend ;
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