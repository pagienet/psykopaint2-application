package com.quasimondo.data
{
	final public class ProximityQuantizer
	{
		public var clusters:Vector.<QuantizeDataRGB>;
		private var maxClusters:int;
		
		public function ProximityQuantizer( maximumClusters:int = 5 )
		{
			reset( maximumClusters );
		}
		
		public function reset( maxClusters:int ):void
		{
			setMaxClusters( maxClusters );
			clusters = new Vector.<QuantizeDataRGB>;
		}
		
		public function setMaxClusters( maxClusters:int ):void
		{
			this.maxClusters = maxClusters;
		}
		
		// returns unused or deleted cluster
		public function addData( data:QuantizeDataRGB ):QuantizeDataRGB
		{
			var closest:QuantizeDataRGB;
			if ( clusters.length < maxClusters || ( closest= getClosestCluster( data )) == null && !closest.isWithinRadius( data )  )
			{
				return addCluster( data );
				
			} else {
				closest.merge( data );
				return data;
			}
		}
		
		public function addCluster( data:QuantizeDataRGB ):QuantizeDataRGB
		{
			clusters.push( data );
			var removed:QuantizeDataRGB;
			while ( clusters.length > maxClusters )
			{
				removed = removeLeastSignificantCluster();
			}
			return removed;
		}
		
		public function removeClusterAt( index:int ):QuantizeDataRGB
		{
			var removed:QuantizeDataRGB = clusters[index];
			clusters.splice( index, 1 );
			return removed;
		}
		
		public function removeCluster( data:QuantizeDataRGB ):void
		{
			for ( var i:int = 0; i < clusters.length; i++ )
			{
				if ( clusters[i] == data )
				{
					removeClusterAt( i );
					break;
				}
			}
		}
		
		public function getLeastSignificantCluster():QuantizeDataRGB
		{
			var d:Number, i:int, j:int;
			
			for ( i = 0; i < clusters.length; i++ )
			{
				clusters[i].clearDistanceCache();
			}
			
			var smallestDistance:Number = Number.MAX_VALUE;
			var smallest_i:int, smallest_j:int, smallest_weight:Number;
			
			
			var cluster:QuantizeDataRGB;
			for ( i = 0; i < clusters.length - 1; i++ )
			{
				cluster = clusters[i];
				for ( j = i + 1; j < clusters.length; j++ )
				{
					d = cluster.getDistanceTo(clusters[j]);
					if ( d < smallestDistance || ( d == smallestDistance && smallest_weight > cluster.getWeight() + clusters[j].getWeight()) )
					{
						smallestDistance = d;
						smallest_i = i;
						smallest_j = j;
						smallest_weight = cluster.getWeight() + clusters[j].getWeight(); 
					} 
				}
			}
			
			if ( clusters[smallest_i].getWeight() < clusters[smallest_j].getWeight())
		    {
		    	return clusters[smallest_i];
		    }
		    
		    return clusters[smallest_j];
		}
		
		public function removeLeastSignificantCluster():QuantizeDataRGB
		{
			var d:Number, i:int, j:int;
			/*
			for ( i = clusters.length; --i > -1;)
			{
				clusters[i].clearDistanceCache();
			}
			*/
			
			var smallestDistance:Number = Number.MAX_VALUE;
			var smallest_i:int, smallest_j:int, smallest_weight:Number;
			
			
			var cluster:QuantizeDataRGB;
			for ( i = 0; i < clusters.length - 1; i++ )
			{
				cluster = clusters[i];
				for ( j = i + 1; j < clusters.length; j++ )
				{
					d = cluster.getDistanceTo(clusters[j]);
					if ( d < smallestDistance || ( d == smallestDistance && smallest_weight > cluster.getWeight() + clusters[j].getWeight()) )
					{
						smallestDistance = d;
						smallest_i = i;
						smallest_j = j;
						smallest_weight = cluster.getWeight() + clusters[j].getWeight(); 
					} 
				}
			}
			
		    if ( clusters[smallest_i].getWeight() < clusters[smallest_j].getWeight())
		    {
		    	clusters[smallest_j].merge( clusters[smallest_i] );
		    	return removeClusterAt( smallest_i );
		    } else {
		    	clusters[smallest_i].merge( clusters[smallest_j] );
				return removeClusterAt( smallest_j );
		    }
		}
		
		public function getClosestCluster( data:QuantizeDataRGB ):QuantizeDataRGB
		{
			var bestDistance:Number = Number.MAX_VALUE;
			var closest:QuantizeDataRGB;
			var distance:Number;
			
			for ( var i:int = 0; i < clusters.length; i++ )
			{
				distance =  clusters[i].getDistanceTo(  data );
				if ( distance < bestDistance )
				{
					bestDistance = distance;
					closest = clusters[i] ;
					if ( distance == 0 ) return closest;
				}
			}
			
			return closest;
		}
		

	}
}