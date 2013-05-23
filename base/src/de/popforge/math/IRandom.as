package de.popforge.math
{
	public interface IRandom
	{
		function setSeed( seed:uint ): void
		
		function getNumber( min: Number = 0, max: Number = 1 ): Number
	
	 	function getNextInt(): uint
		
		function getMappedNumber( min: Number = 0, max: Number = 1, mappingFunction:Function = null):Number
			
		function getChance( chance:Number = 0.5 ):Boolean
	}
}
