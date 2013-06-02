package net.psykosoft.psykopaint2.core.drawing.brushes.color
{
	public interface IColorStrategy
	{
		function getColor(x : Number, y : Number, size : Number, target :  Vector.<Number>, targetIndexMask:int = 15) : void;
		
		function getColors(x : Number, y : Number, radius : Number, sampleSize : Number, target :Vector.<Number>) : void;
		
		
		function setBlendFactors(colorBlendFactor : Number, alphaBlendFactor : Number) : void;
			
	}
}