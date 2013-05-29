package net.psykosoft.psykopaint2.core.drawing.data
{
	import com.quasimondo.delaunay.DelaunayNodeProperties;
	
	public class DelaunayMetaData extends DelaunayNodeProperties
	{
		public var angle:Number;
		
		public function DelaunayMetaData(angle:Number)
		{
			super(true);
			this.angle = angle;
		}
	}
}