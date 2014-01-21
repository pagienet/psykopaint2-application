package com.quasimondo.data
{
	public interface IQuantizeData
	{
		
		function getDistanceTo( data:IQuantizeData ):Number;
		function setDistanceTo( data:IQuantizeData, distance:Number ):void;
		
		function isWithinRadius( data:IQuantizeData, useCache:Boolean = true ):Boolean;
		function merge( data:IQuantizeData ):void;
		function getRadius():Number;
		function getWeight():Number;
		function clearDistanceCache():void
		
	}
}