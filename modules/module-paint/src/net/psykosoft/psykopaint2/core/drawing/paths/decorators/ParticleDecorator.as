package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import com.greensock.easing.Quint;
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.geom.Vector3D;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.drawing.paths.helpers.ParticlePoint;
	import net.psykosoft.psykopaint2.core.managers.accelerometer.AccelerometerManager;
	
	final public class ParticleDecorator extends AbstractPointDecorator
	{
		private var rng:LCG;
		private var yAxis:Vector3D;
		private var cm:ColorMatrix;
		private var lastSpawnLocation:SamplePoint;
		private var activeParticles:Vector.<ParticlePoint>;
		private const _applyArray:Array = [0,0,1,1];
		
		//"Max Concurrent Particles" - IntValue
		public var param_maxConcurrentParticles:PsykoParameter;
		
		//"Minimum Spawn Distance" - NumberValue
		public var param_minSpawnDistance:PsykoParameter;
		
	    //"Spawn Probability" - NumberValue
		public var param_spawnProbability:PsykoParameter;
		
		//"Lifespan" - IntRange
		public var param_lifeSpan:PsykoParameter;
		
		//"Acceleration" - NumberRange
		public var param_acceleration:PsykoParameter;
		
		//"Speed" - NumberRange
		public var param_speed:PsykoParameter;
		
		//"Speed Distribution" - StringList
		public var param_speedDistribution:PsykoParameter;
		
		//"Offset Angle" - AngleRange
		public var param_offsetAngle:PsykoParameter;
		
		//"Curl Angle" - AngleRange
		public var param_curlAngle:PsykoParameter;
		
		//"Render Steps per Frame" - IntValue
		public var param_renderSteps:PsykoParameter;
		
		//"Update Probability" - Number Range
		public var param_updateProbability:PsykoParameter;
		
		//
		public var param_curlFlipProbability:PsykoParameter;
		
		//
		public var param_useAccelerometer:PsykoParameter;
		
		//
		public var param_saturationAdjustment:PsykoParameter;
		
		//
		public var param_hueAdjustment:PsykoParameter;
		
		//
		public var param_brightnessAdjustment:PsykoParameter;
		
		//
		public var param_applyColorMatrix:PsykoParameter;
		
		//
		public var param_lifeSpanDistribution:PsykoParameter;
		
		//
		public var param_dropOriginalPoint:PsykoParameter;
		
		
		public function ParticleDecorator(  maxConcurrentParticles:int = 5, minSpawnDistance:Number = 20, spawnProbability:Number = 0.02 )
		{
			super( );
			
			param_maxConcurrentParticles = new PsykoParameter( PsykoParameter.IntParameter,"Max Concurrent Particles",maxConcurrentParticles,1,64);
			param_minSpawnDistance       = new PsykoParameter( PsykoParameter.NumberParameter,"Minimum Spawn Distance",minSpawnDistance,0,200);
			param_spawnProbability       = new PsykoParameter( PsykoParameter.NumberParameter,"Spawn Probability",spawnProbability,0,1);
			param_lifeSpan 					= new PsykoParameter( PsykoParameter.IntRangeParameter,"Lifespan",10,400,1,1000);
			param_acceleration 				= new PsykoParameter( PsykoParameter.NumberRangeParameter,"Acceleration",0.92,1,0,2);
			param_speed 						= new PsykoParameter( PsykoParameter.NumberRangeParameter,"Speed",1,10,0,30);
			param_speedDistribution   = new PsykoParameter( PsykoParameter.StringListParameter,"Speed Distribution",0,mappingFunctionLabels);
			
			param_offsetAngle 				= new PsykoParameter( PsykoParameter.AngleRangeParameter,"Offset Angle",0,90,0,180);
			param_curlAngle 					= new PsykoParameter( PsykoParameter.AngleRangeParameter,"Curl Angle",0,4,0,90);
			param_renderSteps 				= new PsykoParameter( PsykoParameter.IntParameter,"Render Steps per Frame",20,1,50);
			param_updateProbability 			= new PsykoParameter( PsykoParameter.NumberRangeParameter,"Update Probability",0.5,1,0,1);
			param_curlFlipProbability 		= new PsykoParameter( PsykoParameter.NumberRangeParameter,"Curl Flip Probability",0,0.01,0,1);
			param_useAccelerometer				= new PsykoParameter( PsykoParameter.BooleanParameter,"Use Accelerometer",0);
			param_applyColorMatrix			= new PsykoParameter( PsykoParameter.BooleanParameter,"Change Particle Colors",0);
			param_lifeSpanDistribution   = new PsykoParameter( PsykoParameter.StringListParameter,"Life Span Distribution",0,mappingFunctionLabels);
			
			param_saturationAdjustment  		= new PsykoParameter( PsykoParameter.NumberParameter,"Particle Saturation Change",1,-2, 2);
			param_hueAdjustment  				= new PsykoParameter( PsykoParameter.AngleParameter,"Particle Hue Change",0,-360, 360);
			param_brightnessAdjustment  		= new PsykoParameter( PsykoParameter.NumberParameter,"Particle Brightness Change",0,-255, 255);
			
			param_dropOriginalPoint = new PsykoParameter( PsykoParameter.BooleanParameter,"Drop Original Point",false);
			
			_parameters.push(param_maxConcurrentParticles,
							 param_minSpawnDistance,
							 param_spawnProbability,
							 param_lifeSpan,
							 param_acceleration,
							 param_speed,
							 param_offsetAngle,
							 param_curlAngle,
							 param_renderSteps,
							 param_updateProbability,
							 param_curlFlipProbability,
							 param_useAccelerometer,
							 param_applyColorMatrix,
							 param_saturationAdjustment, 
							 param_hueAdjustment, 
							 param_brightnessAdjustment,
							 param_lifeSpanDistribution,
							 param_speedDistribution,
							 param_dropOriginalPoint
			
			
			);
			
			activeParticles = new Vector.<ParticlePoint>();
			rng = new LCG(Math.random() * 0xffffffff);
			yAxis = new Vector3D();
			cm = new ColorMatrix();
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			
			
			if ( param_useAccelerometer.booleanValue )
			{
				yAxis = AccelerometerManager.gravityVector;
				//var orientationMatrix:Matrix3D = GyroscopeManager.orientationMatrix.clone();
				//orientationMatrix.invert();
				//orientationMatrix.copyColumnTo(1, yAxis);
				var gravitySpeed:Number = Math.sqrt(yAxis.x * yAxis.x +  yAxis.y *  yAxis.y);
				//PsykoSocket.sendString('<msg src="ParticleDecorator.process value="'+yAxis.x+' '+yAxis.z+' '+gravitySpeed+'"/>');
			}	
			var count:int = points.length;
			if ( param_applyColorMatrix.booleanValue )
			{
				cm.reset();
				cm.adjustSaturation( param_saturationAdjustment.numberValue );
				cm.adjustHue( param_hueAdjustment.degrees );
				cm.adjustBrightness( param_brightnessAdjustment.numberValue );
			}
			var oldPointCount:int = points.length;
			for ( var i:int = activeParticles.length; --i > -1; )
			{
				for ( var j:int = 0; j < param_renderSteps.intValue; j++ )
				{
					if ( param_applyColorMatrix.booleanValue ) cm.applyMatrixToVector( activeParticles[i].samplePoint.colorsRGBA );
					
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
			var lifeSpanMapping:Function = mappingFunctions[param_lifeSpanDistribution.index];
			var speedMapping:Function = mappingFunctions[param_speedDistribution.index];
			
			var applyArray:Array = _applyArray;
			
			for ( j = 0; j < count && param_maxConcurrentParticles.intValue > activeParticles.length; j++ )
			{
				if ( param_spawnProbability.chance && ( lastSpawnLocation == null || lastSpawnLocation.squaredDistance(points[j]) >= param_minSpawnDistance.numberValue ))
				{
					var f:Number = rng.getChance() ? 1 : -1;
					var pc:SamplePoint = points[j].getClone();
					var particle:ParticlePoint;
					applyArray[0] = rng.getNumber();
					var ls:Number = param_lifeSpan.lowerRangeValue + lifeSpanMapping.apply(0,applyArray) * param_lifeSpan.rangeValue;
					applyArray[0] = rng.getNumber();
					var spd:Number = param_speed.lowerRangeValue + speedMapping.apply(0,applyArray) * param_speed.rangeValue;
					
					
					if ( param_useAccelerometer.booleanValue ) 
					{
						//pc.angle = Math.atan2(yAxis.x, yAxis.y);
						
						particle = new ParticlePoint(pc, 
							ls, 
							0,
							param_acceleration.randomValue,
							0,
							0,
							0,
							param_updateProbability.randomValue
						);
					} else {
						particle = new ParticlePoint(pc, 
							ls, 
							spd,
							param_acceleration.randomValue,
							param_offsetAngle.randomValue * f,
							rng.getMappedNumber(param_curlAngle.lowerRangeValue, param_curlAngle.upperRangeValue, Quint.easeIn ) * f,
							param_curlFlipProbability.randomValue,
							param_updateProbability.randomValue
						);
					}
					activeParticles.push( particle );
				}
				
			}
			if ( param_dropOriginalPoint.booleanValue )
			{
				PathManager.recycleSamplePoints( points.splice(0,oldPointCount) );
			}
			return points;
		}
		
		override public function getParameterSetAsXML(path:Array ):XML
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