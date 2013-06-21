package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	
	final public class EndConditionalDecorator extends AbstractPointDecorator
	{
		public function EndConditionalDecorator()
		{
			super();
		}
		
		override public function getParameterSetAsXML( path:Array ):XML
		{
			return <EndConditionalDecorator />;
		}
	}
}