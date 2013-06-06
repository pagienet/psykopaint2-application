package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import com.greensock.easing.Quint;
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.drawing.paths.helpers.ParticlePoint;
	import net.psykosoft.psykopaint2.core.managers.accelerometer.AccelerometerManager;
	import net.psykosoft.psykopaint2.core.managers.accelerometer.GyroscopeManager;
	
	public class ParticleDecorator extends AbstractPointDecorator
	{
		
		private var maxConcurrentParticles:PsykoParameter;
		
		private var minSpawnDistance:PsykoParameter;

		private var spawnProbability:PsykoParameter;
		private var lifeSpan:PsykoParameter;
		private var acceleration:PsykoParameter;
		private var speed:PsykoParameter;
		private var offsetAngle:PsykoParameter;
		private var curlAngle:PsykoParameter;
		private var renderSteps:PsykoParameter;
		private var updateProbability:PsykoParameter;
		private var curlFlipProbability:PsykoParameter;
		private var useAccelerometer:PsykoParameter;
		private var saturationAdjustment:PsykoParameter;
		private var hueAdjustment:PsykoParameter;
		private var brightnessAdjustment:PsykoParameter;
		private var applyColorMatrix:PsykoParameter;
		private var lastSpawnLocation:SamplePoint;
		private var activeParticles:Vector.<ParticlePoint>;
		private var rng:LCG;
		private var yAxis:Vector3D;
		private var cm:ColorMatrix;
		
		public function ParticleDecorator(  maxConcurrentParticles:int = 5, minSpawnDistance:Number = 20, spawnProbability:Number = 0.02 )
		{
			super( );
			
			this.maxConcurrentParticles = new PsykoParameter( PsykoParameter.IntParameter,"Max Concurrent Particles",maxConcurrentParticles,1,32);
			this.minSpawnDistance       = new PsykoParameter( PsykoParameter.NumberParameter,"Minimum Spawn Distance",minSpawnDistance,0,200);
			this.spawnProbability       = new PsykoParameter( PsykoParameter.NumberParameter,"Spawn Probability",spawnProbability,0,1);
			lifeSpan 					= new PsykoParameter( PsykoParameter.IntRangeParameter,"Lifespan",10,400,1,1000);
			acceleration 				= new PsykoParameter( PsykoParameter.NumberRangeParameter,"Acceleration",0.92,1,0,2);
			speed 						= new PsykoParameter( PsykoParameter.NumberRangeParameter,"Speed",1,10,0,30);
			offsetAngle 				= new PsykoParameter( PsykoParameter.AngleRangeParameter,"Offset Angle",0,90,0,180);
			curlAngle 					= new PsykoParameter( PsykoParameter.AngleRangeParameter,"Curl Angle",0,4,0,90);
			renderSteps 				= new PsykoParameter( PsykoParameter.IntParameter,"Render Steps per Frame",20,1,50);
			updateProbability 			= new PsykoParameter( PsykoParameter.NumberRangeParameter,"Update Probability",0.5,1,0,1);
			curlFlipProbability 		= new PsykoParameter( PsykoParameter.NumberRangeParameter,"Curl Flip Probability",0,0.01,0,1);
			useAccelerometer				= new PsykoParameter( PsykoParameter.BooleanParameter,"Use Accelerometer",0);
			applyColorMatrix			= new PsykoParameter( PsykoParameter.BooleanParameter,"Change Particle Colors",0);
			
			saturationAdjustment  		= new PsykoParameter( PsykoParameter.NumberParameter,"Particle Saturation Change",1,-2, 2);
			hueAdjustment  				= new PsykoParameter( PsykoParameter.AngleParameter,"Particle Hue Change",0,-360, 360);
			brightnessAdjustment  		= new PsykoParameter( PsykoParameter.NumberParameter,"Particle Brightness Change",0,-255, 255);
			
			_parameters.push(this.maxConcurrentParticles,
							 this.minSpawnDistance,
							 this.spawnProbability,
							 lifeSpan,
							 acceleration,
							 speed,
							 offsetAngle,
							 curlAngle,
							 renderSteps,
							 updateProbability,
							 curlFlipProbability,
							 useAccelerometer,
							 applyColorMatrix,
							 saturationAdjustment, 
							 hueAdjustment, 
							 brightnessAdjustment
			
			
			);
			
			activeParticles = new Vector.<ParticlePoint>();
			rng = new LCG(Math.random() * 0xffffffff);
			yAxis = new Vector3D();
			cm = new ColorMatrix();
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			
			
			if ( useAccelerometer.booleanValue )
			{
				yAxis = AccelerometerManager.gravityVector;
				//var orientationMatrix:Matrix3D = GyroscopeManager.orientationMatrix.clone();
				//orientationMatrix.invert();
				//orientationMatrix.copyColumnTo(1, yAxis);
				var gravitySpeed:Number = Math.sqrt(yAxis.x * yAxis.x +  yAxis.y *  yAxis.y);
				//PsykoSocket.sendString('<msg src="ParticleDecorator.process value="'+yAxis.x+' '+yAxis.z+' '+gravitySpeed+'"/>');
			}	
			var count:int = points.length;
			if ( applyColorMatrix.booleanValue )
			{
				cm.reset();
				cm.adjustSaturation( saturationAdjustment.numberValue );
				cm.adjustHue( hueAdjustment.degrees );
				cm.adjustBrightness( brightnessAdjustment.numberValue );
			}
			for ( var i:int = activeParticles.length; --i > -1; )
			{
				for ( var j:int = 0; j < renderSteps.intValue; j++ )
				{
					if ( applyColorMatrix.booleanValue ) cm.applyMatrixToVector( activeParticles[i].samplePoint.colorsRGBA );
					
					if ( !activeParticles[i].update(-yAxis.x, yAxis.y) )
					{
						PathManager.recycleSamplePoint(activeParticles[i].samplePoint);
						activeParticles.splice(i,1);
						break;
					} else {
						if ( rng.getChance( activeParticles[i].updateProbability ) )
							points.push(activeParticles[i].samplePoint.getClone() );
					}
				}
			}
			
			for ( j = 0; j < count && maxConcurrentParticles.intValue > activeParticles.length; j++ )
			{
				if ( rng.getChance(spawnProbability.numberValue) && ( lastSpawnLocation == null || lastSpawnLocation.squaredDistance(points[j]) >= minSpawnDistance.numberValue ))
				{
					var f:Number = rng.getChance() ? 1 : -1;
					var pc:SamplePoint = points[j].getClone();
					var particle:ParticlePoint;
					if ( useAccelerometer.booleanValue ) 
					{
						//pc.angle = Math.atan2(yAxis.x, yAxis.y);
						particle = new ParticlePoint(pc, 
							pc.speed > 0 ? lifeSpan.lowerRangeValue + rng.getNumber(0, lifeSpan.rangeValue * pc.speed ) : 20, 
							0,
							rng.getNumber(acceleration.lowerRangeValue, acceleration.upperRangeValue ),
							0,
							0,
							0,
							rng.getNumber(updateProbability.lowerRangeValue,updateProbability.upperRangeValue )
						);
					} else {
						particle = new ParticlePoint(pc, 
							lifeSpan.lowerRangeValue + rng.getNumber(0, lifeSpan.rangeValue * pc.speed ), 
							rng.getNumber(speed.lowerRangeValue, speed.upperRangeValue ),
							rng.getNumber(acceleration.lowerRangeValue, acceleration.upperRangeValue ),
							rng.getNumber(offsetAngle.lowerRangeValue, offsetAngle.upperRangeValue ) * f,
							rng.getMappedNumber(curlAngle.lowerRangeValue, curlAngle.upperRangeValue, Quint.easeIn ) * f,
							rng.getNumber(curlFlipProbability.lowerRangeValue, curlFlipProbability.upperRangeValue ),
							rng.getNumber(updateProbability.lowerRangeValue,updateProbability.upperRangeValue )
						);
					}
					activeParticles.push( particle );
				}
				
			}
			return points;
		}
		
		override public function getParameterSet(path:Array ):XML
		{
			var result:XML = <ParticleDecorator/>;
			
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				result.appendChild( _parameters[i].toXML(path) );
			}
			
			return result;
		}
		
		override public function hasActivePoints():Boolean
		{
			return activeParticles.length > 0;
		}
		
		override public function clearActivePoints():void
		{
			for ( var i:int = 0; i < activeParticles.length; i++ )
			{
				PathManager.recycleSamplePoint( activeParticles[i].samplePoint );
			}
			activeParticles.length = 0;
		}
	}
}