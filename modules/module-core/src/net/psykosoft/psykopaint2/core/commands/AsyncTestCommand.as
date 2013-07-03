package net.psykosoft.psykopaint2.core.commands
{

	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;

	import robotlegs.bender.framework.api.IContext;

	// TODO: delete
	public class AsyncTestCommand extends TracingCommand
	{
		[Inject]
		public var context:IContext;

		public static var id:uint;
		private var _id:uint;

		public function AsyncTestCommand() {
			super();
			trace( "AsyncTestCommand - born: " + id );
			_id = id;
			id++;
		}

		override public function execute():void {
			super.execute();
			context.detain( this );
			trace( "AsyncTestCommand - detained: " + _id );
			setTimeout( function():void {
				context.release( this );
				trace( "AsyncTestCommand - released: " + _id );
			}, 2000 );
		}
	}
}
