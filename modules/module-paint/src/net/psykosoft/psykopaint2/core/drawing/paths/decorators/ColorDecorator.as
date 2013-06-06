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
		
		private var rng:LCG;
		private var cm:ColorMatrix;
		
		public function ColorDecorator()
		{
			super();
			pickColor  = new PsykoParameter( PsykoParameter.BooleanParameter,"Pick Color",1 );
			saturationAdjustment  = new PsykoParameter( PsykoParameter.NumberParameter,"Saturation",1,-3, 3);
			hueAdjustment  = new PsykoParameter( PsykoParameter.AngleParameter,"Hue",0,-180, 180);
			brightnessAdjustment  = new PsykoParameter( PsykoParameter.NumberParameter,"Brightness",0,-255, 255);
			
			_parameters.push(pickColor, saturationAdjustment, hueAdjustment, brightnessAdjustment);
			rng = new LCG(Math.random() * 0xffffffff);
			cm = new ColorMatrix();
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			
			cm.reset();
			cm.adjustSaturation( saturationAdjustment.numberValue );
			cm.adjustHue( hueAdjustment.degrees );
			cm.adjustBrightness( brightnessAdjustment.numberValue );
			
			var cb:PathManagerCallbackInfo =  manager.callbacks;
			for ( var i:int = 0; i < points.length; i++ )
			{
				if (pickColor.booleanValue && cb.onPickColor ) 
				{
					cb.onPickColor.apply(cb.callbackObject, [points[i]] );
				}
				cm.applyMatrixToVector( points[i].colorsRGBA );
			}
			return points;
		}
		
		override public function getParameterSet( path:Array ):XML
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