package net.psykosoft.psykopaint2.core.drawing.paths.helpers
{
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	final public class KDTreeNode
	{
		public var left:KDTreeNode;
		public var right:KDTreeNode;
		public var depth:int;
		public var point:SamplePoint;
		public var dist:Number;
		public var parent:KDTreeNode;
		public var count:uint = 1;
				
		public function KDTreeNode()
		{}
	}
}