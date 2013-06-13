package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quint;
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	public class StationaryDecorator extends AbstractPointDecorator
	{
		
		private var delay:PsykoParameter;
		
		private var rng:LCG;
		private var lastX:Number;
		private var lastY:Number;
		private var lastAngle:Number;
		private var sizeRange:PsykoParameter;
		private var maxOffset:PsykoParameter;
		private var delayTriggered:Boolean;
		private var timeStamp:int;
		
		public function StationaryDecorator(  )
		{
			super( );
			
			sizeRange    = new PsykoParameter( PsykoParameter.NumberRangeParameter,"Size",0.25,0.75,0,1);
			maxOffset    = new PsykoParameter( PsykoParameter.NumberParameter,"Maximum Offset",0,0,500);
			delay   	 = new PsykoParameter( PsykoParameter.IntParameter,"Delay",100,0,1000);
			_parameters.push( sizeRange, maxOffset, delay );
			rng = new LCG(Math.random() * 0xffffffff);
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			if ( points.length == 0 )
			{
				if ( fingerIsDown )
				{
					if ( delayTriggered && 	(getTimer()-timeStamp >=  delay.intValue ))
					{
						var angle:Number = rng.getNumber( 0, Math.PI * 2);
						var distance:Number =  rng.getMappedNumber(0, maxOffset.numberValue, Quad.easeIn );
						points.push( PathManager.getSamplePoint(lastX +  Math.cos(angle) * distance,lastY +  Math.sin(angle) * distance,0,rng.getNumber(sizeRange.lowerRangeValue,sizeRange.upperRangeValue),lastAngle ));
					} else if ( !delayTriggered )
					{
						delayTriggered = true;
						timeStamp = getTimer();
					}
				} else {
					delayTriggered = false;
				}
			} else {
				if ( lastX != points[points.length-1].x || lastY != points[points.length-1].y ) delayTriggered = false;
				lastX = points[points.length-1].x;
				lastY = points[points.length-1].y;
				lastAngle = points[points.length-1].angle;
			}
			
			return points;
		}
		
		override public function getParameterSet(path:Array ):XML
		{
			var result:XML = <StationaryDecorator/>;
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				result.appendChild( _parameters[i].toXML(path) );
			}
			return result;
		}
		
		override public function hasActivePoints():Boolean
		{
			return false;
		}
		
		
	}
}