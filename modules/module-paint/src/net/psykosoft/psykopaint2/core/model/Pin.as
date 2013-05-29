package net.psykosoft.psykopaint2.core.model
{
	final public class Pin
	{
		
		public var nx:Number,ny:Number,x:Number,y:Number,vx:Number,vy:Number;
		public var sx:Number,sy:Number,tx:Number,ty:Number;
		public var springs:Vector.<Pin>;
		public var maxconnections:int=6;
		public var connections:int=0;
		public var fix:Boolean;
		public var weight:Number=1.0;
		public var k:Number=.09;
		public var d:Number=.6;
		public var iteration:int = -1;
		public var index:int;
		private var distances:Vector.<Number>;
		
		public static var currentIteration:int = 0;
		//public static var activePins:Vector.<Pin> = new Vector.<Pin>();
		//public static var affectedPins:Vector.<Pin> = new Vector.<Pin>();
		public static var activePins:Object = {};
		public static var affectedPins:Object = {};
		
		
		public static var forceFactor:Number = 1;//0.0003;
		
		public static function addActivePin( pin:Pin):void
		{
			activePins[pin.index] = pin;
			pin.iteration = currentIteration; 
		}
		
		public static function addAffectedPin( pin:Pin):void
		{
			affectedPins[pin.index] = pin;
		}
		
		function Pin ( ix:Number, iy:Number,u:Number, v:Number, ifix:Boolean )
		{
			tx=nx=x=ix;
			ty=ny=y=iy;
			sx= u;
			sy = v;
			vx=0;
			vy=0;
			springs=new Vector.<Pin>(maxconnections,true);
			distances=new Vector.<Number>(maxconnections,true);
			fix=ifix;
		}
		
		public function setConnection( p:Pin, d:Number = NaN, counterConnect:Boolean = true ):void
		{
			if ( springs.indexOf(p) == -1 )
			{
				if ( isNaN(d) )
				{
					var dx:Number = x - p.x;
					var dy:Number = y - p.y;
					distances[connections] = d = dx*dx+dy*dy;
				} else {
					distances[connections] = d
				}
				springs[connections++]=p;
				
			}
			if ( counterConnect ) 
			{
				p.setConnection( this, d, false );
			}
		}
		
		public function calculate():void
		{
			if (!fix){
				
				
				vx = (tx-x);
				vy = (ty-y);
				x = tx;
				y = ty;
				for (var i:int=0;i<connections;i++)
				{
					if ( springs[i].iteration != currentIteration )
					{
						var dx:Number = x - springs[i].x;
						var dy:Number = y - springs[i].y;
						var d:Number = (dx*dx+dy*dy) / distances[i];
						if ( d > 0 )
						{
							d = 1 / d;
							if ( d > 1 ) d = 1;
							springs[i].tx +=  vx * 0.5 * d;
							springs[i].ty +=  vy * 0.5 * d;
						} else {
							springs[i].tx +=  vx;
							springs[i].ty +=  vy;
						}
						addAffectedPin(springs[i]);
					}
					//vx+=springs[i].weight*(springs[i].x-x)*k;
					//vy+=springs[i].weight*(springs[i].y-y)*k;
				}
					
				
				/*
				vx+=(tx-x)*k;
				vy+=(ty-y)*k;
				for (var i:int=0;i<connections;i++)
				{
					vx+=springs[i].weight*(springs[i].x-x)*k;
					vy+=springs[i].weight*(springs[i].y-y)*k;
				}
				nx+=vx;
				ny+=vy;
				vx*=d;
				vy*=d;
				*/
			}
		}
		
		public function average( factor:Number = 1):void
		{
			if (!fix){
				for (var i:int=0;i<connections;i++)
				{
					var pin:Pin = springs[i];
					tx += springs[i].tx;
					ty += springs[i].ty;
				}
				x = (1-factor) * x + factor * (tx / (connections+1));
				y = (1-factor) * y + factor *  (ty / (connections+1));
				tx = x;
				ty = y;
				
			}
		}
		
		public function addForce( ivx:Number,ivy:Number):void
		{
			vx+=ivx*forceFactor;
			vy+=ivy*forceFactor;
		}
		
		public function update():void
		{
			x=nx;
			y=ny;
		}
		
		public function addVertex(vertexData:Vector.<Number>):void
		{
			vertexData.push(x, y,sx,sy);
		}
		
		public function setSpring( ik:Number, id:Number):void
		{
			k=ik;
			d=id;
		}
		
		public function setWeight( iw:Number):void
		{
			weight=iw;
		}
	}
}