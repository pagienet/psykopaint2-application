package net.psykosoft.psykopaint2.paint.config
{

	import flash.display.DisplayObjectContainer;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;

	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;

	public class PtConfig
	{
		private var _injector:Injector;
		private var _mediatorMap:IMediatorMap;
		private var _commandMap:ISignalCommandMap;

		public function PtConfig( display:DisplayObjectContainer, injector:Injector ) {
			super();
			// TODO: set this up...
		}
	}
}
