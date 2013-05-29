package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	
	public class EndConditionalDecorator extends AbstractPointDecorator
	{
		public function EndConditionalDecorator()
		{
			super();
		}
		
		override public function getParameterSet( path:Array ):XML
		{
			return <EndConditionalDecorator />;
		}
	}
}