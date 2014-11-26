package  {
	
	import flash.display.MovieClip;
	import flash.display.Graphics;
	
	import com.alanmacdougall.underscore._;

	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.events.MouseEvent;
	
	import flash.filesystem.File;
	import flash.net.FileFilter;

	import fl.controls.DataGrid;
	import fl.controls.Button;
	import fl.controls.TextInput;
	
	public class BarcodeCheck extends MovieClip {
		protected var check_list:Array;
		protected var input_list:Array;
		protected var count:Number;
		
		public var code_entry:TextInput;
		public var file_picker:Button;
		public var file_saver:Button;
		public var input_items:DataGrid;
		public var check_items:DataGrid;
		
		public function BarcodeCheck():void {
			// initalize lists
			check_list = [];
			input_list = [];
			count = 0;
			input_items.addColumn("Code");	
			check_items.addColumn("Code");	
			// handle events
			code_entry.addEventListener(TextEvent.TEXT_INPUT, _.debounce(onTextInput, 333));
			file_picker.addEventListener(MouseEvent.CLICK, onFileClick);
		}
		
		protected function indicate(good:Boolean):void {
			// TODO animate good / bad
			// indicator.
			var g:Graphics = this.graphics,
				w:Number = this.stage.stageWidth,
				h:Number = this.stage.stageHeight;
			g.clear();
			g.beginFill(good ? 0x00ff00 : 0xff0000);
			g.drawRect(0, 0, w, h);
			g.endFill();
		}
		
		protected function updateCounter(increment:int = 1):void {
			count += increment;
			counter.text = 'Counter: '+ count;
		}
		
		protected function isValid(code:String):Boolean {
			return check_list.indexOf(code) !== -1
			  	&& input_list.indexOf(code) == -1;
		}
		
		protected function onListCheck(code:String):void {
			if (isValid(code)) {
				input_list.push(code);
				input_items.addItem({ Code: code });
				var d:DataGrid = check_items;
				for (var i:Number = d.length; i--;) {
					var item:* = d.getItemAt(i);
					if (item.Code == code) {
						d.removeItemAt(i);
						break;
					}
				}
				updateCounter();
				indicate(true);
			}
			else {
				indicate(false);
			}
		}
		
		protected function onListLoad(lines:Array):void {
			check_list = lines;
			check_items.removeAll();
			lines.forEach(function(item:String, index:int, arr:Array):void {
				check_items.addItem({ Code: item });
            });
			// TODO flush input list?
			input_list = [];
			input_items.removeAll();
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
