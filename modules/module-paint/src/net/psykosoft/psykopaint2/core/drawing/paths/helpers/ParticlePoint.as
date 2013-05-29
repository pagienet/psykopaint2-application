package net.psykosoft.psykopaint2.core.drawing.paths.helpers
{
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	public class ParticlePoint
	{
		public var samplePoint:SamplePoint;
		public var updateProbability:Number;
		private var lifeSpan:int;
		private var acceleration:Number;
		private var curlAngle:Number;
		private var speed:Number;
		private var curlFlipProbability:Number;
		
		public function ParticlePoint( samplePoint:SamplePoint, 
									   lifeSpan:int, 
									   speed:Number, 
									   acceleration:Number, 
									   offsetAngle:Number, 
									   curlAngle:Number,
									   curlFlipProbability:Number,
									   updateProbability:Number)
		{
			this.samplePoint = samplePoint;
			samplePoint.angle += offsetAngle;
			this.speed = speed;
			this.lifeSpan = lifeSpan;
			this.acceleration = acceleration;
			this.curlAngle = curlAngle;
			this.updateProbability = updateProbability;
			this.curlFlipProbability = curlFlipProbability;
		}
		
		public function update( gravityX:Number, gravityY:Number ):Boolean
		{
			samplePoint.x += Math.cos( samplePoint.angle ) * speed + gravityX;
			samplePoint.y += Math.sin( samplePoint.angle ) * speed + gravityY;
			speed *= acceleration;
			samplePoint.speed *= acceleration;
			if ( Math.random() < curlFlipProbability ) curlAngle = -curlAngle;
			samplePoint.angle += curlAngle;
			lifeSpan--;
			return lifeSpan > 0;
		}
	}
}