package  {
	
	import flash.display.MovieClip;
	
	import com.alanmacdougall.underscore._;

	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.events.MouseEvent;
	
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	public class BarcodeCheck extends MovieClip {
		protected var check_list:Array;
		protected var input_list:Array;
		protected var count:Number;
		
		public function BarcodeCheck():void {
			// initalize lists
			check_list = [];
			input_list = [];
			count = 0;
			// handle events
			code_entry.addEventListener(TextEvent.TEXT_INPUT, _.debounce(onTextInput, 333));
			file_picker.addEventListener(MouseEvent.CLICK, onFileClick);
		}
		
		protected function updateCounter(increment:int = 1):void {
			count += increment;
			counter.text = 'Counter: '+ count;
		}
		
		protected function isValid(code:String):Boolean {
			return check_list.indexOf(code) == -1;
			// TODO block re-entry of code?
			return check_list.indexOf(code) == -1
			  	&& input_list.indexOf(code) == -1;
		}
		
		protected function onListCheck(code:String):void {
			trace(code);
			if (isValid(code)) {
				input_list.push(code);
				updateCounter();
			}
		}
		
		protected function onListLoad(lines:Array):void {
			check_list = lines;
			// TODO flush input list?
			//input_list = [];
		}
		
		protected function onFileClick(e:MouseEvent):void {
			var f:File = new File;
			f.addEventListener(Event.COMPLETE, function(e:Event):void {
				var data:String = f.data.readUTFBytes(f.data.bytesAvailable) || "";
				onListLoad(data.split("\r").join('').split("\n"));
			});
			// what
			f.addEventListener(Event.SELECT, function(e:Event):void {
				f.load();
			});
			f.browse([new FileFilter("Text documents", "*.txt")]);
		}
		
		protected function onTextInput(e:TextEvent):void {
			var code:String = e.target.text;
			e.target.text = '';
			onListCheck(code);
		}
	}
	
}
