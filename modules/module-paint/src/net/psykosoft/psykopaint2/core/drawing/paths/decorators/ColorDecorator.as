package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	
	import com.quasimondo.geom.ColorMatrix;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManagerCallbackInfo;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	
	final public class ColorDecorator extends AbstractPointDecorator
	{
		public static const PARAMETER_COLOR_MODE:String = "Color Mode";
		public static const PARAMETER_COLOR:String = "Color";
		public static const PARAMETER_SATURATION:String = "Saturation";
		public static const PARAMETER_HUE:String = "Hue";
		public static const PARAMETER_BRIGHTNESS:String = "Brightness";
		public static const PARAMETER_COLOR_BLENDING:String = "Color Blending";
		public static const PARAMETER_OPACITY:String = "Opacity";
		
		
		private var colorMode:PsykoParameter;
		private var saturationAdjustment:PsykoParameter;
		private var hueAdjustment:PsykoParameter;
		private var brightnessAdjustment:PsykoParameter;
		private var presetColor:PsykoParameter;
		private var colorBlending:PsykoParameter;
		private var brushOpacity:PsykoParameter;
		
		private var rng:LCG;
		private var cm:ColorMatrix;
		private const tmpRGBA:Vector.<Number> = new Vector.<Number>(16,true);
		
		public function ColorDecorator()
		{
			super();
			colorMode  = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_COLOR_MODE,0,["Pick Color","Fixed Color"] );
			presetColor = new PsykoParameter( PsykoParameter.IntListParameter,PARAMETER_COLOR,0,[0xff000000,0xffffffff,0xff808080]);
			saturationAdjustment  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_SATURATION,1,-3, 3);
			hueAdjustment  = new PsykoParameter( PsykoParameter.AngleParameter,PARAMETER_HUE,0,-180, 180);
			brightnessAdjustment  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_BRIGHTNESS,0,-255, 255);
			colorBlending  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_COLOR_BLENDING,0.7,0.7,0, 1);
			brushOpacity  = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_OPACITY,0.9,0.9,0,1);
			
			
			_parameters.push(colorMode, presetColor, saturationAdjustment, hueAdjustment, brightnessAdjustment,colorBlending,brushOpacity);
			rng = new LCG(Math.random() * 0xffffffff);
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
				var a:Number = ((c >>> 24) & 0xff) / 255;
				var r:Number = ((c >>> 16) & 0xff) / 255;
				var g:Number = ((c >>> 8) & 0xff) / 255;
				var b:Number = (c & 0xff) / 255;
				
			}
			var rgba:Vector.<Number> = tmpRGBA;
			
			var cb:PathManagerCallbackInfo =  manager.callbacks;
			for ( var i:int = 0; i < points.length; i++ )
			{
				if ( mode == 0 )
				{
					if ( cb.onPickColor ) cb.onPickColor.apply(cb.callbackObject, [points[i],rgba] );
				} else {
					rgba[0] = rgba[4] = rgba[8] = rgba[12] = r;
					rgba[1] = rgba[5] = rgba[9] = rgba[13] = g;
					rgba[2] = rgba[6] = rgba[10] = rgba[14] = b;
					rgba[3] = rgba[7] = rgba[11] = rgba[15] = a;
				}
				//TODO: this could be skipped if there is no color adjustment:
				if ( applyMatrix ) cm.applyMatrixToVector( rgba );
				
				var prgba:Vector.<Number> = points[i].colorsRGBA;
				var blend:Number = rng.getNumber( colorBlending.lowerRangeValue, colorBlending.upperRangeValue );
				var alpha:Number = rng.getNumber( brushOpacity.lowerRangeValue, brushOpacity.upperRangeValue );
				prgba[0] += (rgba[0] * alpha - prgba[0] )  * blend ;
				prgba[1] += (rgba[1] * alpha - prgba[1] ) * blend ;
				prgba[2] += (rgba[2] * alpha - prgba[2] ) * blend ;
				prgba[3] += (alpha - prgba[3]) * blend ;
				prgba[4] += (rgba[4] * alpha - prgba[4] )  * blend ;
				prgba[5] += (rgba[5] * alpha - prgba[5] ) * blend ;
				prgba[6] += (rgba[6] * alpha - prgba[6] ) * blend ;
				prgba[7] += (alpha - prgba[7]) * blend ;
				prgba[8] += (rgba[8] * alpha - prgba[8] )  * blend ;
				prgba[9] += (rgba[9] * alpha - prgba[9] ) * blend ;
				prgba[10] += (rgba[10] * alpha - prgba[10] ) * blend ;
				prgba[11] += (alpha - prgba[11]) * blend ;
				prgba[12] += (rgba[12] * alpha - prgba[12] )  * blend ;
				prgba[13] += (rgba[13] * alpha - prgba[13] ) * blend ;
				prgba[14] += (rgba[14] * alpha - prgba[14] ) * blend ;
				prgba[15] += (alpha - prgba[15]) * blend ;
				
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