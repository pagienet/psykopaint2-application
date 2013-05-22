package net.psykosoft.psykopaint2.base.robotlegs
{

	import robotlegs.bender.extensions.signalCommandMap.SignalCommandMapExtension;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IExtension;

	public class BsSignalCommandMapBundle implements IExtension
	{
		public function extend( context:IContext ):void {
			context.install( SignalCommandMapExtension );
		}
	}
}
