package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	
	import com.quasimondo.geom.ColorMatrix;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManagerCallbackInfo;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	
	public class ColorDecorator extends AbstractPointDecorator
	{
		private var pickColor:PsykoParameter;
		private var saturationAdjustment:PsykoParameter;
		private var hueAdjustment:PsykoParameter;
		private var brightnessAdjustment:PsykoParameter;
		private var presetColor:PsykoParameter;
		private var fixedColor:PsykoParameter;
		
		private var rng:LCG;
		private var cm:ColorMatrix;
		
		public function ColorDecorator()
		{
			super();
			pickColor  = new PsykoParameter( PsykoParameter.BooleanParameter,"Pick Color",1 );
			fixedColor  = new PsykoParameter( PsykoParameter.BooleanParameter,"Fixed Color",0 );
			presetColor = new PsykoParameter( PsykoParameter.IntListParameter,"Colors",0,[0xff000000,0xffffffff,0xff808080]);
			saturationAdjustment  = new PsykoParameter( PsykoParameter.NumberParameter,"Saturation",1,-3, 3);
			hueAdjustment  = new PsykoParameter( PsykoParameter.AngleParameter,"Hue",0,-180, 180);
			brightnessAdjustment  = new PsykoParameter( PsykoParameter.NumberParameter,"Brightness",0,-255, 255);
			
			_parameters.push(pickColor, fixedColor, presetColor, saturationAdjustment, hueAdjustment, brightnessAdjustment);
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
			
			if ( fixedColor.booleanValue ) 
			{
				var c:uint = presetColor.intValue;
				var a:Number = ((c >>> 24) & 0xff) / 255;
				var r:Number = ((c >>> 16) & 0xff) / 255;
				var g:Number = ((c >>> 8) & 0xff) / 255;
				var b:Number = (c & 0xff) / 255;
				
			}
			
			var cb:PathManagerCallbackInfo =  manager.callbacks;
			for ( var i:int = 0; i < points.length; i++ )
			{
				if (pickColor.booleanValue && cb.onPickColor ) 
				{
					cb.onPickColor.apply(cb.callbackObject, [points[i]] );
				} 
				if ( fixedColor.booleanValue ) 
				{
					var rgba:Vector.<Number> = points[i].colorsRGBA;
					rgba[0] = rgba[4] = rgba[8] = rgba[12] = r;
					rgba[1] = rgba[5] = rgba[9] = rgba[13] = g;
					rgba[2] = rgba[6] = rgba[10] = rgba[14] = b;
					rgba[3] = rgba[7] = rgba[11] = rgba[15] = a;
				}
				//TODO: this could be skipped if there is no color adjustment:
				if ( applyMatrix ) cm.applyMatrixToVector( points[i].colorsRGBA );
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